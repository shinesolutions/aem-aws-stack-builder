#!/usr/bin/env python
import argparse, re, time
from assume_role_lib import log, sts
from assume_role_lib.util import unwrap
from datetime import datetime, timedelta
from collections import Counter as counter

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
        '--timeout',
        metavar = 'TIME',
        default = '15m',
        help    = unwrap("""
            Stack timeout: XXn; for n - d = days, h = hour, m = mins, s =
            seconds.
        """)
    )
    argument_parser.add_argument(
        'elb',
        metavar = 'NAME',
        nargs   = '+',
        help    = unwrap("""
            The ELB to watch. Multiple are allowed.
        """)
    )

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

def get_elb_instance_info(elb, elb_client):
    instance_health = elb_client.describe_instance_health(
        LoadBalancerName = elb,
    ).get('InstanceStates', [])
    instance_states = counter(( i.get('State') for i in instance_health ))
    return len(instance_health), instance_states

def main():
    global logger
    p = argparse.ArgumentParser(
        description=unwrap("""
            Wait for all instances added to an ELB to come into service. Exits
            non-zero if there are no instances added to an ELB.
        """),
    )
    sts.add_arguments(p)
    log.add_arguments(p)
    add_arguments(p)
    args = p.parse_args()

    logger = log.get_logger(args)
    logger.debug('Args: %r', args)
    session = sts.get_session(args)

    elb_client = session.client('elb')

    elbs = set( args.elb )
    complete_elbs = set()
    remaining_elbs = elbs - complete_elbs
    timeout = datetime.now() + parse_timeout(args.timeout)
    while remaining_elbs:
        for elb in remaining_elbs:
            count, states = get_elb_instance_info(elb, elb_client)
            logger.debug('%s: %r', elb, states)
            if states.get('InService') == count:
                complete_elbs.add(elb)
                logger.info(
                    '%s has %d of %d instances in service',
                    elb, states.get('InService', 0), count,
                )
        remaining_elbs = elbs - complete_elbs
        if remaining_elbs:
            if datetime.now() > timeout:
                logger.error(
                    'Timeout waiting for ELBs. %d have not completed.',
                    len(remaining_elbs),
                )
                for elb in remaining_elbs:
                    count, states = get_elb_instance_info(elb, elb_client)
                    logger.error(
                        '%s has only %d of %d instances in service',
                        elb, states.get('InService', 0), count,
                    )
                raise SystemExit(2)
            logger.info('Waiting for %d ELB\'s instances to come into service.', len(remaining_elbs))
            logger.debug('%r', remaining_elbs)
            time.sleep(15)


if __name__ == '__main__':
    main()

