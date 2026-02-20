Backend structure

Folders
routes/ 
-> maps URL paths to controllers controllers/ 
-> HTTP handlers (req/res). class model/query functions (no schema definitions here) models/ 
-> sequelize models and associations (db/table definitions) middleware/ 
-> auth, validation, error handling. runs before controllers utils/ -> stateless helpers (jwt, mailer, etc) db/ 
-> sequelize init, connection, config

(more to be added for sockets later)

HealthCheck is an example of the separation: model = models/HealthCheck.js controller = controllers/healthController.js routes = routes/healthRoutes.js

Request flow

Frontend calls API endpoints: route 
-> middleware 
-> controller 
-> model/query 
-> res.json(...)

Errors: - Expected client errors (4xx): throw AppError.(...) - Unexpected errors: middleware/errorHandler handles it and returns a generic 500 response

API response
Success: JSON payload + appropriate 2xx status
Errors: { error: string, code: string } with corresponding status code
Conventions
Don't define schemas inside of controllers, keep the entity info in models
Don't return internal error details to the client, log info to the server side console
Mount routes in server.js as app.use('/prefix', router)