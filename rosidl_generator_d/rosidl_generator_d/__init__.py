# Copyright 2020 nonanonno
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import os
import pathlib
import sys
from collections import OrderedDict
from rosidl_cmake import get_newest_modification_time, expand_template, read_generator_arguments
from rosidl_parser.definition import IdlLocator, \
    IdlContent, \
    Message, \
    Service, \
    Action, \
    BasicType, \
    AbstractNestedType, \
    AbstractString, \
    AbstractWString, \
    NamespacedType, \
    UnboundedSequence, \
    BoundedSequence, \
    Array
from rosidl_parser.parser import parse_idl_file


def generate_d_files(
    generator_arguments_file: hash,
    mapping: hash
):
    args = read_generator_arguments(generator_arguments_file)

    template_basepath = pathlib.Path(args['template_dir'])
    for template_filename in mapping.keys():
        assert(template_basepath / template_filename).exists(), \
            'Could no find template: ' + template_filename

    latest_target_timestamp = get_newest_modification_time(
        args['target_dependencies'])
    generated_files = []

    # correct msgs, srvs, actions
    idl_content = IdlContent()
    for idl_tuple in args.get('idl_tuples', []):
        idl_parts = idl_tuple.rsplit(':', 1)
        assert len(idl_parts) == 2

        idl_content.elements += parse_idl_file(
            IdlLocator(*idl_parts)).content.elements

    idl_data = {
        'msg': [msg for msg in idl_content.get_elements_of_type(Message)],
        'srv': [msg for msg in idl_content.get_elements_of_type(Service)],
        'action': [msg for msg in idl_content.get_elements_of_type(Action)],
    }

    generated_files = []

    # interfaces
    for type_, contents in idl_data.items():
        data = {
            'type_': type_,
            'package_name': args['package_name'],
            'contents': contents
        }
        try:
            for template_file, generated_filename in mapping.items():
                generated_file = os.path.join(
                    args['output_dir'], generated_filename % type_)
                generated_files.append(generated_file)
                expand_template(
                    os.path.basename(template_file),
                    data,
                    generated_file,
                    minimum_timestamp=latest_target_timestamp,
                    template_basepath=template_basepath
                )
        except Exception as e:
            print('Error processing idl file', file=sys.stderr)
            raise(e)

    # dub
    try:
        generated_file = os.path.join(args['output_dir'], 'dub.json')
        generated_files.append(generated_file)
        expand_template(
            'dub.json.em',
            {
                'package_name': args['package_name'],
                'contents': idl_data['msg'] + idl_data['srv'] + idl_data['action']
            },
            generated_file,
            minimum_timestamp=latest_target_timestamp,
            template_basepath=template_basepath
        )
    except Exception as e:
        print('Error creating dub.json', file=sys.stderr)
        raise(e)

    return generated_files


def generate_d(generator_arguments_file):
    mapping = {
        'idl.d.em': 'source/%s.d',
        'idl_c_interface.d.em': 'source/%s_c_interface.d'
    }
    generate_d_files(generator_arguments_file, mapping)


def value_type_of(type_):
    if isinstance(type_, AbstractNestedType):
        return type_.value_type
    else:
        return type_


def solve_depends(contents, this_module: set) -> set:
    depends = OrderedDict()
    for c in contents:
        if isinstance(c, Service) or isinstance(c, Action):
            continue

        for m in c.structure.members:
            type_ = value_type_of(m.type)
            if isinstance(type_, NamespacedType):
                if type_.namespaces[0] != this_module[0] or type_.namespaces[1] != this_module[1]:
                    depends.setdefault(
                        (type_.namespaces[0], type_.namespaces[1]))
    return depends


def solve_depends_package(contents, package_name: str) -> set:
    depends = OrderedDict()
    for c in contents:
        if isinstance(c, Service) or isinstance(c, Action):
            continue

        for m in c.structure.members:
            type_ = value_type_of(m.type)
            if isinstance(type_, NamespacedType):
                if type_.namespaces[0] != package_name:
                    depends.setdefault(type_.namespaces[0])
    return depends


MSG_TYPE_TO_D = {
    'boolean': 'bool',
    'octet': 'ubyte',
    'char': 'char',
    'wchar': 'wchar',
    'float': 'float',
    'double': 'double',
    'long double': 'real',
    'uint8': 'ubyte',
    'int8': 'byte',
    'uint16': 'ushort',
    'int16': 'short',
    'uint32': 'uint',
    'int32': 'int',
    'uint64': 'ulong',
    'int64': 'long',
    'string': 'string',
    'wstring': 'wstring',
}


def msg_type_only_to_d(type_):
    """
    Convert a message type into the D declaration, ignoring array type.

    Example input: uint32, std_msgs/msg/String, std_msgs/msg/String[3]
    Example output: uint, std_msgs.msg.String, std_msgs.msg.String

    @param type_: The message type
    @type type_: rosidl_parser.Type
    """
    type_ = value_type_of(type_)
    if isinstance(type_, BasicType):
        return MSG_TYPE_TO_D[type_.typename]
    if isinstance(type_, AbstractString):
        return MSG_TYPE_TO_D['string']
    if isinstance(type_, AbstractWString):
        return MSG_TYPE_TO_D['wstring']
    if isinstance(type_, NamespacedType):
        return '.'.join(type_.namespaced_name())
    assert False, type_


