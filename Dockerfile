# 1️⃣ Build stage
FROM gradle:8.7-jdk17 AS builder

WORKDIR /workspace

# Copy everything at once
COPY . .

# Make Gradle wrapper executable
RUN chmod +x gradlew

# Build directly
RUN ./gradlew clean :transfer:transfer-00-prerequisites:connector:build \
    --no-daemon \
    --stacktrace \
    --info

# 2️⃣ Runtime stage
FROM eclipse-temurin:17-jre

WORKDIR /app

COPY --from=builder \
     /workspace/transfer/transfer-00-prerequisites/connector/build/libs/connector.jar \
     ./connector.jar

COPY transfer/transfer-00-prerequisites/resources/configuration/provider-configuration.properties \
     ./provider.properties

EXPOSE 19193

ENTRYPOINT ["java", "-Dedc.fs.config=/app/provider.properties", "-jar", "connector.jar"]