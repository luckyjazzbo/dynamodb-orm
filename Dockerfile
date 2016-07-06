FROM ruby:2.3.1

RUN apt-get update -qq && \
    apt-get install -qq -y --no-install-recommends build-essential cmake libpq-dev mcrypt libmcrypt-dev && \
    apt-get clean -qq

ENV BUNDLE_PATH=/app/.bundle
ENV PATH=$PATH:./bin

RUN mkdir -p /app
WORKDIR /app

EXPOSE 3000

ENTRYPOINT docker_start $0 $@
