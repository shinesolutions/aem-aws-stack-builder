#!/bin/bash
make clean deps lint package
echo "${GITHUB_TOKEN}" | gh auth login --with-token
chown -R root:root /github/workspace
make publish
