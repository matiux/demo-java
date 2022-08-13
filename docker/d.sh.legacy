#!/bin/bash

PROJECT_NAME=$(basename "$(pwd)" | tr '[:upper:]' '[:lower:]')
APP_DOCKERFILE=./docker/app/Dockerfile

STAGE_DEVELOPMENT="development"
STAGE_PROD="production"
#STAGE_TEST="test"

IMG_NAME_DEVELOPMENT="${PROJECT_NAME}_development"
IMG_NAME_PROD="${PROJECT_NAME}_prod"

COMPOSE_OVERRIDE=

if [[ -f "./docker/docker-compose.override.yml" ]]; then
  COMPOSE_OVERRIDE="--file ./docker/docker-compose.override.yml"
fi

DC_BASE_COMMAND="docker compose -f docker/docker-compose.dev.yml ${COMPOSE_OVERRIDE} -p ${PROJECT_NAME}"
DOCKER_RUN_BASE="docker run -it --rm"

if [[ "$1" == "build-dev" ]]; then
  shift 1; docker build --tag "${IMG_NAME_DEVELOPMENT}" -f ${APP_DOCKERFILE} --target ${STAGE_DEVELOPMENT} .

elif [[ "$1" == "build-prod" ]]; then
  shift 1; docker build --tag "${IMG_NAME_PROD}" -f ${APP_DOCKERFILE} --target ${STAGE_PROD} .

elif [[ "$1" == "rebuild-dev" ]]; then
  shift 1; docker build --no-cache --tag "${IMG_NAME_DEVELOPMENT}" -f ${APP_DOCKERFILE} --target ${STAGE_DEVELOPMENT} .

#elif [[ "$1" == "build-test" ]]; then
#  shift 1; docker build --tag "${PROJECT_NAME}_test" -f ${APP_DOCKERFILE} --target ${STAGE_TEST} .
#
#elif [[ "$1" == "rebuild-test" ]]; then
#  shift 1; docker build --no-cache --tag "${PROJECT_NAME}_test" -f ${APP_DOCKERFILE} --target ${STAGE_TEST} .
elif [[ "$1" == "test" ]]; then
  shift 1;  ${DOCKER_RUN_BASE} -v "$(pwd):/opt/maven" -v maven-repo:/root/.m2 -w /opt/maven --name "${PROJECT_NAME}-test" "${IMG_NAME_DEVELOPMENT}" ./mvnw "$@" test
#  shift 1;  ${DOCKER_RUN_BASE} -v "$(pwd):/opt/maven" -v maven-repo:/root/.m2 -w /opt/maven maven:3.8-openjdk-17-slim mvn clean verify
#  shift 1;  ${DOCKER_RUN_BASE} -v "$(pwd):/opt/maven" -v maven-repo:/root/.m2 -w /opt/maven maven:3.8-openjdk-17-slim mvn test

elif [[ "$1" == "test-debug" ]]; then
  shift 1;  ${DOCKER_RUN_BASE} -v "$(pwd):/opt/maven" -v maven-repo:/root/.m2 -w /opt/maven --name "${PROJECT_NAME}-test" -p "5005:5005" "${IMG_NAME_DEVELOPMENT}" ./mvnw -Dmaven.surefire.debug="-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=*:5005" "$@" test

elif [[ "$1" == "up" ]]; then
  shift 1; ${DC_BASE_COMMAND} up "$@"

elif [[ "$1" == "up-prod" ]]; then
  shift 1; ${DOCKER_RUN_BASE} -p 8080:8080 --name "${PROJECT_NAME}-server" "$@" ${IMG_NAME_PROD}

elif [[ "$1" == "up-build" ]]; then
  shift 1; ${DC_BASE_COMMAND} up --build --force-recreate "$@"
fi