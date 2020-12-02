# ROS2 for Dlang

## Requirements

- dmd (not ldc)
- dub
- clang, libclang-dev 
    - For [dpp](https://code.dlang.org/packages/dpp)
    - Tested on version 10

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