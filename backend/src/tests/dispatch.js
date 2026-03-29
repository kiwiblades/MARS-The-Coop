import fetch from 'node-fetch';
import dotenv from 'dotenv';
dotenv.config();

const USERNAME = process.env.TEST_USERNAME;
const PASSWORD = process.env.TEST_PASSWORD;
const SV_PORT = process.env.SV_PORT || '5000';
const URL = `http://127.0.0.1:${SV_PORT}`;

if (!USERNAME || !PASSWORD) {
  console.error('set TEST_USERNAME and TEST_PASSWORD in your .env file');
  process.exit(1);
}

const res = await fetch(`${URL}/auth/signin`, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ username: USERNAME, password: PASSWORD }),
});

const data = await res.json();
const token = data.accessToken ?? data.token ?? data.access_token;

if (!token) {
  console.error('could not find token in response:', data);
  process.exit(1);
}

console.log('access token fetched');
console.log(token);

// run the dispatch
console.log('dispatching daily questions...');
const dispatchRes = await fetch(`${URL}/daily-question/dispatch`, {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json',
  },
});
const dispatchData = await dispatchRes.json();
console.log('Done:', dispatchData);