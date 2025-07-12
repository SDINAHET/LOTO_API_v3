# Étape 1: Build avec Maven
FROM maven:3.9.6-eclipse-temurin-21 as builder
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

# Étape 2: Runtime
FROM eclipse-temurin:21-jre-jammy
WORKDIR /app

# Installation des dépendances système
RUN apt-get update && apt-get install -y \
    postgresql-client \
    mongodb-clients \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Installation des dépendances Python
COPY requirements.txt .
RUN pip3 install -r requirements.txt

# Copie des fichiers nécessaires
COPY --from=builder /app/target/*.jar app.jar
COPY src/main/resources/db/migration /app/db/migration
COPY .env.example .env

# Configuration des variables d'environnement
ENV SPRING_PROFILES_ACTIVE=prod
ENV SERVER_PORT=8082
ENV TZ=Europe/Paris

# Exposition du port
EXPOSE 8082

# Script de démarrage
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["java", "-jar", "app.jar"]