def idl_type_to_d(type_):
    """
    Convert a message type into the D declaration, along with the array type.

    Example input: uint32, std_msgs/msg/String, std_msgs/msg/String[3]
    Example output: uint, std_msgs.msg.String, std_msgs.msg.String[3]

    @param type_: The message type
    @type type_: rosidl_parser.Type
    """
    d_type = msg_type_only_to_d(type_)

    if not isinstance(type_, AbstractNestedType):
        return d_type
    if isinstance(type_, UnboundedSequence):
        return '%s[]' % d_type
    if isinstance(type_, BoundedSequence):
        return '%s[]' % (d_type)  # ToDo: Replace to BoundedSequence
    if isinstance(type_, Array):
        return '%s[%u]' % (d_type, type_.size)
    assert False, type_


def msg_type_only_to_c_in_d(type_):
    """
    Convert a message type into the C interface declaration, ignoring array type.

    Example input: uint32, std_msgs/msg/String, std_msgs/msg/String[3]
    Example output: uint, rosidl_runtime_c__String', rosidl_runtime_c__String

    @param type_: The message type
    @type type_: rosidl_parser.Type
    """
    from rosidl_generator_c import idl_structure_type_to_c_typename

    type_ = value_type_of(type_)
    if isinstance(type_, BasicType):
        return MSG_TYPE_TO_D[type_.typename]
    if isinstance(type_, AbstractString):
        return 'rosidl_runtime_c__String'
    if isinstance(type_, AbstractWString):
        return 'rosidl_runtime_c__U16String'
    if isinstance(type_, NamespacedType):
        return idl_structure_type_to_c_typename(type_)
    assert False, type_


def idl_type_to_c_in_d(type_):
    """
    Convert a message type into the C interface declaration, ignoring array type.

    Example input: uint32, std_msgs/msg/String, std_msgs/msg/String[3]
    Example output: uint, rosidl_runtime_c__String', rosidl_runtime_c__String[3]

    @param type_: The message type
    @type type_: rosidl_parser.Type
    """
    from rosidl_generator_c import idl_type_to_c, basetype_to_c

    c_type = basetype_to_c(value_type_of(type_))

    if not isinstance(type_, AbstractNestedType):
        return c_type
    if isinstance(type_, Array):
        return '%s[%d]' % (c_type, type_.size)
    return idl_type_to_c(type_)


def assign_text_d_to_c(member, src: str, dst: str) -> str:
    type_ = value_type_of(member.type)

    if isinstance(type_, BasicType):
        assign = '{0} = {1}'
    elif isinstance(type_, AbstractString):
        assign = 'rosidl_runtime_c__String__assign(&{0}, toStringz({1}))'
    elif isinstance(type_, AbstractWString):
        assign = 'rosidl_runtime_c__U16String__assign(&{0}, cast(const(ushort*))toUTF16z({1}))'
    elif isinstance(type_, NamespacedType):
        assign = msg_type_only_to_d(type_) + '.convert({1}, {0})'
    else:
        assert False, type_

    if isinstance(member.type, AbstractNestedType) and not isinstance(member.type, Array):
        dst_mem = '%s.data' % member.name
    else:
        dst_mem = member.name

    return assign.format(dst % dst_mem, src % member.name)


def assign_text_c_to_d(member, src: str, dst: str) -> str:
    type_ = value_type_of(member.type)

    if isinstance(type_, BasicType):
        assign = '{0} = {1}'
    elif isinstance(type_, AbstractString):
        assign = '{0} = fromStringz({1}.data).dup()'
    elif isinstance(type_, AbstractWString):
        assign = '{0} = fromStringz(cast(const(wchar*)){1}.data).dup()'
    elif isinstance(type_, NamespacedType):
        assign = msg_type_only_to_d(type_) + '.convert({1}, {0})'
    else:
        assert False, type_

    if isinstance(member.type, AbstractNestedType) and not isinstance(member.type, Array):
        src_mem = '%s.data' % member.name
    else:
        src_mem = member.name

    return assign.format(dst % member.name, src % src_mem)


def array_init_text_d_to_c_with_semicolon(member, src: str, dst: str) -> str:
    type_ = member.type
    assert isinstance(type_, AbstractNestedType)

    if isinstance(type_, Array):
        return ''
    if isinstance(type_, UnboundedSequence) or isinstance(type_, BoundedSequence):
        return '{2}__init(&{0}, {1}.length);'.format(
            dst % member.name, src % member.name, idl_type_to_c_in_d(type_))
    assert False, type_


def array_init_text_c_to_d_with_semicolon(member, src: str, dst: str) -> str:
    type_ = member.type
    assert isinstance(type_, AbstractNestedType)

    if isinstance(type_, Array):
        return ''
    if isinstance(type_, UnboundedSequence) or isinstance(type_, BoundedSequence):
        return '{0} = new {2}[{1}.size];'.format(
            dst % member.name, src % member.name, msg_type_only_to_d(type_))
    assert False, type_
