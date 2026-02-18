# wpdevops — Production deploy for WordPress app

Pull a WordPress image from **Docker Hub** and run it with MySQL. Use the **official** `wordpress:latest` image, or your own image (e.g. from the **wordpress** repo CI) that includes your theme and plugins.

## Flow

1. **Build (from wpdevops):** Use **Actions → Build and push WordPress image → Run workflow**. Enter your **WordPress repo** (e.g. `myorg/wordpress`). The workflow checks out that repo, builds the image, and pushes to GHCR and Docker Hub (if `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` secrets are set).
2. **Run on production:** Set `IMAGE=YOUR_DOCKERHUB_USER/wordpress-app:latest` in `.env`, then on the server run `./deploy.sh` to pull and start the stack.

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

## Build and push image (wpdevops workflow)

This repo is the single place for both the app and the pipeline: put your **theme** in `theme/`, **plugins** in `plugins/`, and the workflow builds the image from here.

1. In the **wpdevops** repo on GitHub go to **Actions**.
2. Click **Build and push WordPress image** in the left sidebar.
3. Click **Run workflow** (right side).
4. Optionally set **Theme slug** (must match the folder name under `theme/`; default is `wordpress-starter`). If your theme lives in a subfolder like `theme/seese/`, use `seese`.
5. Leave **Also push to Docker Hub** checked if you use Docker Hub (and have set `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` under **Settings → Secrets and variables → Actions**).
6. Click the green **Run workflow**.

The workflow checks out wpdevops, builds the Docker image from `Dockerfile` + `theme/` + `plugins/`, and pushes to GitHub Container Registry and to Docker Hub.

**If GHCR push fails with “installation not allowed to Create organization package”:** Your org may block the default token from creating packages. Fix it in one of these ways: (1) **Use a PAT for GHCR:** Create a Personal Access Token (GitHub → Settings → Developer settings → Personal access tokens) with `write:packages`, add it as a repo secret named **GHCR_TOKEN**. The workflow will use it to push to GHCR. (2) **Ask an org admin** to allow workflow packages: Organization → Settings → Actions → General → Workflow permissions, and ensure Packages allow creation. (3) **Use only Docker Hub:** If you only need the image on Docker Hub, you can ignore the GHCR error as long as the “Push to Docker Hub” step runs after; set `IMAGE=YOUR_DOCKERHUB_USER/wordpress-app:latest` on the server.

## Deploy updates (CI/CD)

After the workflow above (or any CI) has built and pushed a new image:

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
