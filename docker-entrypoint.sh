#!/bin/bash
set -e

# Wait for the database to be ready before continuing
echo "Waiting for database..."
until mysqladmin ping -h"${DB_HOST:-db}" -u"${DB_USER:-observium}" -p"${DB_PASSWORD:-observium}" --silent; do
    >&2 echo "Database is unavailable - sleeping"
    sleep 1
done
>&2 echo "Database is up - executing command"

# Run initial database setup/migration. This is safe to run on every start.
/opt/observium/discovery.php -u

# Create rrd and logs directories if they don't exist, and set permissions
mkdir -p /opt/observium/rrd /opt/observium/logs
chown -R www-data:www-data /opt/observium/rrd /opt/observium/logs

# Start cron
cron

# Start Apache in the foreground
exec apache2ctl -D FOREGROUND