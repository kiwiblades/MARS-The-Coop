# The Coop

## Overview (WIP)
TODO: add some nice descriptive one-liner here about The Coop
- **Frontend:** Flutter/Dart
- **Backend:** Node.js + Express
- **Database:** PostgreSQL (via Docker)

Repo structure:
- `frontend/` Flutter app
- `backend/` Express API server
- `compose.yaml` Docker Compose for PostgreSQL

## Prerequisites

Install these before running the project:

### Backend + Database
- Node.js + npm
- Docker Desktop (required for PostgreSQL)

### Frontend
- Flutter SDK
- Android Studio (for the Android emulator)

Optional but helpful:
- VS Code Flutter + Dart extensions

## First-time setup

### 1) Clone repo + start the database
From the project root:

```bash
docker compose up -d
docker compose ps
```

> Docker will automatically download/pull the Postgres image the first time you run this. Much easier than last time.

To stop containers later:
```bash
docker compose down
```

### 2) Backend setup

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

### 3) Frontend setup

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

Install Flutter packages:
```bash
flutter pub get
```

You should also verify Flutter is aware of the Android SDK, and verify you have accepted any Android Studio licenses:
```bash
flutter doctor
```
If this command produces any errors, follow the output to correct them. Mainly, verify 'Android toolchain' is marked with a green check.

---

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
- Make sure Docker is running (`docker compose ps`).
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
- Run `docker compose ps` and ensure the Postgres container is healthy (look under status).
- Restart containers: `docker compose down` then `docker compose up -d`.
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
- `docker compose up -d` -> starts all docker services in background
- `docker compose ps` -> displays all running docker containers + their status
- `docker compose logs -f postgres` -> real-time docker log display in terminal for troubleshooting
- `docker compose down` -> stops containers but keeps database volume (persists data)
- `docker compose down -v` -> stops containers **and deletes volumes** (full reset)