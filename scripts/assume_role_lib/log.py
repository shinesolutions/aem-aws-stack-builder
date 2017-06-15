#!/usr/bin/env python
import sys, os, logging
from socket import gethostname as ghn
from .util import clamp
import boto3 # Only here to ensure boto3 loggers are created

_default_logger_name = os.path.basename(sys.argv[0]).replace('.py', '')

def add_arguments(argument_parser):
    argument_parser.add_argument(
        '--quiet', '-q',
        action  = 'count',
        default = 0,
        help    = 'Be less verbose.',
    )
    argument_parser.add_argument(
        '--verbose', '-v',
        action  = 'count',
        default = 0,
        help    = 'Be more verbose.',
    )

def get_logger(args, name = _default_logger_name):
    try:
        import coloredlogs
        coloredlogs.install(
            isatty = True,
            show_name = False,
            show_severity = False,
            level = logging.NOTSET,
            severity_to_style = {'DEBUG': {'color': 'blue'}},
        )
    except:
        logging.basicConfig(
            stream = sys.stdout,
            format = '%(asctime)s ' + ghn() + ' %(levelname)-8s %(message)s',
            datefmt = "%Y-%m-%d %H:%M:%S",
            level = logging.NOTSET,
        )
    _set_logging_level(args.quiet, args.verbose)
    return logging.getLogger(name)

def _set_logging_level(quiet, verbose):
    level_adj = (quiet - verbose) * 10
    new_level = clamp(
        logging.NOTSET,
        logging.WARNING + level_adj,
        logging.CRITICAL
    )
    for handler in getattr(logging.getLogger(), 'handlers', []):
        handler.setLevel(new_level)
    boto_level = clamp(
        logging.NOTSET,
        logging.WARNING + (level_adj + 20),
        logging.CRITICAL
    )
    for boto_logger in ('boto3', 'botocore', 's3transfer'):
        logging.getLogger(boto_logger).setLevel(boto_level)
