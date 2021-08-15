FROM openjdk:11

ENV SPARK_VERSION="3.1.2"
ENV SPARK_INSTALL_DIR="/opt/spark"
ENV HADOOP_VERSION="3.2.0"
ENV HADOOP_INSTALL_DIR="/opt/hadoop"

ENV SPARK_HOME="${SPARK_INSTALL_DIR}"
ENV SPARK_CONF_DIR="${SPARK_INSTALL_DIR}/conf"
ENV HADOOP_HOME="${HADOOP_INSTALL_DIR}"
ENV HADOOP_CONF_DIR="${SPARK_INSTALL_DIR}/etc/hadoop"


RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        apt-utils locales wget \
    && update-locale LANG=C.UTF-8 LC_MESSAGES=POSIX \
    && locale-gen en_US.UTF-8 \
    && DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales \
    && rm -rf /var/lib/apt/lists/*

RUN useradd --system --create-home --home-dir "${HADOOP_HOME}" hadoop \
    && mkdir -p "${HADOOP_INSTALL_DIR}" \
    && cd "${HADOOP_INSTALL_DIR}" \
    && wget -q -O "${HADOOP_INSTALL_DIR}/hadoop.tgz" "https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz" \
    && tar -xz --strip 1 -f "hadoop.tgz" \
    && chown -R hadoop:hadoop "${HADOOP_HOME}"

RUN useradd --system --create-home --home-dir "${SPARK_HOME}" spark \
    && mkdir -p "${SPARK_INSTALL_DIR}" \
    && cd "${SPARK_INSTALL_DIR}" \
    && wget -q -O "${SPARK_INSTALL_DIR}/spark-bin-hadoop.tgz" "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION%.*}.tgz" \
    && tar -xz --strip 1 -f "spark-bin-hadoop.tgz" \
    && chown -R spark:spark "${SPARK_HOME}"

COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

USER spark
WORKDIR $SPARK_HOME

ENTRYPOINT [ "/sbin/entrypoint.sh" ]
CMD ["master"]
