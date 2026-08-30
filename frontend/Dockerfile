# syntax=docker/dockerfile:1

# ---------- Stage 1: build do SPA ----------
FROM node:22-alpine AS build
WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY . .
# O script "build" roda vue-tsc antes do vite build: erro de tipo quebra a imagem.
RUN npm run build

# ---------- Stage 2: Caddy serve o SPA e faz proxy da API ----------
FROM caddy:2-alpine
COPY --from=build /app/dist /srv
COPY Caddyfile /etc/caddy/Caddyfile
EXPOSE 80 443
