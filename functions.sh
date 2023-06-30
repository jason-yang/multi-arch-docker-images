#!/usr/bin/env bash

# Prerequisite
# Make sure you set secret environment variables in CI
# DOCKER_USERNAME
# DOCKER_PASSWORD
# API_TOKEN

# Usage to set variable "CURL_OPTIONS"
#
# if [[ "${CI}" == "true" ]]; then
#   CURL_OPTIONS="-sL -H \"Authorization: token ${API_TOKEN}\""
# else
#   CURL_OPTIONS="-sL"
# fi

function install_jq() {
  # jq 1.6
  DEBIAN_FRONTEND=noninteractive
  #sudo apt-get update && sudo apt-get -q -y install jq
  curl -sL https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 -o jq
  sudo mv jq /usr/bin/jq
  sudo chmod +x /usr/bin/jq
}

function get_latest_release() {
  curl "$CURL_OPTIONS" "https://api.github.com/repos/$1/releases/latest" | jq -r '.tag_name | ltrimstr("v")'
}

function get_published_date() {
  curl "$CURL_OPTIONS" -s "https://api.github.com/repos/$1/releases/latest" | jq -r '.published_at'
}

function get_image_published_date() {
  curl "$CURL_OPTIONS" -s "https://hub.docker.com/v2/repositories/$1/tags/" | jq -r '.results[] | select(.name == "latest") | .last_updated'
}

function get_image_tags() {
  curl "$CURL_OPTIONS" -s "https://hub.docker.com/v2/repositories/$1/tags/" | jq -r '.results[].name'
}

function build_docker_image() {
  local tag="${1}"
  local build_arg="${2}"
  local image_name="${3}"
  local platform="${4}"  

  # Create a new buildx builder instance
  docker buildx create --name mybuilder --use
  
  if [[ "$CIRCLE_BRANCH" == "master" ]]; then 
    docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
    docker buildx build --progress=plain --push \
     --platform "${platform}" \
     --build-arg "${build_arg}" \
     --no-cache \
     --tag "${image_name}:${tag}" \
     --tag "${image_name}:latest" \
     .
  fi
  
  # Remove the buildx builder instance
  docker buildx rm mybuilder
}