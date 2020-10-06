FROM ubuntu:20.04 AS builder

# install unzip
# install curl
RUN apt-get update && \
    apt-get install -y unzip=6.0-25ubuntu1 && \
    apt-get install -y curl

# create kafka-connect-jdbc folder
RUN mkdir ./kafka-connect-jdbc/

# download kafka-connect-jdbc
ENV KAFKA_CONNECT_JDBC_VERSION 5.5.2
RUN curl -o confluentinc-kafka-connect-jdbc-${KAFKA_CONNECT_JDBC_VERSION}.zip "https://d1i4a15mxbxib1.cloudfront.net/api/plugins/confluentinc/kafka-connect-jdbc/versions/${KAFKA_CONNECT_JDBC_VERSION}/confluentinc-kafka-connect-jdbc-${KAFKA_CONNECT_JDBC_VERSION}.zip" && \
    unzip confluentinc-kafka-connect-jdbc-${KAFKA_CONNECT_JDBC_VERSION}.zip -d ./kafka-connect-jdbc/

# download mysql connector
ENV MYSQL_CONNECTOR_JAVA_VERSION 8.0.21
RUN curl -k -SL "https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MYSQL_CONNECTOR_JAVA_VERSION}.tar.gz" | tar -xzf - -C ./kafka-connect-jdbc/ --strip-components=1 mysql-connector-java-$MYSQL_CONNECTOR_JAVA_VERSION/mysql-connector-java-$MYSQL_CONNECTOR_JAVA_VERSION.jar

# download castorm-kafka-connect-http
ENV KAFKA_CONNECT_HTTP_VERSION 0.7.6
RUN curl -o castorm-kafka-connect-http-${KAFKA_CONNECT_HTTP_VERSION}.zip "https://d1i4a15mxbxib1.cloudfront.net/api/plugins/castorm/kafka-connect-http/versions/${KAFKA_CONNECT_HTTP_VERSION}/castorm-kafka-connect-http-${KAFKA_CONNECT_HTTP_VERSION}.zip" && \
    unzip castorm-kafka-connect-http-${KAFKA_CONNECT_HTTP_VERSION}.zip -d ./castorm-kafka-connect-http/

# download kafka connect image
FROM confluentinc/cp-kafka-connect:6.0.0

COPY --from=builder ./kafka-connect-jdbc/ /usr/share/java/
COPY --from=builder ./castorm-kafka-connect-http/ /usr/share/java/
