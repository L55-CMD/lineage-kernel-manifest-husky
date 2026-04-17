FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends \
    bc \
    bison \
    build-essential \
    ca-certificates \
    ccache \
    curl \
    file \
    flex \
    g++-multilib \
    gcc-multilib \
    git \
    git-lfs \
    gnupg \
    gperf \
    imagemagick \
    lib32ncurses6 \
    lib32readline-dev \
    lib32z1-dev \
    libelf-dev \
    liblz4-tool \
    libsdl1.2-dev \
    libssl-dev \
    libxml2 \
    libxml2-utils \
    lzop \
    openjdk-21-jdk-headless \
    openssh-client \
    pngcrush \
    python-is-python3 \
    python3 \
    repo \
    rsync \
    schedtool \
    squashfs-tools \
    unzip \
    wget \
    xsltproc \
    zip \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
