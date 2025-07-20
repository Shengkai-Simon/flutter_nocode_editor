# Phase 1: Use a clear version of the community mirror with a clear source
FROM ghcr.io/cirruslabs/flutter:3.32.0 AS build

# WORKDIR & COPY
WORKDIR /app
COPY . .

# Run the Flutter Doctor validation environment
RUN flutter doctor -v

# Install project dependencies
RUN flutter pub get

# Build the web app as a release version
RUN flutter build web --release --base-href /flutter/

# --------------------------------------------------------------------------

# Phase 2: Build the static file with Nginx hosting
FROM nginx:alpine

# Copy the files you built in phase 1
COPY --from=build /app/build/web /usr/share/nginx/html/flutter

# Copy the Nginx configuration file
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Container exposes port 8082
EXPOSE 8082