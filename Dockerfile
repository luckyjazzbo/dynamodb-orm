FROM ruby:2.3.1

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends -qq cmake && \
    apt-get clean -qq

RUN mkdir -p /app
WORKDIR /app
ADD . /app

RUN bundle install --jobs 4
