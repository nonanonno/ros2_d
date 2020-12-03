@{
from rosidl_generator_d import solve_depends_package
}@
{
    "version": "1.0.0",
    "description": "@(package_name) for Dlang",
    "license": "Apache-2.0",
    "name": "@(package_name)",
    "configurations": [
        {
            "name": "library",
            "targetType": "sourceLibrary"
        }
    ],
    "dependencies": {
@[for dep in solve_depends_package(contents, package_name)]@
        "@(dep)": "~>1.0.0",
@[end for]@
        "rcl_bind": "~>0.0.1"
    },
    "lflags": [
        "-L$PACKAGE_DIR/../../lib"
    ],
    "libs": [
        "@(package_name)__rosidl_typesupport_c",
        "@(package_name)__rosidl_generator_c"
    ]
}
