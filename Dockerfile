# Use latest stable channel SDK.
FROM dart:stable AS build

# Resolve app dependencies.
WORKDIR /app
COPY pubspec.* ./
RUN dart pub get

# Copy app source code (except anything in .dockerignore) and AOT compile app.
COPY . .
RUN dart compile exe bin/xlinecargo.dart -o bin/server

# Build minimal serving image from AOT-compiled `/server`
# and the pre-built AOT-runtime in the `/runtime/` directory of the base image.
FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /app/bin/server /app/bin/

# Copy swagger files if they are needed at runtime
COPY --from=build /app/lib/swagger /app/lib/swagger
COPY --from=build /app/lib/admin_panel /app/lib/admin_panel

# Start server.
EXPOSE 8080
CMD ["/app/bin/server"]
