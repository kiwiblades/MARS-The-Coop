/*
  Config.js loads .env and exports a config, so only one place loads .env.
  Anything else using .env values should import this config rather than calling process.env.
*/

import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// indicate path to the root .env file
dotenv.config({ path: path.resolve(__dirname, '../.env') }); 

// populate process.env
export const config = {
  SV_PORT: process.env.SV_PORT ?? '5000',
  DATABASE_URL: process.env.DATABASE_URL,
  db: {
    host: process.env.PGHOST ?? "localhost",
    port: Number(process.env.PGPORT ?? "5432"),
    name: process.env.PGDATABASE,
    user: process.env.PGUSER,
    password: process.env.PGPASSWORD
  },
};