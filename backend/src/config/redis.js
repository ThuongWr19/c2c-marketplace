import { createClient } from "redis";

export const redis = createClient({
    socket: { host: process.env.REDIS_HOST, port: Number(process.env.REDIS_PORT) },
    password: process.env.REDIS_PASSWORD || undefined,
});

redis.on("error", (err) => console.error("[Redis] Error:", err));
redis.on("connect", () => console.log("[Redis] Connected"));

export async function connectRedis() {
    if (!redis.isOpen) await redis.connect();
}
