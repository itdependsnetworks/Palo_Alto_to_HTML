
.PHONY: cli
cli:
	docker exec -it parules_web bash

.PHONY: build
build:
	docker-compose -p parules build

.PHONY: deploy
deploy:
	docker-compose -p parules up


.PHONY: deploy_detached
deploy_detached:
	docker-compose -p parules up -d

.PHONY: down
down:
	docker-compose -p parules down

.PHONY: destroy
destroy:
	docker-compose -p parules down

.PHONY: rebuild
rebuild:
	make destroy
	make build
	make deploy

.PHONY: rebuild_detached
rebuild_detached:
	make destroy
	make build
	make deploy_detached

.PHONY: run_scripts
run_scripts:
	docker exec -it parules_web /scripts/pascripts/runall.pl
	docker exec -it parules_web /scripts/pascripts/dailyhistory.pl
