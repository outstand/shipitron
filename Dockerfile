FROM ruby:2.3.1-alpine
MAINTAINER Ryan Schlesinger <ryan@outstand.com>

RUN addgroup -S shipitron && \
    adduser -S -G shipitron shipitron && \
    addgroup -g 1101 docker && \
    addgroup shipitron docker

ENV GOSU_VERSION 1.9
ENV DUMB_INIT_VERSION 1.1.1

RUN apk add --no-cache ca-certificates gnupg && \
    mkdir -p /tmp/build && \
    cd /tmp/build && \
    gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 && \
    curl -o gosu -L "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-amd64" && \
    curl -o gosu.asc -L "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-amd64.asc" && \
    gpg --verify gosu.asc && \
    chmod +x gosu && \
    cp gosu /bin/gosu && \
    curl -O -L https://github.com/Yelp/dumb-init/releases/download/v${DUMB_INIT_VERSION}/dumb-init_${DUMB_INIT_VERSION}_amd64 && \
    curl -O -L https://github.com/Yelp/dumb-init/releases/download/v${DUMB_INIT_VERSION}/sha256sums && \
    grep dumb-init_${DUMB_INIT_VERSION}_amd64$ sha256sums | sha256sum -c && \
    chmod +x dumb-init_${DUMB_INIT_VERSION}_amd64 && \
    cp dumb-init_${DUMB_INIT_VERSION}_amd64 /bin/dumb-init && \
    cd /tmp && \
    rm -rf /tmp/build && \
    apk del gnupg && \
    rm -rf /root/.gnupg

RUN apk add --no-cache \
    build-base \
    git \
    openssh \
    perl \
    bash

ENV USE_BUNDLE_EXEC true
ENV BUNDLE_GEMFILE /shipitron/Gemfile

WORKDIR /app
COPY Gemfile shipitron.gemspec /shipitron/
COPY lib/shipitron/version.rb /shipitron/lib/shipitron/
COPY scripts/fetch-bundler-data.sh /shipitron/scripts/fetch-bundler-data.sh

ARG bundler_data_host
RUN /shipitron/scripts/fetch-bundler-data.sh ${bundler_data_host} && \
      (bundle check || bundle install) && \
      git config --global push.default simple
COPY . /shipitron/
RUN ln -s /shipitron/exe/shipitron /usr/local/bin/shipitron && \
    mkdir -p /home/shipitron/.ssh && \
    chown shipitron:shipitron /home/shipitron/.ssh && \
    chmod 700 /home/shipitron/.ssh

COPY scripts/docker-entrypoint.sh /docker-entrypoint.sh

ENV DUMB_INIT_SETSID 0
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["help"]
