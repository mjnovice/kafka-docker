FROM arm64v8/openjdk:8-jre

ARG kafka_version=2.3.0
ARG scala_version=2.12
ARG glibc_version=2.27-3ubuntu1
ARG vcs_ref=unspecified
ARG build_date=unspecified

LABEL org.label-schema.name="kafka" \
      org.label-schema.description="Apache Kafka" \
      org.label-schema.build-date="${build_date}" \
      org.label-schema.vcs-url="https://github.com/wurstmeister/kafka-docker" \
      org.label-schema.vcs-ref="${vcs_ref}" \
      org.label-schema.version="${scala_version}_${kafka_version}" \
      org.label-schema.schema-version="1.0" \
      maintainer="wurstmeister"

ENV KAFKA_VERSION=$kafka_version \
    SCALA_VERSION=$scala_version \
    KAFKA_HOME=/opt/kafka \
    GLIBC_VERSION=$glibc_version

ENV PATH=${PATH}:${KAFKA_HOME}/bin

COPY download-kafka.sh start-kafka.sh broker-list.sh create-topics.sh versions.sh /tmp/

RUN ls -la /tmp/ && sleep 11

RUN apt-get update \
 && apt-get -y install bash curl jq docker \
 && chmod a+x /tmp/*.sh \
 && mv /tmp/start-kafka.sh /tmp/broker-list.sh /tmp/create-topics.sh /tmp/versions.sh /usr/bin \
 && ls -la /usr/bin/*.sh \
 && sleep 10 \
 && sync && /tmp/download-kafka.sh \
 && tar xfz /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz -C /opt \
 && rm /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz \
 && ln -s /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION} ${KAFKA_HOME} \
 && rm -rf /tmp/* \
# && wget http://ftp.us.debian.org/debian/pool/main/g/glibc/libc-bin_2.29-2_arm64.deb \
# && dpkg -i libc-bin_2.29-2_arm64.deb \
# && rm libc-bin_2.29-2_arm64.deb

COPY overrides /opt/overrides

VOLUME ["/kafka"]

RUN ls -la /usr/bin/*.sh && sleep 10

# Use "exec" form so that it runs as PID 1 (useful for graceful shutdown)
CMD ["start-kafka.sh"]
