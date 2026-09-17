import "dotenv/config";
import http from "http";
import app from "./app.js";
import { testConnection } from "./config/db.js";
import { connectRedis } from "./config/redis.js";

const PORT = process.env.PORT || 4000;

async function bootstrap() {
    await testConnection();
    await connectRedis();

    const server = http.createServer(app);

    server.listen(PORT, () => {
        console.log(`[Server] Running on http://localhost:${PORT}`);
    });
}

bootstrap().catch((err) => {
    console.error("[Bootstrap] Failed:", err);
    process.exit(1);
});
