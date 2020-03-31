RUN  = docker-compose run app
RAKE = docker-compose run app bundle exec rake

docker\:build:
	docker build . -t homeland/homeland:test
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
docker\:reindex:
	@echo "Reindex ElasticSearch..."
	@$(RAKE) environment elasticsearch:import:model CLASS=Topic FORCE=y
	@$(RAKE) environment elasticsearch:import:model CLASS=User FORCE=y
