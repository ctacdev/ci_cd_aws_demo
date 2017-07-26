FROM openjdk:8u131-jre

COPY *.class /

EXPOSE 8080

CMD java Server