FROM ubuntu:16.04

# Release parameters
ENV DISCOVERY_ARTMAN_VERSION=0.1.0 \
    DEBIAN_FRONTEND=noninteractive

# Set the locale
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=C

# Install essential packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        man-db \
        pkg-config \
        libffi-dev \
        libssl-dev \
        curl \
        kdiff3 \
        git \
        vim \
        less \
        openssh-client && \
    rm -rf /var/lib/apt/lists/*

# Install runtime packages
RUN apt-get update && \
    apt-get install -y \
        unzip \
        perl \
        software-properties-common \
        php-pear && \
    rm -rf /var/lib/apt/lists/*

# Install python requirements
RUN apt-get update && \
    apt-get install -y \
        python-pip \
        python3-pip && \
    rm -rf /var/lib/apt/lists/* && \
    python -m pip install --upgrade pip && \
    python -m pip install django==1.8.12 httplib2 google-apputils python-gflags google-api-python-client

# Install Oracle JDK 8
RUN add-apt-repository ppa:openjdk-r/ppa && \
    apt-get update && \
    apt-get install -y openjdk-8-jdk && \
    rm -rf /var/lib/apt/lists/*

# Setup JAVA_HOME, this is useful for docker commandline
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/
RUN export JAVA_HOME

# Install NodeJS.
# This installs Node 4 on Ubuntu 16.04.
RUN apt-get update && \
    apt-get install -y \
        nodejs \
        npm && \
    rm -rf /var/lib/apt/lists/* && \
    # Ubuntu apt uses "nodejs" as the executable, but everything else expects
    # the executable to be spelled "node".
    ln -s /usr/bin/nodejs /usr/local/bin/node

# Install Ruby.
# This installs Ruby 2.3 on Ubuntu 16.04.
RUN apt-get update && \
    apt-get install -y \
        ruby \
        ruby-dev && \
    rm -rf /var/lib/apt/lists/*

# Setup tools for codegen of Ruby
RUN gem install rake --no-ri --no-rdoc && \
    gem install rubocop --version '= 0.39.0' --no-ri --no-rdoc && \
    gem install bundler --version '= 1.12.1' --no-ri --no-rdoc && \
    gem install rake --version '= 10.5.0' --no-ri --no-rdoc && \
    gem install grpc-tools --version '=1.10.0' --no-ri --no-rdoc

# Install Go.
RUN mkdir -p /golang \
  && cd /golang \
  && curl https://dl.google.com/go/go1.10.3.linux-amd64.tar.gz > go.tar.gz \
  && (echo 'fa1b0e45d3b647c252f51f5e1204aba049cde4af177ef9f2181f43004f901035 go.tar.gz' | sha256sum -c) \
  && tar xzf go.tar.gz \
  && cd /
ENV PATH $PATH:/golang/go/bin
ENV GOPATH /go
ENV PATH $GOPATH/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" \
  && chmod -R 777 "$GOPATH"

ADD . /discovery-artifact-manager

WORKDIR /discovery-artifact-manager