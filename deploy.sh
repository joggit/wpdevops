#!/usr/bin/env bash
# Deploy full WordPress site (theme + plugins from CI image): pull image and bring stack up.
# Use --backup to dump DB before deploy, --check to wait for the site to respond.
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

usage() {
  echo "Usage: $0 [OPTIONS]"
  echo "  Pull latest WordPress app image and run docker compose up."
  echo ""
  echo "Options:"
  echo "  --backup     Dump DB to ./backups/ before deploy (requires db container)."
  echo "  --check      After deploy, wait for site to return HTTP 200 (uses PORT from .env)."
  echo "  --dry-run    Print commands only, do not run."
  echo "  -h, --help   Show this help."
}

BACKUP=
CHECK=
DRY_RUN=

while [ $# -gt 0 ]; do
  case "$1" in
    --backup)   BACKUP=1 ;;
    --check)    CHECK=1 ;;
    --dry-run)  DRY_RUN=1 ;;
    -h|--help)  usage; exit 0 ;;
    *)          echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
  esac
  shift
done

run() {
  if [ -n "$DRY_RUN" ]; then
    echo "[dry-run] $*"
  else
    "$@"
  fi
}

if [ ! -f .env ]; then
  echo "Copy env.example to .env and set IMAGE (and PORT if using --check)." >&2
  exit 1
fi

# Load .env for PORT and image name
set -a
# shellcheck source=/dev/null
source .env
set +a

IMAGE_NAME="${IMAGE:-wordpress:latest}"
PORT="${PORT:-8080}"

if echo "$IMAGE_NAME" | grep -qE 'your-org|YOUR_GITHUB|REPLACE_WITH'; then
  echo "ERROR: Set IMAGE in .env to a real image." >&2
  echo "  Default: wordpress:latest (official from Docker Hub)" >&2
  echo "  Or your image: YOUR_DOCKERHUB_USER/wordpress-app:latest" >&2
  echo "For private images: docker login" >&2
  exit 1
fi

echo "Deploying WordPress site (theme + plugins from image): $IMAGE_NAME"

if [ -n "$BACKUP" ]; then
  BACKUP_DIR="$SCRIPT_DIR/backups"
  run mkdir -p "$BACKUP_DIR"
  STAMP=$(date +%Y%m%d-%H%M%S)
  BACKUP_FILE="$BACKUP_DIR/wp-${STAMP}.sql"
  echo "Backing up DB to $BACKUP_FILE"
  if [ -n "$DRY_RUN" ]; then
    echo "[dry-run] docker compose exec -T db mysqldump ... > $BACKUP_FILE"
  else
    docker compose exec -T db mysqldump -u"${WP_DB_USER:-wordpress}" -p"${WP_DB_PASSWORD:-wordpress}" "${WP_DB_NAME:-wordpress}" 2>/dev/null > "$BACKUP_FILE" || \
      docker compose exec -T db mysqldump -uroot -p"${MYSQL_ROOT_PASSWORD:-root}" "${WP_DB_NAME:-wordpress}" > "$BACKUP_FILE"
  fi
  echo "Backup done."
fi

echo "Pulling image..."
run docker compose pull wordpress
echo "Starting stack..."
run docker compose up -d

if [ -n "$CHECK" ]; then
  if [ -n "$DRY_RUN" ]; then
    echo "[dry-run] Would wait for http://127.0.0.1:${PORT}/ to return 200"
  else
    echo "Waiting for site at http://127.0.0.1:${PORT} ..."
    for i in $(seq 1 30); do
      if curl -sf -o /dev/null -w "%{http_code}" "http://127.0.0.1:${PORT}/" 2>/dev/null | grep -q 200; then
        echo "Site is up (HTTP 200)."
        break
      fi
      if [ $i -eq 30 ]; then
        echo "Timeout waiting for site. Check: docker compose logs wordpress" >&2
        exit 1
      fi
      sleep 2
    done
  fi
fi

echo "Done."
