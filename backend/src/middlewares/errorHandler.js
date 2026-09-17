import { ZodError } from "zod";

export function errorHandler(err, req, res, next) {
    console.error(err);
    if (err instanceof ZodError) {
        return res
            .status(422)
            .json({
                success: false,
                error: { code: "VALIDATION_ERROR", message: "Dữ liệu không hợp lệ", details: err.errors },
            });
    }

    res.status(err.status || 500).json({
        success: false,
        error: { code: err.code || "INTERNAL_ERROR", message: err.message || "Lỗi hệ thống" },
    });
}
