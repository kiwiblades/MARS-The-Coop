import User from '../models/userModel.js'; 
import { sequelize } from '../db/sequelize.js';

async function checkUserHash() {
  try {
    // 1. Connect to DB
    await sequelize.authenticate();
    console.log('Connected to Database');

    // 2. Find the user
    const user = await User.findOne({ where: { username: 'coopuser1' } });

    if (user) {
      console.log('User found!');
      console.log('Stored password_hash:', user.password_hash);
      
      // 3. Check if it's a bcrypt hash
      if (user.password_hash.startsWith('$2b$')) {
        console.log('Hashing Verified: This is a valid bcrypt hash.');
      } else {
        console.log('Hashing Failed: This appears to be plain text or a different format.');
      }
    } else {
      console.log('User not found.');
    }
  } catch (error) {
    console.error('Error:', error);
  } finally {
    await sequelize.close();
  }
}

checkUserHash();