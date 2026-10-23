#Stage 1 Build the war file
FROM maven:3.9.9-eclipse-temurin-17 as builder
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DSkipTests
#Stage 2 Copy war fle to tomcat
FROM tomcat:10.1-jdk17-temurin
RUN rm -rf usr/local/tomcat/webapps/*
COPY --from=builder /app/target/vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war
EXPOSE 8080
CMD ["catalina.sh", "run"]
