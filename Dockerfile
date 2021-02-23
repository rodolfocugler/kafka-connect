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
RUN echo ${GIT_PERSONAL_USERNAME}
# download castorm-kafka-connect-http
ENV KAFKA_CONNECT_HTTP_VERSION 0.7.7-0.1.0
RUN curl -o castorm-kafka-connect-http-${KAFKA_CONNECT_HTTP_VERSION}.zip "https://github-registry-files.githubusercontent.com/304133755/01c8b900-0eea-11eb-98fb-7fa120b136d8?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIWNJYAX4CSVEH53A%2F20210223%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20210223T203310Z&X-Amz-Expires=300&X-Amz-Signature=3c7780fdb48494c2737781fe9d60bd74fc4c06937cd00ce8c54e33b48ab3ee98&X-Amz-SignedHeaders=host&actor_id=0&key_id=0&repo_id=304133755&response-content-disposition=filename%3Dkafka-connect-http-0.7.7-0.1.0.zip&response-content-type=application%2Foctet-stream" && \
    unzip castorm-kafka-connect-http-${KAFKA_CONNECT_HTTP_VERSION}.zip -d ./castorm-kafka-connect-http/castorm-kafka-connect-http-${KAFKA_CONNECT_HTTP_VERSION}

# download hpgrahsl-kafka-connect-mongodb
ENV KAFKA_CONNECT_MONGODB_SINK_VERSION 1.4.0-0.1.1
RUN curl -o hpgrahsl-kafka-connect-mongodb-${KAFKA_CONNECT_HTTP_VERSION}.zip "https://github-registry-files.githubusercontent.com/308427197/73dfe880-1a28-11eb-9ef0-d2d536332204?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIWNJYAX4CSVEH53A%2F20210223%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20210223T203543Z&X-Amz-Expires=300&X-Amz-Signature=6779fb5286706a1a1fce4fd415f539504b5c1543f8d96a0db9803bbad0894500&X-Amz-SignedHeaders=host&actor_id=0&key_id=0&repo_id=308427197&response-content-disposition=filename%3Dkafka-connect-mongodb-1.4.0-0.1.1.zip&response-content-type=application%2Foctet-stream" && \
    unzip hpgrahsl-kafka-connect-mongodb-${KAFKA_CONNECT_HTTP_VERSION}.zip -d ./hpgrahsl-kafka-connect-mongodb/hpgrahsl-kafka-connect-mongodb-${KAFKA_CONNECT_HTTP_VERSION}

# download kafka connect image
FROM confluentinc/cp-kafka-connect:6.1.0

COPY --from=builder ./kafka-connect-jdbc/ /usr/share/java/
COPY --from=builder ./castorm-kafka-connect-http/ /usr/share/java/
COPY --from=builder ./hpgrahsl-kafka-connect-mongodb/ /usr/share/java/
COPY --from=builder ./mongodb-kafka-connect-mongodb/ /usr/share/java/
