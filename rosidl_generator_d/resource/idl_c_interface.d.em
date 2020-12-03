// generated from rosidl_generator_d/resource/idl_c_interface.d.em
// with input from @(package_name)
// generated_code does not contain a copyright notice
module @(package_name).@(type_)_c_interface;
import core.stdc.stdint;
import rcl_bind;

@[if type_ == 'msg']@
@{
TEMPLATE(
    'msg_c_interface.d.em',
    package_name=package_name,
    contents=contents
)
}@
@[end if]@