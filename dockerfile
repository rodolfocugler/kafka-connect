FROM ubuntu:20.04 AS builder

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG GIT_PERSONAL_USERNAME
ARG GIT_PERSONAL_TOKEN

# install libxml2-utils
# install unzip
# install curl
# install ca-certificates
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libxml2-utils=2.9.10+dfsg-5 \
    unzip=6.0-25ubuntu1 \
    curl=7.68.0-1ubuntu2.2 \
    ca-certificates=20190110ubuntu1 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# create kafka-connect-jdbc folder
RUN mkdir ./kafka-connect-jdbc/

# download kafka-connect-jdbc
ENV KAFKA_CONNECT_JDBC_VERSION 5.5.2
RUN curl -o confluentinc-kafka-connect-jdbc-${KAFKA_CONNECT_JDBC_VERSION}.zip "https://d1i4a15mxbxib1.cloudfront.net/api/plugins/confluentinc/kafka-connect-jdbc/versions/${KAFKA_CONNECT_JDBC_VERSION}/confluentinc-kafka-connect-jdbc-${KAFKA_CONNECT_JDBC_VERSION}.zip" && \
    unzip confluentinc-kafka-connect-jdbc-${KAFKA_CONNECT_JDBC_VERSION}.zip -d ./kafka-connect-jdbc/

# download mysql connector
ENV MYSQL_CONNECTOR_JAVA_VERSION 8.0.21
RUN curl -k -SL "https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MYSQL_CONNECTOR_JAVA_VERSION}.tar.gz" | tar -xzf - -C ./kafka-connect-jdbc/confluentinc-kafka-connect-jdbc-${KAFKA_CONNECT_JDBC_VERSION}/lib/ --strip-components=1 mysql-connector-java-$MYSQL_CONNECTOR_JAVA_VERSION/mysql-connector-java-$MYSQL_CONNECTOR_JAVA_VERSION.jar

# download castorm-kafka-connect-http
ENV KAFKA_CONNECT_HTTP_VERSION 0.7.7-0.1.0
RUN curl -u $GIT_PERSONAL_USERNAME:$GIT_PERSONAL_TOKEN -o url.txt "https://maven.pkg.github.com/finance-br/kafka-connect-http/com/github/castorm/kafka-connect-http/${KAFKA_CONNECT_HTTP_VERSION}/kafka-connect-http-${KAFKA_CONNECT_HTTP_VERSION}.zip" && \
    total_char=$(< url.txt wc -c) && \
    max_size=$((total_char - 26)) && \
    url_enconded=$(< url.txt cut -b 10-$max_size) && \
    url="${url_enconded//amp;/}" && \
    curl -o castorm-kafka-connect-http-${KAFKA_CONNECT_HTTP_VERSION}.zip "$url" && \
    mkdir castorm-kafka-connect-http && \
    unzip castorm-kafka-connect-http-${KAFKA_CONNECT_HTTP_VERSION}.zip -d ./castorm-kafka-connect-http/castorm-kafka-connect-http-${KAFKA_CONNECT_HTTP_VERSION}


# download hpgrahsl-kafka-connect-mongodb
ENV KAFKA_CONNECT_MONGODB_VERSION 1.4.0-0.1.0
RUN curl -u $GIT_PERSONAL_USERNAME:$GIT_PERSONAL_TOKEN -o url.txt "https://maven.pkg.github.com/finance-br/kafka-connect-mongodb/at/grahsl/kafka/connect/kafka-connect-mongodb/${KAFKA_CONNECT_MONGODB_VERSION}/kafka-connect-mongodb-${KAFKA_CONNECT_MONGODB_VERSION}.zip" && \
    total_char=$(< url.txt wc -c) && \
    max_size=$((total_char - 26)) && \
    url_enconded=$(< url.txt cut -b 10-$max_size) && \
    url="${url_enconded//amp;/}" && \
    curl -o hpgrahsl-kafka-connect-mongodb-${KAFKA_CONNECT_HTTP_VERSION}.zip "$url" && \
    mkdir hpgrahsl-kafka-connect-mongodb && \
    unzip hpgrahsl-kafka-connect-mongodb-${KAFKA_CONNECT_HTTP_VERSION}.zip -d ./castorm-kafka-connect-http/castorm-kafka-connect-http-${KAFKA_CONNECT_HTTP_VERSION}

# download kafka connect image
FROM confluentinc/cp-kafka-connect:6.0.0

COPY --from=builder ./kafka-connect-jdbc/ /usr/share/java/
COPY --from=builder ./castorm-kafka-connect-http/ /usr/share/java/
COPY --from=builder ./hpgrahsl-kafka-connect-mongodb/ /usr/share/java/
