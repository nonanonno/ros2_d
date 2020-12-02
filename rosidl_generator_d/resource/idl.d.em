// generated from rosidl_generator_d/resource/idl.d.em
// with input from @(package_name)
// generated code does not contain a copyright notice
module @(package_name).@(type_);
import @(package_name).@(type_)_c_interface;
import rcld.c.rcl;
import std.string;
import std.utf;

@[if type_ == 'msg']@
@{
TEMPLATE(
    'msg.d.em',
    package_name=package_name,
    contents=contents
)
}@
@[end if]@