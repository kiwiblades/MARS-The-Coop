# The Coop

## Overview
***a mobile app to cultivate human connection***

- **Frontend:** Flutter/Dart
- **Backend:** Node.js + Express
- **Database:** PostgreSQL (via Docker)

Repo structure:
- `frontend/` Flutter app
- `backend/` Express API server
- `compose.yaml` Docker Compose for PostgreSQL

## Prerequisites

Install these or verify you have them installed before running the project:

### Backend + Database
- Node.js + npm
    - https://nodejs.org/en/download/current
- Docker Desktop (required for PostgreSQL)
    - https://www.docker.com/products/docker-desktop/

### Frontend
- Flutter SDK
    - https://docs.flutter.dev/install
- Android Studio (for the Android emulator)
    - https://developer.android.com/studio

## First-time setup

### 1) Backend setup

From the project root:
```bash
cd backend
```

Create the backend env file:
- Mac/Linux:
    ```bash
    cp .env.example .env
    ```
- Windows (PowerShell):
    ```bash
    Copy-Item .env.example .env
    ```
- Or use a GUI file-manager.

Install backend dependencies:
```bash
npm install
```

> [!NOTE]
> You may need to repeat `npm install` after pulling new changes. Dependencies may change over time.

### 2) Frontend setup

From the project root:
```bash
cd frontend
```

Create the frontend env file:
- Mac/Linux:
    ```bash
    cp .env.example .env
    ```
- Windows (PowerShell):
    ```bash
    Copy-Item .env.example .env
    ```
- Or use a GUI file-manager.

If you already had Flutter SDK installed prior to project setup, make sure it's up to date:
```bash
flutter upgrade
```

Install Flutter packages:
```bash
flutter pub get
```

You should also verify Flutter is aware of the Android SDK, and verify you have accepted any Android Studio licenses:
```bash
flutter doctor
```
If this command produces any errors, follow the output to correct them. Mainly, verify 'Android toolchain' is marked with a green check.

### 3) Database setup

From the project root:

```bash
docker compose --env-file backend/.env up -d
docker compose --env-file backend/.env ps
```

> Docker will automatically download/pull the Postgres image the first time you run this. Much easier than last time.

## Running the project

### 1) Start backend (Express)

From the project root:
```bash
cd backend
npm run dev
```

You should see a startup log showing the server port:
```bash
Server running on port 5000
```

#### Verify backend + database connectivity
Open a browser to:
- `http://127.0.0.1:5000/health/db`
You should see JSON like `{ ok: true, ... }`.

If it fails:
- Make sure Docker is running (`docker compose --env-file backend/.env ps`).
- Make sure `backend/.env` exists and is correct.
- Make sure the backend server is running.
- (Optional) Contact Rye and complain.

### 2) Run frontend (Flutter)

#### Start an Android emulator
- Open Android Studio -> Device Manager -> Start an emulator

Confirm Flutter sees a device:
```bash
flutter devices
```

Run the app:
```bash
cd frontend
flutter run
```

## Environment config notes

### Android emulator networking

When running the backend on your computer:
- Your computer sees it as `http://localhost:5000`
- The Android emulator sees it as `http://10.0.2.2:5000`

This is why `frontend/.env` uses `10.0.2.2` by default. If all else fails, use the default values in both `.env.example` files.

If for some reason you run Flutter Web, use `http://localhost:5000`.

### Security concerns

Note that `backend/.env` and `frontend/.env` exist separately. Any keys or sensitive values should go in `backend/.env` because `frontend/` contains the Flutter app. The build can be deconstructed to reproduce any values in `frontend/.env`. Therefore, it's not safe for sensitive information to be stored there. Use it only for convenience and consistency (URLs, ports, etc). This may not be a concern in a small-scale project, but it's good to exercise safe security practices regardless.

## Troubleshooting

### "Stuck on Flutter logo" or app never loads
- Make sure `frontend/.env` exists.
- Make sure `.env` is listed as an asset in `frontend/pubspec.yaml` (it should be, by default).
- Run `flutter pub get` again and hot restart ('R' in terminal).

### Backend works in browser, but Flutter can't connect
- Confirm `API_BASE_URL` in `frontend/.env` is http://10.0.2.2:5000 for Android emulator.
- Check that `SV_PORT` in `backend/.env` matches the port in this URL.

### Database healthcheck fails
- Run `docker compose --env-file backend/.env ps` and ensure the Postgres container is healthy (look under status).
- Restart containers: `docker compose down` then `docker compose --env-file backend/.env up -d`.
- Restart the backend server: `npm run dev`, then check the endpoint again.
- If it's still not working, open Docker Desktop, navigate to this project's container, then open logs. At the far right, there is a "copy to clipboard" option; do this and send to Rye.

