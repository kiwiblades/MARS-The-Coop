/*
3. check for duplicates
-> controller calls User.findOne on sequelize model to scan database
-> looks for existing user where username OR email matches the new one
--> if found, return error to frontend

4. --> if not found, proceed to create user
---> beforeCreate hook in the model automatically hashes the password before saving to database
 */

import { DataTypes } from 'sequelize'; // Import data types for the schema
import { sequelize } from '../db/sequelize.js'; // Import the established connection
import bcrypt from 'bcrypt'; // Import bcrypt for hashing

// Define the User model as a Sequelize object
const User = sequelize.define('User', {
    // Unique ID for the user
    uid: {
        type: DataTypes.UUID, // Use UUID type
        defaultValue: DataTypes.UUIDV4, // Automatically generate unique IDs
        primaryKey: true // Set as primary key
    },
    // Username field
    username: {
        type: DataTypes.STRING, // String type
        allowNull: false, // Cannot be empty
        unique: true // Must be unique in the DB
    },
    // Email field (Required for the verification story)
    email: {
        type: DataTypes.STRING, // String type
        allowNull: false, // Cannot be empty
        unique: true // Must be unique in the DB
    },
    // Hashed password field
    password_hash: {
        type: DataTypes.STRING, // String type
        allowNull: false // Cannot be empty
    }
}, {
    // Hooks run automatically at certain points
    hooks: {
        // Before creating a user, hash their password
        beforeCreate: async (user) => {
            const salt = await bcrypt.genSalt(10); // Generate salt
            user.password_hash = await bcrypt.hash(user.password_hash, salt); // Hash and replace
        }
    }
});

export default User; // Export the model

// // Defines the function to create a user and save to database
// async function createUser({ username, email, password }) {
//     // 1. Encrypt the password before saving
//     const saltRounds = 10;
//     const password_hash = await bcrypt.hash(password, saltRounds);

//     // 2. Define the SQL query to insert the user
//     const query = `
//         INSERT INTO users (username, email, password_hash)
//         VALUES ($1, $2, $3)
//         RETURNING uid, username, email;`; // Return the unique ID and username
        
//     // 3. Execute the query safely
//     const values = [username, email, password_hash];
//     const result = await db.query(query, values);
    
//     // 4. Return the new user object
//     return result.rows[0];
// }

// // Function to find a user to check for duplicates
// async function getUserByUsername(username, email) {
//     const query = 'SELECT uid FROM users WHERE username = $1';
//     const result = await db.query(query, [username, email]);
//     return result.rows[0] || null; // Return user if found, else null
// }

// module.exports = { createUser, getUserByUsernameOrEmail }; // Export the functions