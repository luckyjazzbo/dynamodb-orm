FROM ruby:2.3.1

RUN apt-get update -qq && \
    apt-get install -y cmake && \
    apt-get clean

RUN mkdir -p /app
WORKDIR /app
ADD . /app

RUN bundle install --jobs 4
