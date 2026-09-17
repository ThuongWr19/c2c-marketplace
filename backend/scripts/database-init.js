import "dotenv/config";
import fs from "fs/promises";
import path from "path";
import mysql from "mysql2/promise";

const SQL_FILE = path.join(import.meta.dirname, "../sql/init.sql");

async function initDb() {
    console.log("[DB Init] Connecting to MySQL...");

    const connection = await mysql.createConnection({
        host: process.env.DB_HOST,
        port: Number(process.env.DB_PORT),
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        database: process.env.DB_NAME,
        multipleStatements: true,
    });

    try {
        console.log("[DB Init] Reading SQL file...");
        const sql = await fs.readFile(SQL_FILE, "utf8");

        console.log("[DB Init] Executing SQL...");
        const [results] = await connection.query(sql);

        const statementCount = Array.isArray(results) ? results.length : 1;
        console.log(`[DB Init] Executed ${statementCount} statements`);

        const [tables] = await connection.query("SHOW TABLES");
        console.log(`[DB Init] Total tables: ${tables.length}`);

        console.log("[DB Init] Done successfully");
    } catch (err) {
        console.error("[DB Init] Failed:", err.message);
        console.error("[DB Init] SQL State:", err.sqlState);
        console.error("[DB Init] Error code:", err.code);
        process.exit(1);
    } finally {
        await connection.end();
    }
}

initDb().catch((err) => {
    console.error("[DB Init] Fatal:", err);
    process.exit(1);
});
