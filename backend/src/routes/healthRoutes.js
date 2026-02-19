/*
    Example routes:
    The main mount is /health, so the endpoints look like:
    '/health' and '/health/db'
*/

import { Router } from "express";
import { serverHealth, dbHealth } from "../controllers/healthController.js";

const router = Router();

router.get("/", serverHealth);
router.get("/db", dbHealth);

export default router;