## Commands

### Frontend
Run these from `frontend/`

- `flutter pub get` -> installs/updates package dependencies
- `flutter run` -> builds and runs the app on connected device/emulator
- `flutter devices` -> lists all available devices (to confirm emulator is detected)
- `flutter clean` -> clears build artifacts
- `flutter analyze` -> runs dart/flutter static analysis to catch common issues
- `dart format .` -> formats dart code in the project

### Backend
Run these from `backend/`

- `npm run dev` -> starts the backend server in development mode (w/ hot reload)
- `npm run lint` -> runs eslint to report style issues and potential bugs (doesn't change files)
- `npm run lint:fix` -> runs eslint and automatically fixes what it can (safe for formatting fixes; review changes)
- `npm run format` -> runs prettier to format code consistently across the backend
- `npm run db:migrate` -> applies database migrations to bring your local schema up to date
- `npm run db:rollback` -> rolls back the **most recent** migration (useful if a migration was wrong or you need to undo a schema change)

### Database
- `docker compose --env-file backend/.env up -d` -> starts all docker services in background using backend .env values
- `docker compose --env-file backend/.env ps` -> displays all running docker containers + their status
- `docker compose logs -f postgres` -> real-time docker log display in terminal for troubleshooting
- `docker compose down` -> stops containers but keeps database volume (persists data)
- `docker compose down -v` -> stops containers **and deletes volumes** (full reset)

## Tools

### pgAdmin 4
This is a GUI tool for the postgreSQL database. Because the database exists in Docker, you must specify some connection details to connect it to the GUI interface.

In the "Default Workspace" section, right click on the "Servers" drop-down and register a new connection. Give it any name you'd like (e.g., "Docker (coop)"), then move to the "Connection" tab.

This depends on the setup of your database values in .env, so fill in the values corresponding to your .env values, if differing from .env.example.
- Host name/address: 127.0.0.1 OR localhost
- Port: `PGPORT` (e.g., 5433)
- Username: `PGUSER` (e.g., postgres)
- Password: `PGPASSWORD` (e.g., postgres). You can toggle save password for convenience.

Everything else can be left as default. Register the server.

The named server should now appear under "Servers". Expand the server, and under "Databases" you should see your existing database with the same name as `PGDATABASE` (e.g., the_coop).

Right click the database and select "Query Tool". This brings up a text box where you can type and run queries. To run a query, highlight the text and hit `F5`.

Example queries:
- `select * from public."user";` -> user is a meta table in postgres, so reference our user table as public."user"
- `select * from public."user" where email='thecoopmobileapp@gmail.com';`
- `select * from chatmembership join chatroom on chatmembership."chatId"=chatroom.id;` -> reference fields with mixed casing using double quotes; e.g., chatmembership."chatId", select "emailVerified" from ...

### Postman
This is an API platform tester, providing an interface to test API endpoints (essentially a GUI tool for curl). This allows you to test edge cases on endpoints you wouldn't be able to access through the application interface. For example, attempting to delete a chatroom as a user who is not the owner. You can evaluate both the returned json and the expanded details printed in your terminal running the backend server.

You can access the current collection here: `https://kiwiblades-3762189.postman.co/workspace/Rye's-Workspace~f49e809d-fb08-4c0b-87ef-8e62851ca9a0/collection/52479941-fe82afae-21ab-4fde-9159-36379689f94a?action=share&creator=52479941`

You can follow a similar format to the endpoints in the collection to create your own, or contact Rye to add more. For most endpoints, they require a json body, and if protected, they require the accessToken pasted into the "Authorization" tab.

Click on a request and check the "Docs" section for details about the information needed on the request. Switch to the "Body" tab, choose "raw" and "JSON", and specify the needed parameters as indicated in the docs.

To access protected endpoints, you can first run the "SIGNIN" request, which outputs refreshToken, accessToken, and UID. Copy the accessToken and navigate to a protected request. Choose the "Authorization" tab, and set Auth Type to "Bearer Token". Add the accessToken into the field, then you should be able to send the request. The accessToken also indicates which signed-in user the request is being called for. If you want to test with multiple users at once, you can sign in another user and copy their accessToken as well. If the accessToken expires, you can either hit the signin endpoint again or generate a new access token in "REFRESH".

For convenience, you can increase or decrease the expiration time of the access and refresh tokens by specifying their lifespan in your .env. The time formats supported are minutes (e.g., "15m"), hours (e.g., "1h"), and days (e.g., "30d").