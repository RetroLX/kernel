#!/bin/bash -e

# PWD = source dir
# BASE_DIR = build dir
# BUILD_DIR = base dir/build
# HOST_DIR = base dir/host
# BINARIES_DIR = images dir
# TARGET_DIR = target dir


#!/usr/bin/env bash
#
# Author: Stefan Buck
# https://gist.github.com/stefanbuck/ce788fee19ab6eb0b4447a85fc99f447
#
#
# This script accepts the following parameters:
#
# * owner
# * repo
# * tag
# * filename
# * github_api_token
#
# Script to upload a release asset using the GitHub API v3.
#
# Example:
#
# upload-github-release-asset.sh github_api_token=TOKEN owner=stefanbuck repo=playground tag=v0.1.0 filename=./build.zip
#

# Check dependencies.
set -e
xargs=$(which gxargs || which xargs)

# Validate settings.
[ "$TRACE" ] && set -x

# Define variables.
GH_API="https://api.github.com"
GH_REPO="$GH_API/repos/RetroLX/kernel"
GH_TAGS="$GH_REPO/releases/tags/${TARGET}-${VERSION}"
AUTH="Authorization: token $GH_TOKEN"
WGET_ARGS="--content-disposition --auth-no-challenge --no-cookie"
CURL_ARGS="-LJO#"

if [[ "$tag" == 'LATEST' ]]; then
  GH_TAGS="$GH_REPO/releases/latest"
fi

# Validate token.
curl -o /dev/null -sH "$AUTH" $GH_REPO || { echo "Error: Invalid repo, token or network issue!";  exit 1; }

# Create release
curl -i -X POST -H "Content-Type:application/json" -H "Authorization: token $GH_TOKEN" $GH_REPO/releases -d "{\"tag_name\":\"${TARGET}-${VERSION}\",\"name\": \"${TARGET}-${VERSION}\",\"body\": \"\",\"draft\": false,\"prerelease\": false}"

# Read asset tags.
response=$(curl -sH "$AUTH" $GH_TAGS)

# Get ID of the asset based on given filename.
eval $(echo "$response" | grep -m 1 "id.:" | grep -w id | tr : = | tr -cd '[[:alnum:]]=')
[ "$id" ] || { echo "Error: Failed to get release id for tag: $tag"; echo "$response" | awk 'length($0)<100' >&2; exit 1; }

# Upload asset
echo "Uploading asset... $localAssetPath" >&2

# Construct url
GH_ASSET="https://uploads.github.com/repos/RetroLX/kernel/releases/$id/assets?name=kernel-${TARGET}-${VERSION}.tar.gz"

curl "$GITHUB_OAUTH_BASIC" --data-binary @"output/kernel-${TARGET}/images/kernel.tar.gz" -H "Authorization: token $GH_TOKEN" -H "Content-Type: application/octet-stream" $GH_ASSET
