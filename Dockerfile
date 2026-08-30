# syntax=docker/dockerfile:1

# ---------- Stage 1: build do fat jar ----------
FROM eclipse-temurin:21-jdk AS build
WORKDIR /app

# Wrapper e arquivos de build primeiro: essa camada só é invalidada
# quando as dependências mudam, o que deixa rebuilds bem mais rápidos.
COPY gradlew settings.gradle build.gradle ./
COPY gradle ./gradle
RUN sed -i 's/\r$//' gradlew && chmod +x gradlew \
    && ./gradlew --no-daemon dependencies --quiet || true

COPY src ./src
RUN ./gradlew --no-daemon clean bootJar -x test

# ---------- Stage 2: runtime ----------
FROM eclipse-temurin:21-jre
WORKDIR /app

RUN groupadd --system farm && useradd --system --gid farm farm
COPY --from=build /app/build/libs/*.jar app.jar
RUN chown farm:farm app.jar
USER farm

EXPOSE 8080
ENTRYPOINT ["java", "-XX:MaxRAMPercentage=75", "-jar", "/app/app.jar"]
