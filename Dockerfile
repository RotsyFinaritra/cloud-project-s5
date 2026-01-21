# Use pre-built WAR file from local target directory
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Install curl for healthcheck
RUN apk add --no-cache curl

# Copy the pre-compiled WAR file from local target directory
COPY target/*.war app.war

EXPOSE 8080

HEALTHCHECK --interval=10s --timeout=3s --retries=5 CMD curl -f http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["java", "-jar", "app.war"]
