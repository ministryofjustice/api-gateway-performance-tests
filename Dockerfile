FROM ruby:2.5



# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

ENV NOMIS_API_CLIENT_TOKEN_FILE /usr/src/app/nomis-api-client.token
ENV NOMIS_API_CLIENT_KEY_FILE /usr/src/app/nomis-api-client.key

CMD ["./api_gateway_perf_test.rb"]