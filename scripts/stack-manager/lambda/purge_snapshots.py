# -*- coding: utf8 -*-

"""
Lambda function to manage AEM Stack resources.
"""

import os
import boto3
import logging
import datetime
import re
import time


__author__ = 'Andy Wang (andy.wang@shinesolutions.com)'
__copyright__ = 'Shine Solutions'
__license__ = 'Apache License, Version 2.0'


# setting up logger
logger = logging.getLogger(__name__)
logger.setLevel(int(os.getenv('LOG_LEVEL', logging.INFO)))


def purge_old_snapshots(params):

    filters = [
        {
            'Name': 'status',
            'Values': ['completed']
        }
    ]

    if 'StackPrefix' in params:
        filters.append({
            'Name': 'tag:StackPrefix',
            'Values': [params['StackPrefix']]
        })
    else:
        filters.append({
            'Name': 'tag-key',
            'Values': ['StackPrefix']
        })

    filters.append(
        {
            'Name': 'tag:SnapshotType',
            'Values': [params['SnapshotType']]
        }
    )

    # snapshots is a list
    snapshots = boto3.resource('ec2').snapshots.filter(Filters=filters)

    quantity = params['Age'][:-1]
    unit = params['Age'][-1]

    if unit == 'd':
        delta = datetime.timedelta(days=int(quantity))
    elif unit == 'h':
        delta = datetime.timedelta(hours=int(quantity))
    elif unit == 'w':
        delta = datetime.timedelta(weeks=int(quantity))
    else:
        raise RuntimeError('Unsupported time unit')

    now = datetime.datetime.utcnow()
    old_snapshots = [snapshot for snapshot in snapshots if (now - snapshot.start_time.replace(tzinfo=None)) > delta]

    logger.info('Deleting {} {} snapshots older than {}'.format(len(old_snapshots), params['SnapshotType'], delta))
    for snapshot in old_snapshots:
        print('Deleting snapshot {}'.format(snapshot.snapshot_id))
        snapshot.delete()
        time.sleep(0.5)


def handler(event, context):

    if 'SnapshotType' not in event or event['SnapshotType'] not in ['live', 'offline', 'orchestration']:
        logger.error('SnapshotType [live|offline] must be specified')
        raise RuntimeError('\'SnapshotType\' is expected in inputs and have value of \'live\', \'offline\', or \'orchestration\'')

    if 'Age' not in event or not re.match(r'^\d+[hdw]$', event['Age'], re.I):
        logger.error('Age must be specified in xx[h|d|m] format')
        raise RuntimeError('\'Age\' is expected in inputs and in correct format')

    purge_old_snapshots(event)
