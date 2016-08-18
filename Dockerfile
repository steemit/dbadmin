FROM ruby:2.3

RUN apt-get update -qq && apt-get install -y build-essential git nodejs mysql-client libmysqlclient-dev

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/
RUN bundle install
RUN bundle exec rake assets:precompile

ADD . $APP_HOME



EXPOSE 5000
