/*
    This file acts as script to generate migrations, which are schemas.
    You can run the file using "npm run db:migrate" from backend/.
*/

import { migrator } from './migrator';

await migrator.up();
console.log('Migrations applied.');
process.exit(0);