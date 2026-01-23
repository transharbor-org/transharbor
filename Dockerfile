# Lightweight nginx with Flutter web app
FROM nginx:alpine

# Copy pre-built web app (built in CI and moved to web/)
COPY web /usr/share/nginx/html

# Copy custom nginx config template
# nginx:alpine's entrypoint processes templates from /etc/nginx/templates/ automatically
COPY docker/nginx.conf /etc/nginx/templates/default.conf.template

# Set default POCKETBASE_URL if not provided
ENV POCKETBASE_URL=http://pocketbase:8080

EXPOSE 80
