# Setup ————————————————————————————————————————————————————————————————————————————————————————————————————————————————
PROJECT_NAME=$(shell basename $$(pwd) | tr '[:upper:]' '[:lower:]')
APP_DOCKERFILE=./docker/app/Dockerfile

IMG_NAME_DEVELOPMENT=$(PROJECT_NAME)-development
IMG_NAME_PROD=$(PROJECT_NAME)-prod

STAGE_DEVELOPMENT=development
STAGE_PROD=production

MAVEN_IMAGE=maven:3-openjdk-17-slim
MAVEN_BASE_COMMAND=$(DOCKER_RUN_BASE) \
                   		-v $(shell pwd):/opt/maven \
                   		-v $(PROJECT_NAME)-maven:/root/.m2 \
                   		-w /opt/maven

DOCKER_RUN_BASE=docker run -it --rm

DC_BASE_COMMAND=docker compose -f docker/docker-compose.dev.yml -p $(PROJECT_NAME)-dc

ifeq ($(wildcard ./docker/docker-compose.override.yml),)
	COMPOSE_OVERRIDE=
else
	COMPOSE_OVERRIDE=-f ./docker/docker-compose.override.yml
endif

.PHONY: build-dev
build-dev:
	docker build --tag $(IMG_NAME_DEVELOPMENT) -f $(APP_DOCKERFILE) --target $(STAGE_DEVELOPMENT) .

.PHONY: rebuild-dev
rebuild-dev:
	docker build --no-cache --tag $(IMG_NAME_DEVELOPMENT) -f $(APP_DOCKERFILE) --target $(STAGE_DEVELOPMENT) .

.PHONY: build-prod
build-prod:
	docker build --tag $(IMG_NAME_PROD) -f $(APP_DOCKERFILE) --target $(STAGE_PROD) .

.PHONY: test
test:
	@#$(DOCKER_RUN_BASE) \
#		-v $(shell pwd):/opt/maven \
#		-v maven-repo:/root/.m2 \
#		-w /opt/maven \
#		--name $(PROJECT_NAME)-test \
#		$(IMG_NAME_DEVELOPMENT) \
#		./mvnw \
#		$$ARG \
#		test

	@#${DOCKER_RUN_BASE} -v "$(pwd):/opt/maven" -v maven-repo:/root/.m2 -w /opt/maven maven:3.8-openjdk-17-slim mvn clean verify

	$(MAVEN_BASE_COMMAND) \
		$(MAVEN_IMAGE) \
		mvn \
		test \
		$$ARG

.PHONY: test-debug
test-debug:
	@#$(DOCKER_RUN_BASE) \
#		-v $(shell pwd):/opt/maven \
#		-v maven-repo:/root/.m2 \
#		-w /opt/maven \
#		--name $(PROJECT_NAME)-test \
#		-p 5005:5005 \
#		$(IMG_NAME_DEVELOPMENT) \
#		./mvnw \
#		-Dmaven.surefire.debug="-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=*:5005" \
#		$$ARG \
#		test

	$(MAVEN_BASE_COMMAND) \
		-p 5005:5005 \
		$(MAVEN_IMAGE) \
		mvn \
		-Dmaven.surefire.debug="-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=*:5005" \
		test \
		$$ARG

.PHONY: up
up:
	$(DC_BASE_COMMAND) $(COMPOSE_OVERRIDE) up $$ARG

.PHONY: up-prod
up-prod:
	$(DOCKER_RUN_BASE) \
		-p 8080:8080 \
		--name $(PROJECT_NAME)-server \
		$$ARG \
		$(IMG_NAME_PROD)

.PHONY: up-build
up-build:
	$(DC_BASE_COMMAND) \
	up \
	--build \
	--force-recreate \
	$$ARG