import request from "supertest";
import app from "../src/app.js";

describe("Health Check", () => {
    it("should return status ok on /heath", async () => {
        const res = await request(app).get("/heath");
        expect(res.statusCode).toBe(200);
        expect(res.body).toEqual({ status: "ok" });
    });
});
