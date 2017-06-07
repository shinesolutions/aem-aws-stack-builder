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
        stream = sys.stdout,
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
            Copy files between the local system and S3, or directly between
            locations in S3. Optionally, assume an IAM role before performing
            the copy operation. This command does _not_ handle recursive
            copies.
        """),
    )
    p.add_argument(
        '--profile', '-p',
        metavar = 'NAME',
        default = None,
        help    = unwrap("""
            Use a profile to perform the copy or assume-role operation. If not
            specified, the default credential search order is used.
        """),
    )
    p.add_argument(
        '--assume-role', '-a',
        metavar = 'ARN',
        default = None,
        help    = unwrap("""
            ARN of an IAM role to assume before performing the copy operation.
        """),
    )
    p.add_argument(
        '--assume-role-session-name',
        metavar = 'NAME',
        default = 'assume-role-s3-copy',
        help    = unwrap("""
            The session name to use when assuming the role. Defaults to
            'assume-role-s3-copy'.
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
        'source',
        metavar = 'SRC',
        help    = 'A local path or s3://<bucket>/<path> URL.',
    )
    p.add_argument(
        'destination',
        metavar = 'DST',
        help    = 'A local path or s3://<bucket>/<path> URL.',
    )

    return p.parse_args()


def resolve_local_path(path, copy_basename_from = '', create_missing_dirs = False):
    log.debug('resolve_local_path "%s" "%s"', path, copy_basename_from)
    path = os.path.expanduser(path)
    basename = os.path.basename(copy_basename_from)
    if not os.path.exists(path):
        if create_missing_dirs and path.endswith('/'):
            os.makedirs(path)
        else:
            log.error('Local path does not exist: %s', path)
            raise SystemExit(1)
    if os.path.isdir(path):
        path = os.path.join(path, basename)
    path = os.path.abspath(path)
    return path


def resolve_s3_key(key, copy_basename_from = ''):
    log.debug('resolve_s3_key "%s" "%s"', key, copy_basename_from)
    key = key.lstrip('/')
    basename = os.path.basename(copy_basename_from)
    if key == '':
        if copy_basename_from:
            return basename
        else:
            log.error('S3 key cannot be blank.')
            raise SystemExit(1)
    if key.endswith('/'):
        key = os.path.join(key, basename)
    return key


def main():
    args = parse_args()
    set_logging_level(args.quiet, args.verbose)
    log.debug('Args: %r', args)

    session = boto3.Session(profile_name=args.profile)

    if args.assume_role is not None:
        sts = session.client('sts')
        assumed_role = sts.assume_role(
            RoleArn         = args.assume_role,
            RoleSessionName = args.assume_role_session_name,
        )
        credentials = assumed_role.get('Credentials', {})
        session = boto3.Session(
            aws_access_key_id     = credentials.get('AccessKeyId', ''),
            aws_secret_access_key = credentials.get('SecretAccessKey', ''),
            aws_session_token     = credentials.get('SessionToken', ''),
        )
    s3 = session.client('s3')

    source      = urlparse(args.source)
    destination = urlparse(args.destination)

    if source.scheme == 's3' and destination.scheme == 's3':
        copy_source = {
            'Bucket': source.netloc,
            'Key': resolve_s3_key(source.path),
        }
        bucket     = destination.netloc
        key        = resolve_s3_key(destination.path, copy_source.get('Key'))
        log.debug('Copy %r => %s : %s', copy_source, bucket, key)
        s3.copy(copy_source, bucket, key)
    elif source.scheme == 's3':
        bucket     = source.netloc
        key        = resolve_s3_key(source.path)
        local_path = resolve_local_path(destination.path, source.path, True)
        log.debug('Download %s : %s => %s', bucket, key, local_path)
        s3.download_file(bucket, key, local_path)
    elif destination.scheme == 's3':
        local_path = resolve_local_path(source.path)
        bucket     = destination.netloc
        key        = resolve_s3_key(destination.path, local_path)
        log.debug('Upload %s => %s : %s', local_path, bucket, key)
        s3.upload_file(local_path, bucket, key)
    else:
        log.error('At least one of source or destination must be an S3 URL.')
        raise SystemExit(1)

if __name__ == '__main__':
    main()
