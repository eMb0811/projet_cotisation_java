# Multi-stage build pour l'application Jakarta EE 10 UCAD Cotisations

# Étape 1 : Compilation et packaging avec Maven & JDK 17
FROM maven:3.9.6-eclipse-temurin-17 AS builder
WORKDIR /build

# Copier les fichiers du projet
COPY pom.xml .
COPY src ./src

# Compiler et packager le livrable WAR
RUN mvn clean package -DskipTests

# Étape 2 : Déploiement sur Apache Tomcat 10.1 (Jakarta EE 10 / Servlet 6.0)
FROM tomcat:10.1-jdk17-temurin

# Nettoyer les applications par défaut de Tomcat
RUN rm -rf /usr/local/tomcat/webapps/*

# Déployer l'application en tant que ROOT (accès direct sur /) et cotisations-app (/cotisations-app)
COPY --from=builder /build/target/cotisations-app.war /usr/local/tomcat/webapps/ROOT.war
COPY --from=builder /build/target/cotisations-app.war /usr/local/tomcat/webapps/cotisations-app.war

# Exposer le port HTTP standard de Tomcat
EXPOSE 8080

# Lancer Tomcat
CMD ["catalina.sh", "run"]
