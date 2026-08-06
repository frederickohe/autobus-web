# Stage 1: Build Flutter web
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .

# Inject production env at build time (flutter_dotenv bundles .env as an asset)
# PUBLIC_WEBHOOK_API_KEY must match backend PUBLIC_WEBHOOK_API_KEY (X-Api-Key for public chat).
ARG BACKEND_URL
ARG PAYSTACK_PUBLIC_KEY=""
ARG PAYSTACK_CALLBACK_URL=""
ARG PUBLIC_WEBHOOK_API_KEY=""
RUN printf "BACKEND_URL=%s\nPAYSTACK_PUBLIC_KEY=%s\nPAYSTACK_CALLBACK_URL=%s\nPUBLIC_WEBHOOK_API_KEY=%s\n" \
    "$BACKEND_URL" "$PAYSTACK_PUBLIC_KEY" "$PAYSTACK_CALLBACK_URL" "$PUBLIC_WEBHOOK_API_KEY" > .env

RUN flutter build web --release

# Stage 2: Serve with nginx
FROM nginx:alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]