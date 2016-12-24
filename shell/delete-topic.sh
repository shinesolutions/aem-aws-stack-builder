#!/usr/bin/env bash

aws sns delete-topic \
    --topic-arn arn:aws:sns:region:accountID:aem-stack-asg-topic
