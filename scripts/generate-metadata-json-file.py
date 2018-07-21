#!/usr/bin/env python
import sys, os, argparse, textwrap, hashlib, json

__version__ = '0.1'

def unwrap(txt):
    return ' '.join(textwrap.wrap(textwrap.dedent(txt).strip()))

def parse_args():
    p = argparse.ArgumentParser(
        description=unwrap("""
            Generates a metadata file containing md5, sha256 and sha512
            hash values. This is output as a JSON file.
        """),
    )
    p.add_argument(
        '--version', '-v',
        action  = 'version',
        version = '%(prog)s {0}'.format(__version__),
        help    = 'Show version information and exit.',
    )
    p.add_argument(
        '--input', '-i',
        metavar = 'FILE',
        default = None,
        help    = 'Required: Input file to be hashed.',
        required = True,
    )
    p.add_argument(
        '--outpath', '-o',
        metavar = 'FILE',
        default = None,
        help    = 'Required: Output file path for hash values.',
        required = True,
    )
    p.add_argument(
        '--outfile', '-OF',
        metavar = 'FILE',
        default = None,
        help    = 'Required: Output file name for hash values.',
        required = True,
    )
    return p.parse_args()

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

# Calculate sha512 has and return
def sha512Checksum(filePath):
    with open(filePath, 'rb') as fh:
        contents = fh.read()
        m = hashlib.sha512(contents)
    return m.hexdigest()

def main():
    args = parse_args()

    # Checking to see if the input file exists. If not, we exit gracefully
    if os.path.exists(args.input):
        # Generating hash values
        file_md5    = md5Checksum(args.input)
        file_sha256 = sha256Checksum(args.input)
        file_sha512 = sha512Checksum(args.input)

        # Create JSON data
        data = { 'md5': file_md5, 'sha256': file_sha256, 'sha512': file_sha512 }
        jstr = json.dumps(data, indent=4)
    else:
        print("{} is not a valid file".format(args.input))
        raise SystemExit(1)

    # Checking if the output path is valid, if not we exit gracefully
    if os.path.exists(args.outpath):
        filename = args.outpath + '/' + args.outfile
        # Output to json file
        with open(filename, 'w') as outfile:
            json.dump(data, outfile)
    else:
        print("{} is not a valid dir".format(args.outpath))
        raise SystemExit(1)

if __name__ == '__main__':
    main()
