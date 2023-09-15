FROM amd64/ubuntu:23.10

RUN apt-get update -y && \
    apt-get install --no-install-recommends -y \
    ca-certificates \
    bash \
    curl \
    wget \
    procps \
    apt-utils \
    apt-transport-https \
    bzip2 \
    cron \
    jq \
    gnupg \
    unzip \
    binutils \
    libproj-dev \
    gdal-bin \
    libgdal-dev \ 
    g++ \
    libnss-wrapper && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Update C env vars so compiler can find gdal
ENV CPLUS_INCLUDE_PATH=/usr/include/gdal
ENV C_INCLUDE_PATH=/usr/include/gdal

# AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install

# DUCKDB
WORKDIR /duckdb
RUN wget https://github.com/duckdb/duckdb/releases/download/v0.8.1/duckdb_cli-linux-amd64.zip
RUN unzip duckdb_cli-linux-amd64.zip

# Prepare data
WORKDIR /duckdb/import
COPY ./*.sql .
COPY ./*.sh .
RUN mkdir data
COPY ./data ./data

# if you want download all
# RUN aws s3 cp --region us-west-2 --no-sign-request --recursive s3://overturemaps-us-west-2/release/2023-07-26-alpha.0/ .
RUN ./srs.sh
RUN ./geoparquet.sh

RUN /duckdb/duckdb omf_italy -c ".read 00_prepare_tables_istat.sql"

