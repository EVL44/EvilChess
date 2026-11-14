# Build stage
FROM eclipse-temurin:21-jdk AS build
WORKDIR /src
COPY gradlew settings.gradle.kts build.gradle.kts ./
COPY gradle gradle
RUN chmod +x gradlew && ./gradlew --no-daemon dependencies > /dev/null
COPY src src
RUN ./gradlew --no-daemon bootJar -x test

# Runtime stage
FROM eclipse-temurin:21-jre
WORKDIR /app
RUN useradd --system --uid 1001 evilchess
COPY --from=build /src/build/libs/*-SNAPSHOT.jar app.jar
USER evilchess
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
