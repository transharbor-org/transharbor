#!/bin/sh
set -e

# Substitute environment variables in nginx config
envsubst '${POCKETBASE_URL}' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf

# Start nginx
exec nginx -g 'daemon off;'
