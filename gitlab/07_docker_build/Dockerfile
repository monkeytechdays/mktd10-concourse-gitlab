FROM openjdk:8u222-jdk

RUN mkdir /app
COPY target/*.jar /app/
COPY target/dependency/*.jar /app/

EXPOSE 4567
CMD ["java", "-cp", "/app/*", "io.monkeypatch.mktd10.Main"]
