FROM debian:9

LABEL author="Paulo Henrique dos Santos <paulo.santos@fh.com.br>"
LABEL co-author="Lucas Zarzur <lucas12zarzur@gmail.com>"
LABEL maintainer="Lucas Zarzur <lucas12zarzur@gmail.com>"

## Arguments 
ARG HYBRIS_COMMERCE123_VERSION="CXCOMM181100P_2-70004085.ZIP"
ARG HYBRIS_COMMERCE123_DIR="/app/Commerce123Mod"
ARG HYBRIS_COMMERCE123_USER="hybris_commerce123"
ARG HYBRIS_COMMERCE123_CUSTOM_DIR=${HYBRIS_COMMERCE123_DIR}"/hybris/bin/custom"
# ARG RECIPE="b2c_b2b_acc"
# ARG RECIPE="b2b_acc"
ARG RECIPE="b2c_acc"
ARG JAVA_VERSION_FILE="jdk-8u211-linux-x64.tar.gz"
ARG DB_DRIVER="mysql-connector-java-5.1.47.jar"
ARG DOCKER_HOME="/home/hybris"

## Environments
ENV HYBRIS_COMMERCE123_VERSION=${HYBRIS_COMMERCE123_VERSION}
ENV HYBRIS_COMMERCE123_DIR=${HYBRIS_COMMERCE123_DIR}
ENV HYBRIS_COMMERCE123_USER=${HYBRIS_COMMERCE123_USER}
ENV HYBRIS_COMMERCE123_CUSTOM_DIR=${HYBRIS_COMMERCE123_CUSTOM_DIR}
ENV RECIPE=${RECIPE}
ENV JAVA_VERSION_FILE=${JAVA_VERSION_FILE}
ENV DB_DRIVER=${DB_DRIVER}
ENV DEVELOPER_NAME="Lucas Zarzur"
ENV DEVELOPER_EMAIL="lucas12zarzur@gmail.com"
ENV BRANCH_NAME=
ENV INITIALIZE="true"
ENV USE_MYSQL_DB="true"
ENV USE_SOLR_SSL="false"
ENV DOCKER_HOME=${DOCKER_HOME}

## Install linux packages
RUN apt-get update && apt-get install -y software-properties-common gnupg unzip lsof sudo git apt-utils nano curl
RUN apt-get update && curl -sL https://deb.nodesource.com/setup_9.x | sudo -E bash -
RUN apt-get update && apt-get install -y build-essential nodejs

## Create hybris user and set password, folders (Docker home, Hybris dir)
RUN mkdir -p ${DOCKER_HOME}
RUN useradd -m -d ${DOCKER_HOME} ${HYBRIS_COMMERCE123_USER} && echo "${HYBRIS_COMMERCE123_USER}    ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN chown -R ${HYBRIS_COMMERCE123_USER}:${HYBRIS_COMMERCE123_USER} ${DOCKER_HOME}
RUN mkdir -p ${DOCKER_HOME}/.ssh
RUN mkdir -p ${HYBRIS_COMMERCE123_DIR}
RUN mkdir -p /usr/lib/jvm 

## Expose Hybris Commerce123 ports
EXPOSE 9001
EXPOSE 9002
EXPOSE 8000

## Expose Solr port
EXPOSE 8983

## Copy files
COPY bashrc.txt ${DOCKER_HOME}/.bashrc
COPY bashrc.txt /root/.bashrc
COPY entrypoint.sh /entrypoint.sh
COPY hybris.sh /etc/init.d/hybris
COPY ${HYBRIS_COMMERCE123_VERSION} ${DOCKER_HOME}/${HYBRIS_COMMERCE123_VERSION}
COPY ${JAVA_VERSION_FILE} ${DOCKER_HOME}/${JAVA_VERSION_FILE}
COPY ${DB_DRIVER} ${DOCKER_HOME}

## Update file permissions
RUN chmod +x /entrypoint.sh
RUN chown ${HYBRIS_COMMERCE123_USER}:${HYBRIS_COMMERCE123_USER} /entrypoint.sh
RUN chmod +x /etc/init.d/hybris

## Setting workdir
WORKDIR ${HYBRIS_COMMERCE123_DIR}

## Change to hybris User
USER ${HYBRIS_COMMERCE123_USER}

## Set entrypoint of container
ENTRYPOINT ["/entrypoint.sh"]

CMD ["run"]
