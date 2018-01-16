#!/usr/bin/env python
import sys, os, logging, argparse, socket, textwrap, boto3

__version__='0.1'
try:
  import coloredlogs
  coloredlogs.install(
    isatty = True,
    show_name = False,
    show_severity = False,
    level = logging.NOTSET,
    severity_to_style = { 'DEBUG': {'color': 'blue'}},
  )
except:
  logging.basicConfig(
    stream = sys.stdout,
    format = '%(asctime)s ' + socket.gethostname() + ' %(levelname)-8s %(message)s',
    datefmt = "%Y-%m-%d %H:%M:%S",
    level = logging.NOTSET,
  )
log = logging.getLogger(__name__)

def find_autoscaling_group(client, component, stack_prefix):
  groups = client.describe_auto_scaling_groups()['AutoScalingGroups']
  for group in groups:
    count_found = 0
    for tag in group['Tags']:
      if (tag['Key'] == 'StackPrefix' and tag['Value'] == stack_prefix) or \
          (tag['Key'] == 'Component' and tag['Value'] == component):
        if count_found == 1:
          log.debug('Autoscaling Group: %r', group)
          return group
        else:
          count_found += 1
  raise ValueError('No Autoscaling Group found for stack_prefix: {} and component: {}.'.format(stack_prefix, component))

def update_snapshot_id(launch_config, device_name, snapshot_id):
  launch_config.pop('LaunchConfigurationARN')
  launch_config.pop('CreatedTime')
  launch_config.pop('KernelId')
  launch_config.pop('RamdiskId')
  devices = launch_config['BlockDeviceMappings']
  for device in devices:
    if device['DeviceName'] == device_name:
      ebs = device['Ebs']
      ebs['SnapshotId'] = snapshot_id

def find_launch_conf(client, launch_conf_name):
  launch_conf = \
  client.describe_launch_configurations(LaunchConfigurationNames=[launch_conf_name])['LaunchConfigurations'][0]
  log.debug('Launch Configuration to update: %r', launch_conf)
  return launch_conf

def delete_launch_conf(client, launch_conf_name):
  client.delete_launch_configuration(LaunchConfigurationName=launch_conf_name)

def update_autoscaling_group(client, group_name, launch_conf_name):
  client.update_auto_scaling_group(
    AutoScalingGroupName=group_name,
    LaunchConfigurationName=launch_conf_name
  )

def create_launch_conf(client, launch_config, new_launch_config_name):
  launch_config['LaunchConfigurationName'] = new_launch_config_name
  client.create_launch_configuration(**launch_config)

def repoint_autoscaling_group(client, group_name, launch_config, new_launch_config_name):
  create_launch_conf(client, launch_config, new_launch_config_name)
  update_autoscaling_group(client, group_name, new_launch_config_name)

def update_snapshot_id_to_launch_conf(snapshot_id, component, stack_prefix, device_name):
  client = boto3.client('autoscaling')
  group = find_autoscaling_group(client, component, stack_prefix)
  group_name = group['AutoScalingGroupName']
  launch_conf_name = group['LaunchConfigurationName']
  temp_launch_config_name = launch_conf_name + "-temp"
  launch_config = find_launch_conf(client, launch_conf_name)
  update_snapshot_id(launch_config, device_name, snapshot_id)
  # create a temp Launch conf and point the autoscaling group to it
  repoint_autoscaling_group(client, group_name, launch_config, temp_launch_config_name)
  # delete old launch conf
  delete_launch_conf(client, launch_conf_name)
  # create a the new Launch conf (with the same old name) and point the autoscaling group to it
  repoint_autoscaling_group(client, group_name, launch_config, launch_conf_name)
  # delete the temp launch conf
  delete_launch_conf(client, temp_launch_config_name)

def set_logging_level(quiet, verbose):
  level_adj = (quiet - verbose) * 10
  new_level = clamp(logging.NOTSET, logging.WARNING + level_adj, logging.CRITICAL)
  for handler in getattr(logging.getLogger(), 'handlers', []):
    handler.setLevel(new_level)
    log.debug('Set %s handler level to %d', handler.__class__.__name__, new_level)

def unwrap(txt):
  return ' '.join(textwrap.wrap(textwrap.dedent(txt).strip()))

def clamp(low, x, high):
  return low if x < low else high if x > high else x

def parse_args():
  p = argparse.ArgumentParser(
    description=unwrap("""
            Updates the Snapshot Id in the Launch Configuration attached to
            the Autoscaling group for the Component and Stack-prefix
            provided.
        """)
  )
  p.add_argument(
    '--component', '-c',
    required = True,
    metavar = 'author-dispatcher|author-primary|author-standby|chaos-monkey|orchestrator|publish|publish-dispatcher',
    help     = unwrap("""
            The Component name. Required.
        """),
  )
  p.add_argument(
    '--stack-prefix', '-sp',
    metavar = 'sandpit-xxx',
    required = True,
    help     = unwrap("""
            The Stack Prefix name. Required.
        """),
  )
  p.add_argument(
    '--device', '-d',
    metavar = '/dev/xxx',
    required = True,
    help     = unwrap("""
            The device to attach the snapshot-id provided. Required.
        """),
  )
  p.add_argument(
    '--snapshot-id', '-s',
    required = True,
    metavar = 'snap-xxxxxxxx',
    help    = unwrap("""
            EBS snapshot-id to be attached to the Launch configuration. Required.
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

  args = p.parse_args()
  return args

def main():
  log = logging.getLogger(os.path.basename(sys.argv[0]))
  args = parse_args()
  set_logging_level(args.quiet, args.verbose)
  log.debug('Args: %r', args)
  update_snapshot_id_to_launch_conf(args.snapshot_id, args.component, args.stack_prefix, args.device)

if __name__ == '__main__':
  main()

# AWS_PROFILE=sandpit python update-snapshot-id-in-launch-conf.py -c publish -s snap-1234567890abcdef1 -sp sandpit-ramses001 -d /dev/sdb
