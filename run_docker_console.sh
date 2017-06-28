#!/usr/bin/env bash

docker-compose run --service-ports -e RAILS_ENV=development -e MYSQL_HOST=`ipconfig getifaddr en1` web rails console
