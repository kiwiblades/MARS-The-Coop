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
  email: {
    host: process.env.SMTP_HOST ?? "smtp.gmail.com",
    port: Number(process.env.SMTP_PORT ?? "465"),
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASS,
    secure: process.env.SMTP_SECURE ?? true,
    email_from: process.env.EMAIL_FROM
  },
  jwt: {
    access_secret: process.env.ACCESS_TOKEN_SECRET,
    refresh_secret: process.env.REFRESH_TOKEN_SECRET,
    verify_email_secret: process.env.VERIFY_EMAIL_SECRET,
    access_expires_in: process.env.ACCESS_EXPIRES_IN || '15m',
    refresh_expires_in: process.env.REFRESH_EXPIRES_IN || '30d',
    verify_email_expires_in: process.env.VERIFY_EMAIL_EXPIRES_IN || "1h"
  },
};