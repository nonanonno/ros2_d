@{
from rosidl_generator_d import solve_depends, msg_type_only_to_c_in_d, idl_type_to_c_in_d
from rosidl_generator_c import idl_structure_type_to_c_typename, \
                               idl_structure_type_sequence_to_c_typename
}@

import @(package_name).msg;
@[for dep in solve_depends(contents, (package_name, 'msg'))]@
import @('.'.join(dep))_c_interface;
@[end for]@

extern (C):

@[for content in contents]@
@{
namespaced_type = content.structure.namespaced_type
type_name = namespaced_type.name
c_type_name = idl_structure_type_to_c_typename(namespaced_type)
c_array_type_name = idl_structure_type_sequence_to_c_typename(namespaced_type)
typesupport_function = "rosidl_typesupport_c__get_message_type_support_handle__" + c_type_name
}@
struct @(c_type_name) {
@[  for member in content.structure.members ]@
    @(idl_type_to_c_in_d(member.type)) @(member.name);
@[  end for]@
}

struct @(c_array_type_name) {
    @(c_type_name) *data;
    size_t size;
    size_t capacity;
}

bool @(c_type_name)__init(@(c_type_name) * msg) @@nogc nothrow;
void @(c_type_name)__fini(@(c_type_name) * msg) @@nogc nothrow;
@(c_type_name) * @(c_type_name)__create() @@nogc nothrow;
void @(c_type_name)__destroy(@(c_type_name) * msg) @@nogc nothrow;
bool @(c_array_type_name)__init(@(c_array_type_name) * array, size_t size) @@nogc nothrow;
void @(c_array_type_name)__fini(@(c_array_type_name) * array) @@nogc nothrow;
@(c_array_type_name) * @(c_array_type_name)__create(size_t size) @@nogc nothrow;
void @(c_array_type_name)__destroy(@(c_array_type_name) *array) @@nogc nothrow;
const(rosidl_message_type_support_t) * @(typesupport_function)() @@nogc nothrow;


@[end for]@