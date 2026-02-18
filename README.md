# wpdevops — Production deploy for WordPress app

Pull a WordPress image from **Docker Hub** and run it with MySQL. Use the **official** `wordpress:latest` image, or your own image (e.g. from the **wordpress** repo CI) that includes your theme and plugins.

## Flow

1. **Default:** Set `IMAGE=wordpress:latest` in `.env` to use the official WordPress image from Docker Hub (no login needed).
2. **Your own image:** Build and push from the wordpress repo (e.g. to Docker Hub as `YOUR_USER/wordpress-app:latest`). Set `IMAGE=YOUR_USER/wordpress-app:latest` in `.env`.
3. **This repo (wpdevops):** On the server, run `./deploy.sh` to pull the image and start the stack.

## Setup on production server

1. Clone or copy this repo to the server (e.g. `/opt/wpdevops`).

2. Create `.env` from the example:
   ```bash
   cp env.example .env
   ```
   Edit `.env`:
   - **IMAGE:** `wordpress:latest` (default; official image from Docker Hub) or `YOUR_DOCKERHUB_USER/wordpress-app:latest` for your own image.
   - **PORT:** Host port for the container (e.g. `9080`). Your nginx will proxy the domain to `http://127.0.0.1:9080`.
   - **WP_DB_*** / **MYSQL_ROOT_PASSWORD:** Set strong values. If you restore a DB dump from dev, use the same DB name/user/password as in the dump or update the dump.

3. First run (creates DB and starts WordPress):
   ```bash
   docker compose up -d
   ```
   Then configure WordPress (or import a DB dump from dev).

4. Point nginx at the app:
   - Proxy your domain to `http://127.0.0.1:${PORT}` (e.g. `http://127.0.0.1:9080`).

## Deploy updates (CI/CD)

After CI in the wordpress repo has built and pushed a new image:

```bash
./deploy.sh
```

Options:

| Option       | Description |
|-------------|-------------|
| `--backup`  | Dump the DB to `./backups/wp-YYYYMMDD-HHMMSS.sql` before pulling (safe rollback). |
| `--check`   | After deploy, wait for the site to return HTTP 200 on `http://127.0.0.1:${PORT}`. |
| `--dry-run` | Print commands only, do not pull or restart. |
| `-h`        | Show help. |

Examples:

```bash
./deploy.sh                    # Normal deploy
./deploy.sh --backup           # Backup DB, then deploy
./deploy.sh --backup --check   # Backup, deploy, then verify site is up
./deploy.sh --dry-run          # Show what would run
```

## Image (Docker Hub)

- **Official:** `IMAGE=wordpress:latest` — no login required; use for a plain WordPress site.
- **Your image:** `IMAGE=YOUR_DOCKERHUB_USER/wordpress-app:latest` — after your wordpress repo CI builds and pushes to Docker Hub. For private repos: `docker login` first.
- **Pin a tag:** e.g. `wordpress:6.4` or `YOUR_USER/wordpress-app:abc123` to avoid pulling `latest` every time.
