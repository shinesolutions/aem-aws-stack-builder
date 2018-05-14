#!/usr/bin/env python
import sys, json, yaml

class CFFunctionYAMLObject(yaml.YAMLObject):
#    yaml_loader = yaml.Loader
#    yaml_dumper = yaml.Dumper

    @classmethod
    def from_yaml(cls, loader, node):
        if node.tag == u'!Ref':
            key = u'Ref'
        else:
            key = node.tag.replace('!', 'Fn::')

        val = node.value
        return {key: val}

    @classmethod
    def to_yaml(cls, dumper, data):
        return data

class CFSub(CFFunctionYAMLObject):
    yaml_tag = u'!Sub'

class CFRef(CFFunctionYAMLObject):
    yaml_tag = u'!Ref'

class CFJoin(CFFunctionYAMLObject):
    yaml_tag = u'!Join'

if len(sys.argv) == 1:
    f = sys.stdin
else:
    f = open(sys.argv[1], 'r')
json.dump(yaml.load(f), sys.stdout)
