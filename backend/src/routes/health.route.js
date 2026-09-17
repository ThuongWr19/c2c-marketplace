import { Router } from "express";
import { pool } from "../config/db.js";
import { redis } from "../config/redis.js";
import { success } from "zod";

const router = Router();

router.get("/", async (req, res, next) => {
    try {
        await pool.query("SELECT 1");
        await redis.ping();
        res.json({ success: true, data: { db: "ok", redis: "ok" } });
    } catch (error) {
        next(err);
    }
});

export default router;
