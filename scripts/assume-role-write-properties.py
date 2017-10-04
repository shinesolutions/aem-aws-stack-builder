#!/usr/bin/env python
import sys, os, logging, argparse, boto3, socket, textwrap
from urlparse import urlparse
from socket import gethostname as ghn

__version__ = '0.1'
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
        stream = sys.stderr,
        format = '%(asctime)s ' + ghn() + ' %(levelname)-8s %(message)s',
        datefmt = "%Y-%m-%d %H:%M:%S",
        level = logging.NOTSET,
    )
log = logging.getLogger(os.path.basename(sys.argv[0]))


def clamp(low, x, high):
    return low if x < low else high if x > high else x


def unwrap(txt):
    return ' '.join(textwrap.wrap(textwrap.dedent(txt).strip()))


def set_logging_level(quiet, verbose):
    level_adj = (quiet - verbose) * 10
    new_level = clamp(
        logging.NOTSET,
        logging.WARNING + level_adj,
        logging.CRITICAL
    )
    for handler in getattr(logging.getLogger(), 'handlers', []):
        handler.setLevel(new_level)
        cls_name = handler.__class__.__name__
        log.debug('Set %s handler level to %d', cls_name, new_level)


def parse_args():
    p = argparse.ArgumentParser(
        description=unwrap("""
            Assume a role using the AWS STS service and write the temporary
            credentials to a properties file.
        """),
    )
    p.add_argument(
        '--profile', '-p',
        metavar = 'NAME',
        default = None,
        help    = unwrap("""
            Use a profile to perform the assume-role operation. If not
            specified, the default credential search order is used.
        """),
    )
    p.add_argument(
        '--role', '-r',
        metavar  = 'ARN',
        required = True,
        help     = unwrap("""
            ARN of an IAM role to assume before performing the copy operation.
        """),
    )
    p.add_argument(
        '--session-name',
        metavar = 'NAME',
        default = 'assume-role-write-properties',
        help    = unwrap("""
            The session name to use when assuming the role. Defaults to
            'assume-role-write-properties'.
        """),
    )

    p.add_argument(
        '--verbose', '-v',
        action  = 'count',
        default = 0,
        help    = 'Be more verbose.',
    )
    p.add_argument(
        '--quiet', '-q',
        action  = 'count',
        default = 0,
        help    = 'Be less verbose.',
    )
    p.add_argument(
        '--version', '-V',
        action  = 'version',
        version = '%(prog)s {0}'.format(__version__),
        help    = 'Show version information and exit.',
    )

    p.add_argument(
        '--output', '-o',
        metavar = 'FILE',
        default = None,
        help    = 'Properties file to write temporary credentials to.',
    )

    return p.parse_args()


def main():
    args = parse_args()
    set_logging_level(args.quiet, args.verbose)
    log.debug('Args: %r', args)

    session = boto3.Session(profile_name=args.profile)
    exported_keys = [
        'AccessKeyId', 'SecretAccessKey', 'SessionToken', 'Expiration',
    ]

    sts = session.client('sts')
    assumed_role = sts.assume_role(
        RoleArn         = args.role,
        RoleSessionName = args.session_name,
    )
    credentials = assumed_role.get('Credentials', {})
    credentials['Expiration'] = credentials['Expiration'].isoformat()

    out = sys.stdout if args.output is None else open(args.output, 'w')

    for k in exported_keys:
        out.write('{0}={1}\n'.format(k, credentials.get(k)))

if __name__ == '__main__':
    main()
