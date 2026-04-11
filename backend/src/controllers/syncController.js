import { runSync, lastSyncResult } from "../utils/sheetSync.js";
import AppError from "../utils/errors/AppError.js";

// manually trigger spreadsheet-database sync
export async function triggerSync(req, res) {
    const result = await runSync();
    const status = result.status === 'success' ? 200 : 500;
    return res.status(status).json(result);
}

// fetch most recent sync result
export function getSyncStatus(req, res) {
    return res.json(lastSyncResult);
}