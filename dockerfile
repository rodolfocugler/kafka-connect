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

# download kafka connect image
FROM confluentinc/cp-kafka-connect:6.0.0

COPY --from=builder ./kafka-connect-jdbc/  /usr/share/java/
