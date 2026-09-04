##!/bin/bash
## Sobe o Spring Boot e so entao expoe o Caddy na porta publica.
##
## Isso importa em serverless: a plataforma considera o container "pronto"
## assim que algo escuta em $PORT. Se o Caddy subisse antes do Spring, a
## primeira requisicao depois de um cold start levaria 502.
#set -euo pipefail
#
#APP_PORT="${SERVER_PORT:-8081}"
#BOOT_TIMEOUT="${BOOT_TIMEOUT:-120}"
#
#java -XX:MaxRAMPercentage=70 -XX:+UseSerialGC -Xss512k \
#     -Djava.security.egd=file:/dev/./urandom \
#     -jar /app/app.jar &
#JAVA_PID=$!
#
#echo "[entrypoint] aguardando o Spring em 127.0.0.1:${APP_PORT}..."
#for i in $(seq 1 "$BOOT_TIMEOUT"); do
#    if ! kill -0 "$JAVA_PID" 2>/dev/null; then
#        echo "[entrypoint] ERRO: o Spring morreu durante o boot" >&2
#        wait "$JAVA_PID" || exit $?
#        exit 1
#    fi
#    if (echo > "/dev/tcp/127.0.0.1/${APP_PORT}") 2>/dev/null; then
#        echo "[entrypoint] Spring pronto em ${i}s; subindo o Caddy na porta ${PORT:-8080}"
#        exec caddy run --config /etc/caddy/Caddyfile
#    fi
#    sleep 1
#done
#
#echo "[entrypoint] ERRO: Spring nao respondeu em ${BOOT_TIMEOUT}s" >&2
#kill "$JAVA_PID" 2>/dev/null || true
#exit 1
