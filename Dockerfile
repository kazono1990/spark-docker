FROM openjdk:11

ENV SPARK_VERSION="3.1.2"
ENV SPARK_INSTALL_DIR="/opt/spark"
ENV SPARK_CHECKSUM="2385cb772f21b014ce2abd6b8f5e815721580d6e8bc42a26d70bbcdda8d303d886a6f12b36d40f6971b5547b70fae62b5a96146f0421cb93d4e51491308ef5d5"
ENV HADOOP_VERSION="3.2.0"
ENV HADOOP_INSTALL_DIR="/opt/hadoop"
ENV HADOOP_CHECKSUM="79676a7dadbc4740cb2ff4ae7af75f5b0a45b4748f217f4179ab64827b840eef58c63b9132260c5682cb28b6d12a27d4a4d09a15173aca158fb1fc3cdb0b1609"

ENV SPARK_HOME="${SPARK_INSTALL_DIR}"
ENV SPARK_LOG_DIR="/var/log/spark"
ENV SPARK_WORKER_DIR="/var/run/spark/work"
ENV SPARK_SSL_CERTS_DIR="/etc/private/ssl"
ENV HADOOP_HOME="${HADOOP_INSTALL_DIR}"

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        apt-utils \
        ca-certificates \
        curl \
        less \
        locales \
        net-tools \
        python3 \
        python3-matplotlib \
        python3-numpy \
        python3-pandas \
        python3-pip \
        python3-scipy \
        python3-simpy \
        software-properties-common \
        ssh \
        vim \
        wget \
    && update-locale LANG=C.UTF-8 LC_MESSAGES=POSIX \
    && locale-gen en_US.UTF-8 \
    && DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales \
    && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install "/usr/bin/python" "python" "$(which python3)" 1

ENV PYTHONHASHSEED=1
ENV PATH="${SPARK_INSTALL_DIR}/bin:${PATH}"
ENV LD_LIBRARY_PATH="${HADOOP_HOME}/lib/native"

RUN useradd --system --create-home --home-dir "${HADOOP_HOME}" hadoop \
    && mkdir -p "${HADOOP_INSTALL_DIR}" \
    && cd "${HADOOP_INSTALL_DIR}" \
    && wget --no-check-certificate -O "${HADOOP_INSTALL_DIR}/hadoop.tgz" "https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz" \
    && sha512sum "hadoop.tgz" | grep "${HADOOP_CHECKSUM}" \
    && tar -xz --strip 1 -f "hadoop.tgz" \
    && chown -R hadoop:hadoop "${HADOOP_HOME}"

RUN useradd --system --create-home --home-dir "${SPARK_HOME}" spark \
    && mkdir -p "${SPARK_LOG_DIR}" "${SPARK_WORKER_DIR}" "${SPARK_INSTALL_DIR}" \
    && cd "${SPARK_INSTALL_DIR}" \
    && wget --no-check-certificate -O "${SPARK_INSTALL_DIR}/spark-bin-hadoop.tgz" "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION%.*}.tgz" \
    && sha512sum "spark-bin-hadoop.tgz" | grep "${SPARK_CHECKSUM}" \
    && tar -xz --strip 1 -f "spark-bin-hadoop.tgz" \
    && chown -R spark:spark "${SPARK_HOME}" "${SPARK_LOG_DIR}" "${SPARK_WORKER_DIR}"

COPY --chown=spark:spark conf/spark-env.sh "${SPARK_HOME}"/conf/spark-env.sh
COPY --chown=spark:spark conf/spark-defaults.conf "${SPARK_HOME}"/conf/spark-defaults.conf
COPY bin/generate-ssl-files.sh /sbin/generate-ssl-files.sh
COPY bin/entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/generate-ssl-files.sh /sbin/entrypoint.sh \
    && /sbin/generate-ssl-files.sh \
    && chmod 400 "${SPARK_SSL_CERTS_DIR}"/* \
    && chown spark:spark "${SPARK_SSL_CERTS_DIR}"/*

USER spark
WORKDIR $SPARK_HOME

ENTRYPOINT [ "/sbin/entrypoint.sh" ]
CMD ["master"]
