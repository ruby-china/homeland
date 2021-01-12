RUN  = docker-compose run app
RAKE = docker-compose run app bundle exec rake

docker\:base:
	docker build -f Dockerfile-base . -t homeland/base:latest
docker\:build:
	docker build . -t homeland/homeland:latest
docker\:stop:
	docker-compose down
docker\:start:
	docker-compose up
docker\:shell:
	docker-compose run app bash
docker\:test:
	@$(RUN) echo "${RAILS_ENV}"
docker\:install:
	@$(RUN) bundle exec rails db:migrate RAILS_ENV=production
	@$(RUN) bundle exec rails db:seed RAILS_ENV=production
	@$(RUN) bundle exec rails assets:precompile RAILS_ENV=production
