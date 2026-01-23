# Stage 1: Serve pre-built Flutter web app with Nginx
FROM nginx:alpine

# Copy pre-built web app (built in CI)
COPY build/web /usr/share/nginx/html

# Copy custom nginx config
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
