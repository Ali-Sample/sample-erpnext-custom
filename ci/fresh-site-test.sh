#!/usr/bin/env bash
# Fresh-site test: throwaway MariaDB + Redis, a new site with ERPNext + this app, then the app's tests.
# Same script locally and in CI. Usage: ci/fresh-site-test.sh <image>
set -euo pipefail

IMAGE=${1:?usage: ci/fresh-site-test.sh <image>}
# Same versions as erpnext-local/versions.env and RHOS CI.
MARIADB_IMAGE=mariadb:11.8@sha256:75b300c790eec33cd4386d80fc1a938e27604ba70f3eeda25e52874be2aae424
REDIS_IMAGE=redis:7.4@sha256:a6dd428750118c2c2c67d3f555faef0aa15a2b71198b40e1cb3b9229b1cf3094
NET=fresh-site-$$
DB_ROOT_PASSWORD=$(openssl rand -hex 12)   # throwaway, dies with the container

cleanup() {
	docker rm -f "$NET-db" "$NET-redis" >/dev/null 2>&1 || true
	docker network rm "$NET" >/dev/null 2>&1 || true
}
trap cleanup EXIT

docker network create "$NET" >/dev/null
docker run -d --name "$NET-db" --network "$NET" -e MARIADB_ROOT_PASSWORD="$DB_ROOT_PASSWORD" \
	--health-cmd "healthcheck.sh --connect --innodb_initialized" --health-interval 5s "$MARIADB_IMAGE" >/dev/null
docker run -d --name "$NET-redis" --network "$NET" "$REDIS_IMAGE" >/dev/null

for _ in $(seq 60); do
	[ "$(docker inspect -f '{{.State.Health.Status}}' "$NET-db")" = healthy ] && break
	sleep 3
done

docker run --rm --network "$NET" -e NET="$NET" -e DB_ROOT_PASSWORD="$DB_ROOT_PASSWORD" "$IMAGE" bash -c '
	set -euo pipefail
	bench set-config -g db_host "$NET-db"
	bench set-config -g redis_cache "redis://$NET-redis:6379"
	bench set-config -g redis_queue "redis://$NET-redis:6379"
	bench set-config -g redis_socketio "redis://$NET-redis:6379"
	bench new-site test.localhost --mariadb-user-host-login-scope=% \
		--db-root-username root --db-root-password "$DB_ROOT_PASSWORD" --admin-password admin \
		--install-app erpnext --install-app sample_erpnext_custom
	bench --site test.localhost set-config allow_tests true
	bench --site test.localhost run-tests --app sample_erpnext_custom
'
