# Lightweight nginx with Flutter web app
FROM nginx:alpine

# Build arguments for version metadata
ARG APP_VERSION=unknown
ARG GIT_SHA=unknown
ARG BUILD_TIME=unknown

# Copy pre-built web app (built in CI and moved to web/)
COPY web /usr/share/nginx/html

# Copy custom nginx config template
# nginx:alpine's entrypoint processes templates from /etc/nginx/templates/ automatically
COPY docker/nginx.conf /etc/nginx/templates/default.conf.template

# Set default POCKETBASE_URL if not provided
ENV POCKETBASE_URL=http://pocketbase:8080

# Set version environment variables for nginx config
ENV APP_VERSION=${APP_VERSION} \
    GIT_SHA=${GIT_SHA} \
    BUILD_TIME=${BUILD_TIME}

EXPOSE 80
