#!/bin/bash
set -e

CONFIG_PATH="${WARPGATE_CONFIG:-/data/warpgate.yaml}"

# If config already exists, skip setup and just run
if [ -f "$CONFIG_PATH" ]; then
    exec warpgate "$@"
fi

echo "==> No config found at $CONFIG_PATH"
echo "==> Running first-time unattended setup..."

# Build the unattended-setup command
ARGS=(
    "unattended-setup"
    "--data-path" "/data"
    "--http-port" "${WARPGATE_HTTP_PORT:-8888}"
)

# Enable session recording only if explicitly set to "true"
if [ "${WARPGATE_RECORD_SESSIONS}" = "true" ]; then
    ARGS+=(--record-sessions)
fi

# Optional Protocols
[ -n "$WARPGATE_SSH_PORT" ]        && ARGS+=(--ssh-port "$WARPGATE_SSH_PORT")
[ -n "$WARPGATE_MYSQL_PORT" ]      && ARGS+=(--mysql-port "$WARPGATE_MYSQL_PORT")
[ -n "$WARPGATE_POSTGRES_PORT" ]   && ARGS+=(--postgres-port "$WARPGATE_POSTGRES_PORT")
[ -n "$WARPGATE_KUBERNETES_PORT" ] && ARGS+=(--kubernetes-port "$WARPGATE_KUBERNETES_PORT")

# Optional settings
[ -n "$WARPGATE_EXTERNAL_HOST" ]  && ARGS+=(--external-host "$WARPGATE_EXTERNAL_HOST")
[ -n "$WARPGATE_DATABASE_URL" ]   && ARGS+=(--database-url "$WARPGATE_DATABASE_URL")

# Admin password is required for first-time setup
if [ -n "$WARPGATE_ADMIN_PASSWORD" ]; then
    ARGS+=(--admin-password "$WARPGATE_ADMIN_PASSWORD")
else
    echo "====================================================================="
    echo "  ERROR: WARPGATE_ADMIN_PASSWORD environment variable is not set."
    echo ""
    echo "  For security, you must set a password for the admin user."
    echo "  Example:"
    echo "    docker run -e WARPGATE_ADMIN_PASSWORD=mysecretpass ..."
    echo "====================================================================="
    exit 1
fi

warpgate "${ARGS[@]}"

echo "==> Setup complete. Starting Warpgate..."
exec warpgate "$@"