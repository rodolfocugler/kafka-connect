FROM ubuntu:18.04 AS builder

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# install unzip
# install curl
RUN apt-get update && \
    apt-get install -y \
    unzip \
    curl

# create kafka-connect-jdbc folder
RUN mkdir ./kafka-connect-jdbc/

# download kafka-connect-jdbc
ENV KAFKA_CONNECT_JDBC_VERSION 5.5.2
RUN curl -o confluentinc-kafka-connect-jdbc-${KAFKA_CONNECT_JDBC_VERSION}.zip "https://d1i4a15mxbxib1.cloudfront.net/api/plugins/confluentinc/kafka-connect-jdbc/versions/${KAFKA_CONNECT_JDBC_VERSION}/confluentinc-kafka-connect-jdbc-${KAFKA_CONNECT_JDBC_VERSION}.zip" && \
    unzip confluentinc-kafka-connect-jdbc-${KAFKA_CONNECT_JDBC_VERSION}.zip -d ./kafka-connect-jdbc/

ENV KAFKA_CONNECT_MONGODB_SOURCE_VERSION 1.3.0
RUN curl -o mongodb-kafka-connect-mongodb-${KAFKA_CONNECT_JDBC_VERSION}.zip "https://d1i4a15mxbxib1.cloudfront.net/api/plugins/mongodb/kafka-connect-mongodb/versions/${KAFKA_CONNECT_MONGODB_SOURCE_VERSION}/mongodb-kafka-connect-mongodb-${KAFKA_CONNECT_MONGODB_SOURCE_VERSION}.zip" && \
    unzip mongodb-kafka-connect-mongodb-${KAFKA_CONNECT_JDBC_VERSION}.zip -d ./mongodb-kafka-connect-mongodb/

# download mysql connector
ENV MYSQL_CONNECTOR_JAVA_VERSION 8.0.21
RUN curl -k -SL "https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MYSQL_CONNECTOR_JAVA_VERSION}.tar.gz" | tar -xzf - -C ./kafka-connect-jdbc/confluentinc-kafka-connect-jdbc-${KAFKA_CONNECT_JDBC_VERSION}/lib/ --strip-components=1 mysql-connector-java-$MYSQL_CONNECTOR_JAVA_VERSION/mysql-connector-java-$MYSQL_CONNECTOR_JAVA_VERSION.jar

# download castorm-kafka-connect-http
ENV KAFKA_CONNECT_HTTP_VERSION 0.7.7-0.1.0
RUN curl -o html "https://github.com/finance-br/kafka-connect-http/packages/444469?version=${KAFKA_CONNECT_HTTP_VERSION}" && \
    link=$(cat html | grep -oh "https://github-registry-files.githubusercontent.com.*kafka-connect-http-${KAFKA_CONNECT_HTTP_VERSION}.zip.*stream") && \
    curl -o castorm-kafka-connect-http-${KAFKA_CONNECT_HTTP_VERSION}.zip "${link//amp;/}" && \
    rm html && \
    mkdir castorm-kafka-connect-http && \
    unzip castorm-kafka-connect-http-${KAFKA_CONNECT_HTTP_VERSION}.zip -d ./castorm-kafka-connect-http/castorm-kafka-connect-http-${KAFKA_CONNECT_HTTP_VERSION}

# download hpgrahsl-kafka-connect-mongodb
ENV KAFKA_CONNECT_MONGODB_SINK_VERSION 1.4.0-0.1.1
RUN curl -o html "https://github.com/rodolfocugler/kafka-connect-mongodb/packages/480276?version=${KAFKA_CONNECT_MONGODB_SINK_VERSION}" && \
    link=$(cat html | grep -oh "https://github-registry-files.githubusercontent.com.*kafka-connect-mongodb-${KAFKA_CONNECT_MONGODB_SINK_VERSION}.zip.*stream") && \
    curl -o hpgrahsl-kafka-connect-mongodb-${KAFKA_CONNECT_MONGODB_SINK_VERSION}.zip "${link//amp;/}" && \
    rm html && \
    mkdir hpgrahsl-kafka-connect-mongodb && \
    unzip hpgrahsl-kafka-connect-mongodb-${KAFKA_CONNECT_MONGODB_SINK_VERSION}.zip -d ./hpgrahsl-kafka-connect-mongodb/hpgrahsl-kafka-connect-mongodb-${KAFKA_CONNECT_MONGODB_SINK_VERSION}

# download kafka connect image
FROM confluentinc/cp-kafka-connect:6.1.0

COPY --from=builder ./kafka-connect-jdbc/ /usr/share/java/
COPY --from=builder ./castorm-kafka-connect-http/ /usr/share/java/
COPY --from=builder ./hpgrahsl-kafka-connect-mongodb/ /usr/share/java/
COPY --from=builder ./mongodb-kafka-connect-mongodb/ /usr/share/java/
