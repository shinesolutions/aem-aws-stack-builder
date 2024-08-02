#!/bin/bash
git config --global user.email "shineworks@shinesolutions.com"
git config --global user.name "Shine Works"
chown -R root:root /github/workspace
make release-minor
