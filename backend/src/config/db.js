import mysql from "mysql2/promise";

export const pool = mysql.createPool({
    host: process.env.DB_HOST,
    port: Number(process.env.DB_PORT),
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    waitForConnections: true,
    connectionLimit: Number(process.env.DB_POOL_MAX) || 20,
    queueLimit: 0,
    enableKeepAlive: true,
    keepAliveInitialDelay: 10000,
    timezone: "Z",
    charset: "utf8mb4",
});

export async function testConnection() {
    const conn = await pool.getConnection();
    try {
        await conn.ping();
        console.log("[MySQL] connected");
    } finally {
        conn.release();
        
    }
}
