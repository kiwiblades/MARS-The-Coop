/*
    Global error handling middleware used to normalize external errors to AppError type,
    use for known operational errors and return a JSON payload to frontend.
    Unknown errors return a generic 500 response and the details are kept to the server.
*/

import AppError from "../utils/errors/AppError.js";

export default function errorHandler(err, req, res, next) {
    // if the headers have already been sent to the client, forward to Express default handlers
    if (res.headersSent) return next(err);

    if (err instanceof AppError) {
        // this info is logged on the server only
        console.warn('OperationalError', {
            code: err.code,
            message: err.message,
            details: err.details,
            path: req.originalUrl,
            method: req.method,
        });

        // only return error message and code to the client
        return res.status(err.statusCode).json({
            error: err.message,
            code: err.code,
        });
    }

    // if the error isn't known, log it in the server
    console.error('UNHANDLED ERROR:', err);
    // then return a generic 500 error to the client
    return res.status(500).json({
        error: 'Internal server error',
        code: 'INTERNAL_ERROR',
    })
}