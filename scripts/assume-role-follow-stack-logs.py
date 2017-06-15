#!/usr/bin/env python
import argparse, re, time
from assume_role_lib import log, sts
from assume_role_lib.util import unwrap
from datetime import datetime, timedelta

__version__ = '0.1'
logger = None

def add_arguments(argument_parser):
    argument_parser.add_argument(
        '--version', '-V',
        action  = 'version',
        version = '%(prog)s {0}'.format(__version__),
        help    = 'Show version information and exit.',
    )

    argument_parser.add_argument(
        '--describe-instances-filter',
        metavar = 'FILTER',
        action  = 'append',
        default = [ 'Name=instance-state-name,Values=pending,running' ],
        help    = unwrap("""
            Filters to apply when searching for instances whose logs will be
            searched. At the very least you should add a filter for the
            StackPrefix: Name=tag:StackPrefix,Values=<stack_prefix>.
        """)
    )
    argument_parser.add_argument(
        '--log-group',
        metavar = 'NAME',
        default = '/var/log/cloud-init-output.log',
        help    = 'The log group to search in.',
    )
    argument_parser.add_argument(
        '--timeout',
        metavar = 'TIME',
        default = '15m',
        help    = unwrap("""
            Stack timeout: XXn; for n - d = days, h = hour, m = mins, s =
            seconds.
        """)
    )

def parse_filter(filter):
    logger.debug('parse_filter: Parsing %r', filter)
    match = re.match(r'^Name=(?P<Name>[^,]+),Values=(?P<Values>.*)$', filter)
    if match:
        filters = match.groupdict()
        return filters['Name'], filters['Values'].split(',')
    else:
        return ()

def parse_timeout(timeout):
    days, hours, minutes, seconds = 0, 0, 0, 0
    findall = re.findall(r'([0-9]+)([dhms])', timeout.lower())
    for number, unit in findall:
        number = int(number)
        if unit == 'd':
            days = number
        elif unit == 'h':
            hours = number
        elif unit == 'm':
            minutes = number
        elif unit == 's':
            seconds = number
    return timedelta(days, seconds, 0, 0, minutes, hours)

def find_instances(ec2, args):
    filters = dict((
        parse_filter(f) for f in args.describe_instances_filter
    ))
    logger.debug('Filters: %r', filters)

    instances = list(ec2.instances.filter(
        Filters = [ {'Name': k, 'Values': v} for k,v in filters.iteritems() ]
    ))

    return ( instance(i) for i in instances )

class instance(object):
    _component = None
    def __init__(self, instance_info):
        self._info = instance_info

    def __repr__(self):
        return 'instance(id = {0}, component = {1})'.format(self.id, self.component)

    @property
    def id(self):
        return self._info.id

    @property
    def component(self):
        if self._component is None:
            component = {
                t['Key']: t['Value'] for t in self._info.tags
            }.get('Component', 'unknown')
            self._component = component
        return self._component

serverspec_re = re.compile(r'(?P<examples>[0-9]+) examples?, (?P<failures>[0-9]+) failures?')
def parse_event_message(message):
    for line in message.splitlines():
        match = serverspec_re.match(line)
        if match:
            d = match.groupdict()
            examples = int(d['examples'])
            failures = int(d['failures'])
            return line, examples, failures
    return None, None, None

def main():
    global logger
    p = argparse.ArgumentParser(
        description=unwrap("""
            Tail CloudWatch Logs for a stack, looking for ServerSpec test
            output lines. Will exit non-zero if ServerSpec test failures are
            detected.
        """),
    )
    sts.add_arguments(p)
    log.add_arguments(p)
    add_arguments(p)
    args = p.parse_args()

    logger = log.get_logger(args)
    logger.debug('Args: %r', args)
    session = sts.get_session(args)

    ec2 = session.resource('ec2')
    instances = { i.id: i for i in find_instances(ec2, args) }
    logger.info(
        'Found %d instances: %r', len(instances), instances
    )
    instance_ids = set( instances.iterkeys() )
    complete_instance_ids = set()

    cwlogs = session.client('logs')
    filter_log_events_args = dict(
        logGroupName = args.log_group,
        filterPattern = 'example',
    )
    all_examples, all_failures = 0, 0
    remaining_instance_ids = instance_ids - complete_instance_ids
    timeout = datetime.now() + parse_timeout(args.timeout)
    while remaining_instance_ids:
        logger.info('Waiting for %d instances to complete ServerSpec tests.', len(remaining_instance_ids))
        logger.debug('%r', remaining_instance_ids)
        filter_log_events_args['logStreamNames'] = list(remaining_instance_ids)
        try:
            filtered_events = cwlogs.filter_log_events(**filter_log_events_args)
            events = filtered_events['events']
        except:
            logger.exception('Caught an exception while polling for log events.')
            events = []
        for event in events:
            instance = instances[event['logStreamName']]
            matched, ex, fa = parse_event_message(event['message'])
            if matched:
                complete_instance_ids.add(event['logStreamName'])
                all_examples += ex
                all_failures += fa
                if fa > 0:
                    logger.error(
                        'Error in ServerSpec for %r - %s',
                        instance, matched
                    )
                else:
                    logger.info(
                        'ServerSpec complete for %r - %s',
                        instance, matched
                    )
        remaining_instance_ids = instance_ids - complete_instance_ids
        if datetime.now() > timeout:
            logger.error('Timeout waiting for stack to complete. %d instances have not completed.', len(remaining_instance_ids))
            for instance in remaining_instance_ids:
                logger.error('ServerSpec did not complete on %r', instances[instance])
            raise SystemExit(2)
        if len(events) == 0:
            time.sleep(10)
        else:
            time.sleep(1)

    if all_failures > 0:
        raise SystemExit(1)

if __name__ == '__main__':
    main()
