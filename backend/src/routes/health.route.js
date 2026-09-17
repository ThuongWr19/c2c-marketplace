import { Router } from "express";
import { pool } from "../config/db.js";
import { redis } from "../config/redis.js";

const router = Router();

router.get("/", async (_req, res, next) => {
    try {
        await pool.query("SELECT 1");
        await redis.ping();
        res.json({ success: true, data: { db: "ok", redis: "ok" } });
    } catch (err) {
        next(err);
    }
});

export default router;
