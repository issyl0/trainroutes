FROM ruby:3.0.1

LABEL Name=trainroutes Version=0.0.1

EXPOSE 80

ENV RACK_ENV=production
ENV APP_ENV=production

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

WORKDIR /app
COPY . /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

CMD ["thin", "-R", "config.ru", "-a", "0.0.0.0", "-p", "80", "start"]
