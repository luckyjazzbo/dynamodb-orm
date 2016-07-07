FROM ruby:2.3.1-slim

RUN apt-get update -qq && \
    apt-get install -qq -y --no-install-recommends build-essential cmake libpq-dev mcrypt libmcrypt-dev git pkg-config ssh&& \
    apt-get clean -qq

RUN mkdir -p /app
WORKDIR /app
ENV BUNDLE_PATH=/app/.bundle
ENV PATH=$PATH:./bin
ENTRYPOINT docker_start $0 $@
