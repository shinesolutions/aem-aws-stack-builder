#!/usr/bin/env python3

import sys, os, argparse, yaml, boto3
from dateutil.parser import parse as parse_dt

p = argparse.ArgumentParser()
p.add_argument('--outfile', '-o', metavar = 'FILE', help = 'The file to write output to. Use "-" for stdout', default = 'stage/ami-ids.yaml')
p.add_argument('--filter-file', '-f', metavar = 'FILE', help = 'A JSON or YAML file containing AMI filters', default = None)
args = p.parse_args()

def most_recent_ami(ami_name, filterList):
    filters = []
    for filter in filterList:
        name, _, values = filter.partition(',')
        _, _, name = name.partition('=')
        _, _, values = values.partition('=')
        filters.append({
            'Name': name.strip(),
            'Values': [x.strip() for x in values.split(',')]
        })

    ec2 = boto3.resource('ec2')

    most_recent_image = None
    for image in ec2.images.filter(Filters=filters):
        if most_recent_image is None:
            most_recent_image = image
            continue
        if parse_dt(image.creation_date) > parse_dt(most_recent_image.creation_date):
            most_recent_image = image

    if most_recent_image is None:
        sys.stderr.write('No images matched filters provided.\n')
        raise SystemExit(1)

    sys.stderr.write('{0}: {1.id}{2}'.format(ami_name, most_recent_image, '\n'))

    return '{0.id}'.format(most_recent_image)


filters = yaml.load(open(args.filter_file)) if args.filter_file else {}

author_ami_id = most_recent_ami('Author AMI', filters.get('author_ami_filters', ["Name=tag:Application Role,Values=author AMI"]))
publish_ami_id = most_recent_ami('Publish AMI', filters.get('publish_ami_id', ["Name=tag:Application Role,Values=publish AMI"]))
dispatcher_ami_id = most_recent_ami('Dispatcher AMI', filters.get('dispatcher_ami_id', ["Name=tag:Application Role,Values=dispatcher AMI"]))
java_ami_id = most_recent_ami('Java AMI', filters.get('java_ami_id', ["Name=tag:Application Role,Values=java AMI"]))

if args.outfile == '-':
    outfile = sys.stdout
else:
    outfile = open(args.outfile, 'w')

yaml.dump({
    'ami_ids': {
        'author_dispatcher': dispatcher_ami_id,
        'publish_dispatcher': dispatcher_ami_id,
        'publish': publish_ami_id,
        'author': author_ami_id,
        'orchestrator': java_ami_id,
        'chaos_monkey': java_ami_id,
    }
}, outfile, default_flow_style=False)
