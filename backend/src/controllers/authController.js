const userModel = require('../models/userModel'); // Import the user model

// Logic to handle user sign up
async function signup(req, res) {
    try {
        const { username, password } = req.body; // Extract username/password

        // 1. Validate required fields
        if (!username || !password) {
            return res.status(400).json({ error: "Missing required fields" });
        }

        // 2. Check if username already exists (Duplicate Check)
        const existingUser = await userModel.getUserByUsername(username);
        if (existingUser) {
            return res.status(400).json({ error: "Username already recorded" });
        }

        // 3. Create the user (Password is hashed in the model)
        const newUser = await userModel.createUser({ username, password });

        // 4. Return success with the Unique ID
        return res.status(201).json({
            message: "User created successfully",
            userId: newUser.uid 
        });

    } catch (error) {
        console.error(error);
        res.status(500).json({ error: "Internal server error" });
    }
}

module.exports = { signup }; // Export the controller function