import "dotenv/config";
import fs from "fs/promises";
import path from "path";
import mysql from "mysql2/promise";

const SQL_FILE = path.join(import.meta.dirname, "../sql/init.sql");

async function resetDb() {
    console.log("[DB Reset] Connecting to MySQL...");

    const connection = await mysql.createConnection({
        host: process.env.DB_HOST,
        port: Number(process.env.DB_PORT),
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        multipleStatements: true,
    });

    try {
        console.log(`[DB Reset] Dropping database ${process.env.DB_NAME}...`);
        await connection.query(`DROP DATABASE IF EXISTS \`${process.env.DB_NAME}\``);

        console.log(`[DB Reset] Creating database ${process.env.DB_NAME}...`);
        await connection.query(
            `CREATE DATABASE \`${process.env.DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci`,
        );

        console.log(`[DB Reset] Switching to ${process.env.DB_NAME}...`);
        await connection.query(`USE \`${process.env.DB_NAME}\``);

        console.log("[DB Reset] Reading SQL file...");
        const sql = await fs.readFile(SQL_FILE, "utf8");

        console.log("[DB Reset] Executing SQL...");
        await connection.query(sql);

        const [tables] = await connection.query("SHOW TABLES");
        const [categories] = await connection.query("SELECT COUNT(*) AS c FROM categories");
        const [configs] = await connection.query("SELECT COUNT(*) AS c FROM system_configs");

        console.log(`[DB Reset] Tables: ${tables.length}`);
        console.log(`[DB Reset] Categories: ${categories[0].c}`);
        console.log(`[DB Reset] System configs: ${configs[0].c}`);
        console.log("[DB Reset] Done successfully");
    } catch (err) {
        console.error("[DB Reset] Failed:", err.message);
        process.exit(1);
    } finally {
        await connection.end();
    }
}

resetDb().catch((err) => {
    console.error("[DB Reset] Fatal:", err);
    process.exit(1);
});
