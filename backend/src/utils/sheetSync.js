/*
    Syncs Google Sheets to PostgreSQL database
    Fetches rows from the queston sheet and upserts them into the question table
    with Sequelize
*/

import { google } from 'googleapis';
import { config } from '../config.js'
import Question from '../models/Question.js';

// map the database field names to the actual sheet column names (row 1)
const COLUMN_MAP = {
    question: 'Question',
    relationshipType: 'Relationship Type',
    questionType: 'Question Type',
    topics: {
        single: 'Topics',
        primary: 'Primary Question Topic',
        secondary: 'Secondary Question Topic',
    },
};

// handles both two-column format, and also single topics col separated with commas (if the sheet updates in the future)
function parseTopics(row, headers) {
    // if the sheet has a single 'Topics' column
    if (headers.includes(COLUMN_MAP.topics.single)) {
        const raw = row[COLUMN_MAP.topics.single];
        if (!raw) return [];
        return raw.split(',').map(t => t.trim()).filter(Boolean);
    }
    // otherwise, use primary + secondary topic format
    const primary = row[COLUMN_MAP.topics.primary] ?? null;
    const secondary = row[COLUMN_MAP.topics.secondary] ?? null;
    return [primary, secondary].filter(Boolean);
}

// formatted sync result to return after a sync, shows success/error status
export let lastSyncResult = { status: 'never run', timestamp: null };

function getSheetsClient() {
    const auth = new google.auth.GoogleAuth({
        keyFile: config.sheets.keyFilePath,
        scopes: ['https://www.googleapis.com/auth/spreadsheets.readonly'],
    });
    return google.sheets({ version: 'v4', auth });
}

// grab and filter rows from the sheet
async function fetchSheetRows() {
    const sheets = getSheetsClient();
    const res = await sheets.spreadsheets.values.get({
        spreadsheetId: config.sheets.spreadsheetId,
        range: config.sheets.sheetName,
    });

    const [headerRow, ...dataRows] = res.data.values || [];
    if (!headerRow) {
        throw new Error('[sheetSync] read sheet as empty, no header found');
    }

    const rows = dataRows
        .filter(row => row.some(cell => cell?.trim())) // skip blank rows
        .map(row => {
            const obj = {};
            headerRow.forEach((header, i) => {
                obj[header] = row[i]?.trim() ?? null;
            });
            return obj;
        });

    // pass headers with rows
    return { headers: headerRow, rows };
}

// update/insert values pulled from the sheet
async function upsertRows({ headers, rows: sheetRows }) {
    if (!sheetRows.length) return 0;

    const records = sheetRows
        .filter(row => row[COLUMN_MAP.question]) // skip rows with no question text
        .map(row => ({
            question: row[COLUMN_MAP.question],
            relationshipType: row[COLUMN_MAP.relationshipType],
            questionType: row[COLUMN_MAP.questionType] ?? null,
            topics: parseTopics(row, headers),
            syncedAt: new Date(),
        }));

    await Question.bulkCreate(records, {
        updateOnDuplicate: [
            'relationshipType',
            'questionType',
            'topics',
            'syncedAt',
        ],
    });

    return records.length;
}

// sync the database with the sheet
export async function runSync() {
    console.log(`[sheetSync] starting sync at ${new Date().toISOString()}`);
    try {
        const { headers, rows } = await fetchSheetRows();
        console.log(`[sheetSync] fetched ${rows.length} rows from the sheet`);
        const upserted = await upsertRows({ headers, rows });
        lastSyncResult = {
            status: 'success',
            timestamp: new Date().toISOString(),
            rowsFetched: rows.length,
            rowsUpserted: upserted,
        };
        console.log(`[sheetSync] upserted ${upserted} rows, done`);
    } catch(err) {
        lastSyncResult = {
            status: 'error',
            timestamp: new Date().toISOString(),
            error: err.message,
        };
        console.error('[sheetSync] sync failed:', err.message);
    }
    return lastSyncResult;
}

// cron scheduler
export function startScheduler() {
    const hours = config.sheets.syncIntervalHours;
    const ms = hours*60*60*1000; // convert the interval hrs to ms
    console.log(`[sheetSync] scheduler started, syncing every ${hours}h`);
    runSync(); // sync immediately on startup
    setInterval(runSync, ms);
}