# Stage 1: Build Flutter web app
FROM ubuntu:22.04 AS builder

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git -b stable /flutter
ENV PATH="/flutter/bin:${PATH}"

# Enable web
RUN flutter config --enable-web
RUN flutter doctor

# Copy app source
WORKDIR /app
COPY pubspec.* ./
RUN flutter pub get

COPY . .

# Build web app
RUN flutter build web --release --web-renderer canvaskit

# Stage 2: Serve with Nginx
FROM nginx:alpine

# Copy built web app
COPY --from=builder /app/build/web /usr/share/nginx/html

# Copy custom nginx config if needed
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
