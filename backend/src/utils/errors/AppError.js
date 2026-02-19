/*
    AppError provides a single error type that maps expected errors
    such as validation errors, auth errors, etc. 4xx error codes.
    These can be used to throw errors without repetitive try/catch blocks

    Use like:
        throw AppError.badRequest(...);

    If inside a callback ((...) => {}), inside an event handler (.on(...)) or inside a timer (timeout), 
    errors must be passed with next(err). Otherwise, throw the error and Express will route it accordingly.
*/

export default class AppError extends Error {
    constructor(statusCode, message, code='ERROR', details) {
        super(message); // pass error msg to the parent error class
        this.name = 'AppError'; // default name
        this.statusCode = statusCode; // http status
        this.code = code; // short code name for the error
        this.details = details; // optional metadata (e.g., invalid fields)

        // make the stack trace begin at the line where the AppError is created, so constructor isn't top frame
        if (Error.captureStackTrace) {
            Error.captureStackTrace(this, AppError);
        }
    }

    // when request is malformed or missing required fields:
    static badRequest(msg='Bad request', details) {
        return new AppError(400, msg, 'BAD_REQUEST', details);
    }

    // when login fails, invalid or expired token, or token signature is bad
    static unauthorized(msg='Unauthorized', details) {
        return new AppError(401, msg, 'UNAUTHORIZED', details);
    }

    // when user is authenticated, but doesn't have permission
    static forbidden(msg='Forbidden', details) {
        return new AppError(403, msg, 'FORBIDDEN', details);
    }

    // when route exists but resource id doesn't, or fetch by id returns no row
    static notFound(msg='Not Found', details) {
        return new AppError(404, msg, 'NOT_FOUND', details);
    }

    // when username is taken, editing stale data, or duplicate action
    static conflict(msg='Conflict', details) {
        return new AppError(409, msg, 'CONFLICT', details);
    }

    // input is well-formed json, but fails validation rules (e.g., invalid email format, field missing, etc)
    // probably handled by the frontend so may not be used much
    static unprocessable(msg='Validation failed', details) {
        return new AppError(422, msg, 'UNPROCESSABLE_ENTITY', details);
    }
}