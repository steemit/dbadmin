FROM ruby:2.3

RUN apt-get update -qq && apt-get install -y build-essential git nodejs mysql-client libmysqlclient-dev

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/
RUN bundle install
ADD . $APP_HOME
RUN bundle exec rake assets:precompile

EXPOSE 5000

# entrypoint / cmd
CMD bundle exec unicorn -E production -c config/unicorn.rb
