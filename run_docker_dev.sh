#!/usr/bin/env bash
docker-compose run --service-ports -e RAILS_ENV=development web rails s -b 0.0.0.0 -p 5000
