FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV TZ=UTC

# install build dependencies (sorted alphabetically)
RUN apt-get update && apt-get install -y \
    bc \
    bison \
    build-essential \
    ccache \
    curl \
    dwarves \
    flex \
    git \
    jq \
    libelf-dev \
    libssl-dev \
    lld \
    lz4 \
    openssl \
    python3 \
    rsync \
    unzip \
    wget \
    xz-utils \
    zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# install repo tool
RUN curl -o /usr/local/bin/repo https://storage.googleapis.com/git-repo-downloads/repo \
    && chmod a+x /usr/local/bin/repo

# configure git
RUN git config --global user.email 'kernelbuild@localhost' \
    && git config --global user.name 'kernelbuild' \
    && git config --global color.ui false

WORKDIR /build
