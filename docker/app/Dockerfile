FROM azul/zulu-openjdk-debian:17 as base

WORKDIR /app

COPY .mvn/ .mvn
COPY mvnw pom.xml ./
RUN ./mvnw dependency:resolve
COPY src ./src

FROM base as development
CMD ["./mvnw", "spring-boot:run", "-Dspring-boot.run.jvmArguments='-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:8000'"]

FROM base as build
RUN ./mvnw package

FROM azul/zulu-openjdk-debian:17-jre as production
EXPOSE 8080
COPY --from=build /app/target/demo-*.jar /demo.jar
CMD ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "/demo.jar"]