/* JWT Security flow:

4. when user tries to access protected rout
-> frontend sends JWT token in request header
-> authenticakeToken middleware extracts token from header, verifies it using JWT_SECRET
 */

import { verifyToken } from '../utils/jwt.js'; // Import the token verification function

// Middleware function to check for a valid JWT token
export const authenticateToken = (req, res, next) => {
    // 1. Get the token from the request header (Authorization: Bearer <token>)
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // Extract token from "Bearer ..."

    // 2. If no token is provided, return 401 Unauthorized
    if (!token) {
        return res.status(401).json({ error: "Access denied. No token provided." });
    }

    try {
        // 3. Verify the token using the utility function
        const verified = verifyToken(token);
        
        // 4. Attach the user data to the request object so controllers can use it
        req.user = verified; 
        
        // 5. Move to the next function (the controller)
        next(); 
    } catch (error) {
        // 6. If token is invalid or expired, return 403 Forbidden
        res.status(403).json({ error: "Invalid or expired token." });
    }
};

export default authenticateToken;