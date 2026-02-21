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
    },
    // flags to indicate email verification status
    emailVerified: {
        type: DataTypes.BOOLEAN,
        allowNull: false,
        defaultValue: false,
    },
    emailVerifiedAt: {
        type: DataTypes.DATE,
        allowNull: true,
    }, // id to indicate which of the default profile pictures the user has chosen
    pigeonId: {
        type: DataTypes.INTEGER,
        allowNull: false,
        defaultValue: 0,
    }
}, {
    // Hooks run automatically at certain points
    hooks: {
        // Before creating a user, hash their password
        beforeCreate: async (user) => {
            const salt = await bcrypt.genSalt(10); // Generate salt
            user.password_hash = await bcrypt.hash(user.password_hash, salt); // Hash and replace
        }
    },
    tableName: 'user',
    timestamps: true,
});

export default User; // Export the model