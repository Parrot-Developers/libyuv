#!/bin/bash

readonly UPSTREAM_REPO="https://chromium.googlesource.com/libyuv/libyuv"

echo "Add upstream remote: ${UPSTREAM_REPO}"
git remote add upstream ${UPSTREAM_REPO}
git fetch upstream --no-tags

echo "Setup upstream branches"
git branch upstream-main upstream/main --track
git branch upstream-stable upstream/stable --track
