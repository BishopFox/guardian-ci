#!/usr/bin/env bash
set -euo pipefail


VERSION=$(cat VERSION)
if [[ -z $VERSION ]]; then
    echo "no VERSION file present"
    exit 1
fi

CONTAINER="bishopfox/$RELEASE_NAME"

VERSIONED_TAG="$VERSION"
NAMED_TAG="stable"
if [[ -n $CANDIDATE ]]; then
    VERSIONED_TAG="$VERSIONED_TAG-$CIRCLE_SHA1"
    NAMED_TAG="latest"
fi

build() {
    docker build --pull --no-cache -t "$CONTAINER" .
}

push_version() {
    local TAG="$1"

    docker tag "$CONTAINER:latest" "$TAG"

    docker push "$TAG"
}

build_migration() {
    docker build -t "$CONTAINER:migrate" ./migrations/
}

push_migration() {
    local TAG="$1"

    docker tag "$CONTAINER:migrate" "$TAG"

    docker push "$TAG"
}


echo "$DOCKER_PASS" | docker login --username "$DOCKER_USER" --password-stdin

build

push_version "$CONTAINER:$VERSIONED_TAG"
push_version "$CONTAINER:$NAMED_TAG"

if [[ -f migrations/Dockerfile ]]; then
    build_migration
    push_migration "$CONTAINER:migrate-$VERSIONED_TAG"
    push_migration "$CONTAINER:migrate-$NAMED_TAG"
fi
