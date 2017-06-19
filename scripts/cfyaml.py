try:
    from yaml import YAMLObject, ScalarNode, SequenceNode, MappingNode, Loader, Dumper
    import yaml
except ImportError:
    from ruamel.yaml import YAMLObject, ScalarNode, SequenceNode, MappingNode, Loader, Dumper
    import ruamel.yaml as yaml
    import warnings
    warnings.simplefilter('ignore', yaml.error.UnsafeLoaderWarning)

class CFFunctionYAMLObject(YAMLObject):
    yaml_loader = Loader
    yaml_dumper = Dumper

    @classmethod
    def from_yaml(cls, loader, node):
        key = node.tag[1:]
        if node.tag not in ('!Ref', '!Condition'):
            key = 'Fn::' + key
        if isinstance(node, ScalarNode):
            val = loader.construct_scalar(node)
        elif isinstance(node, SequenceNode):
            val = loader.construct_sequence(node)
        elif isinstance(node, MappingNode):
            val = loader.construct_mapping(node)
        else:
            raise Exception("Unable to handle node: %r"%node)
        return {str(key): str(val)}

    @classmethod
    def to_yaml(cls, dumper, data):
        return data

class CFSub(CFFunctionYAMLObject):
    yaml_tag = u'!Sub'

class CFRef(CFFunctionYAMLObject):
    yaml_tag = u'!Ref'

class CFJoin(CFFunctionYAMLObject):
    yaml_tag = u'!Join'

class CFNot(CFFunctionYAMLObject):
    yaml_tag = u'!Not'

class CFEquals(CFFunctionYAMLObject):
    yaml_tag = u'!Equals'
