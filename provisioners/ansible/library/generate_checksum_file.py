#!/usr/bin/python3

from ansible.module_utils.basic import *
import sys, os, hashlib, json, yaml

# Calculate md5 hash and return
def md5Checksum(filePath):
    with open(filePath, 'rb') as fh:
        m = hashlib.md5()
        while True:
            data = fh.read(8192)
            if not data:
                break
            m.update(data)
        return m.hexdigest()

# Calculate sha256 hash and return
def sha256Checksum(filePath):
    with open(filePath, 'rb') as fh:
        contents = fh.read()
        m = hashlib.sha256(contents)
    return m.hexdigest()

# Calculate sha512 hash and return
def sha512Checksum(filePath):
    with open(filePath, 'rb') as fh:
        contents = fh.read()
        m = hashlib.sha512(contents)
    return m.hexdigest()

def checkPathExists(filePath):
    if os.path.exists(filePath):
        return True
    else:
        return False

def generateChecksumData(checksumType, source):
    if checksumType == 'all':
        return { 'md5': md5Checksum(source), 'sha256': sha256Checksum(source), 'sha512': sha512Checksum(source) }
    elif checksumType == 'md5':
        return { 'md5': md5Checksum(source) }
    elif checksumType == 'sha256':
        return { 'sha256': sha256Checksum(source) }
    else:
        return { 'sha512': sha512Checksum(source) }

def toJSONFile(outData, outFile):
    with open(outFile, 'w') as out:
        json.dump(outData, out, indent=4)

def toYAMLFile(outData, outFile):
    with open(outFile, 'w') as out:
        out.write('---\n')
        yaml.safe_dump(outData, out, default_flow_style=False)

def main():
    module = AnsibleModule(
      argument_spec = dict(
        src             = dict(required=True, type='str'),
        dest_path       = dict(required=True, type='str'),
        dest_file       = dict(required=True, type='str'),
        outfile_type    = dict(required=False, choices=['json', 'yaml'], default='json'),
        checksum_type   = dict(required=False, choices=['all', 'md5', 'sha256', 'sha512'], default='all'),
      )
    )

    # Some file/path checks on what is passed to the module
    if checkPathExists(module.params['src']) == False:
        message = 'Source file {0} does not exist at the supplied location' % [module.params['src']]
        module.exit_json(changed = False, msg = message)
    elif checkPathExists(module.params['dest_path']) == False:
        message = 'Destination path {0} does not exist at the supplied location' % [module.params['dest_path']]
        module.exit_json(changed = False, msg = message)
    else:
        # Checking what checksum tupe has been chosen and generating data var based on checksum type
        data = generateChecksumData(module.params['checksum_type'], module.params['src'])
        # Generating the outfile name with full path
        filename = module.params['dest_path'] + '/' + module.params['dest_file']

        if module.params['outfile_type'] == 'yaml':
            toYAMLFile(data, filename)
        else:
            toJSONFile(data, filename)

        message = 'Generated checksum file: {0}'.format(filename)
        module.exit_json(changed = True, msg = message)

if __name__ == '__main__':
    main()
