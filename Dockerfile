# Lightweight nginx with Flutter web app
FROM nginx:alpine

# Remove default nginx config
RUN rm /etc/nginx/conf.d/default.conf

# Copy pre-built web app (built in CI and moved to web/)
COPY web /usr/share/nginx/html

# Copy custom nginx config template
COPY docker/nginx.conf /etc/nginx/templates/default.conf.template

# Set default POCKETBASE_URL if not provided
ENV POCKETBASE_URL=http://pocketbase:8080

EXPOSE 80

# nginx:alpine automatically processes templates in /etc/nginx/templates/
CMD ["nginx", "-g", "daemon off;"]
