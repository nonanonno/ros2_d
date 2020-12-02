# ROS2 for Dlang

## Requirements

- dmd (not ldc)
- dub
- clang, libclang-dev 
    - For [dpp](https://code.dlang.org/packages/dpp)
    - Tested on version 10
- [test_interface_files](https://github.com/ros2/test_interface_files)
    - For test

## How to build

```shell
$ cd <path-to-workspace>
$ colcon build
```

## Test

```shell
$ cd <path-to-workspace>
$ colcon test
```