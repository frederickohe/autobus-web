# Stage 1: Build Flutter web
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .

# Inject production env at build time (flutter_dotenv bundles .env as an asset)
ARG BACKEND_URL
ARG PAYSTACK_PUBLIC_KEY=""
ARG PAYSTACK_CALLBACK_URL=""
RUN printf "BACKEND_URL=%s\nPAYSTACK_PUBLIC_KEY=%s\nPAYSTACK_CALLBACK_URL=%s\n" \
    "$BACKEND_URL" "$PAYSTACK_PUBLIC_KEY" "$PAYSTACK_CALLBACK_URL" > .env

RUN flutter build web --release

# Stage 2: Serve with nginx
FROM nginx:alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]