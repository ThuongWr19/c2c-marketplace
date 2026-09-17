import react from "@vitejs/plugin-react";
import { defineConfig } from "vite";
import tailwindcss from "@tailwindcss/vite";
import path from "path";

// https://vite.dev/config/
export default defineConfig({
    plugins: [react(), tailwindcss()],
    resolve: { alias: { "@": path.resolve(import.meta.dirname, "./src") } },
    server: {
        port: 5173,
        host: true,
        watch: { usePolling: true, interval: 300, ignored: ["**/node_modules/**", "**/.git/**"] },
        proxy: {
            "/api": { target: "http://localhost:4000", changeOrigin: true },
            "/socket.io": { target: "http://localhost:4000", ws: true },
        },
    },
});
