#!/usr/bin/env python3
import sys, os, boto3
from .util import unwrap

_default_session_name = os.path.basename(sys.argv[0]).replace('.py', '')

def add_arguments(argument_parser):
    argument_parser.add_argument(
        '--profile', '-p',
        metavar = 'NAME',
        default = None,
        help    = unwrap("""
            Use an AWS configuration profile for IAM credentials. If not
            specified, the default credential search order is used. If a role
            is specified, these credentials are used to assume the role.
        """),
    )
    argument_parser.add_argument(
        '--role', '-r',
        metavar = 'ARN',
        default = None,
        help    = unwrap("""
            ARN of an IAM role to assume before performing the copy operation.
        """),
    )
    argument_parser.add_argument(
        '--session-name', '-s',
        metavar = 'NAME',
        default = _default_session_name,
        help    = unwrap("""
            "The session name to use when assuming the role. Defaults to '{0}'.
        """.format(_default_session_name)),
    )

def get_session(args):
    session = boto3.Session(profile_name=args.profile)
    if args.role is not None:
        sts = session.client('sts')
        assumed_role = sts.assume_role(
            RoleArn         = args.role,
            RoleSessionName = args.session_name,
        )
        credentials = assumed_role.get('Credentials', {})
        session = boto3.Session(
            aws_access_key_id     = credentials.get('AccessKeyId', ''),
            aws_secret_access_key = credentials.get('SecretAccessKey', ''),
            aws_session_token     = credentials.get('SessionToken', ''),
        )
    return session
