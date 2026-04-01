import fetch from 'node-fetch';
import dotenv from 'dotenv';
dotenv.config();

const USERNAME = process.env.TEST_USERNAME;
const PASSWORD = process.env.TEST_PASSWORD;
const SV_PORT  = process.env.SV_PORT || '5000';
const URL      = `http://127.0.0.1:${SV_PORT}`;

console.log('signing in...');
const signinRes = await fetch(`${URL}/auth/signin`, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ username: USERNAME, password: PASSWORD }),
});
const { accessToken } = await signinRes.json();

console.log("resetting today's questions...");
const res = await fetch(`${URL}/daily-question/reset-today`, {
  method: 'DELETE',
  headers: { 'Authorization': `Bearer ${accessToken}` },
});
const data = await res.json();
console.log('done:', data);