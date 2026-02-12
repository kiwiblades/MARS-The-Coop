/*
    Reference example controller for testing server and database connectivity
*/

import HealthCheck from "../models/Healthcheck.js";

// GET /health
export async function serverHealth(req, res) {
    // no try/catch is needed
    res.json({ ok: true, message: "backend reachable" });
}

// GET /health/db
export async function dbHealth(req, res) {
    try {
        const row = await HealthCheck.create({});
        const count = await HealthCheck.count();
        res.json({ ok: true, insertedId: row.id, totalRows: count });
    } catch(e) {
        console.error(e);
        res.status(500).json({ ok: false, error: "db healthcheck failed" });
    }
}