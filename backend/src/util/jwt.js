// /* JWT security flow:

// 1. issue token
// -> user creatd in database 
// -> controller calls generateToken function in jwt.js to create a new JWT token for the user

// 2. create payload 
// -> func takes user info (uid, email) and packages it into the token payload
// -> use jwt.sign + JWT_SECRET to cryptographically sign the token, set expiration time from config

// 3. controller send token back to frontend in JSON response + success message
// */

// import jwt from 'jsonwebtoken'; // Import the jsonwebtoken library using ESM syntax
// import { JWT_SECRET, JWT_EXPIRES_IN } from '../config.js'; // Import config with .js extension

// // Function to generate a new JWT token for a user
// export const generateToken = (user) => {
//     // Defines the payload (data) to be stored in the token
//     return jwt.sign(
//         { uid: user.uid, email: user.email }, // Payload containing user identifiers
//         JWT_SECRET, // Secret key for signing the token
//         { expiresIn: JWT_EXPIRES_IN } // Expiration time from config
//     );
// };

// // Function to verify a token from the frontend
// export const verifyToken = (token) => {
//     // Verify token using the secret key
//     return jwt.verify(token, JWT_SECRET);
// };