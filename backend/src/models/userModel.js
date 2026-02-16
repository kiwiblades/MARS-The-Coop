const db = require('../db/pool'); // Import database connection pool
const bcrypt = require('bcrypt'); // Import bcrypt for hashing

// Defines the function to create a user and save to database
async function createUser({ username, email, password }) {
    // 1. Encrypt the password before saving
    const saltRounds = 10;
    const password_hash = await bcrypt.hash(password, saltRounds);

    // 2. Define the SQL query to insert the user
    const query = `
        INSERT INTO users (username, email, password_hash)
        VALUES ($1, $2, $3)
        RETURNING uid, username, email;`; // Return the unique ID and username
        
    // 3. Execute the query safely
    const values = [username, email, password_hash];
    const result = await db.query(query, values);
    
    // 4. Return the new user object
    return result.rows[0];
}

// Function to find a user to check for duplicates
async function getUserByUsername(username, email) {
    const query = 'SELECT uid FROM users WHERE username = $1';
    const result = await db.query(query, [username, email]);
    return result.rows[0] || null; // Return user if found, else null
}

module.exports = { createUser, getUserByUsernameOrEmail }; // Export the functions