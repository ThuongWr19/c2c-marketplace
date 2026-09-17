import "dotenv/config";
import fs from "fs/promises";
import path from "path";
import mysql from "mysql2/promise";

async function migrate() {
    const connection = await mysql.createConnection({
        host: process.env.DB_HOST,
        port: Number(process.env.DB_PORT),
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        database: process.env.DB_NAME,
        multipleStatements: true,
        charset: "utf8mb4",
        timezone: "Z",
    });

    try {
        const files = (await fs.readdir(import.meta.dirname)).filter((f) => f.endsWith(".sql")).sort();

        console.log(`[Migrate] Found ${files.length} SQL files`);

        for (const file of files) {
            const sql = await fs.readFile(path.join(import.meta.dirname, file), "utf8");
            console.log(`[Migrate] Running ${file}...`);
            try {
                await connection.query(sql);
                console.log(`[Migrate] ${file} done`);
            } catch (err) {
                console.error(`[Migrate] ${file} FAILED:`, err.message);
                process.exit(1);
            }
        }

        console.log("[Migrate] All migrations completed");
    } finally {
        await connection.end();
    }

    process.exit(0);
}

migrate().catch((err) => {
    console.error("[Migrate] Failed:", err);
    process.exit(1);
});
