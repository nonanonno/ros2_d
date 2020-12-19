# ROS2 for Dlang

## Requirements

- dmd (not ldc)
- dub
- clang, libclang-dev 
    - For [dpp](https://code.dlang.org/packages/dpp)
    - Tested on version 10
- vcstool
- Docker (optional)
    - Example Docker image : https://github.com/nonanonno/ros2_d_docker.git
        - The image contains all of requirements listed above.
## How to build

```shell
cd <path-to-ros-workspace>/src
git clone https://github.com/nonanonno/ros2_d.git
cd ../..
vcs import src < src/ros2_d/ros2_d.repos
source /opt/ros/foxy/setup.sh
colcon build
```

## Examples

[rcld_examples](rcld_examples)

Publisher:

```shell
cd <path-to-ros-workspace>
. ./install/setup.sh
ros2 run rcld_examples talker
```

Subscription:

```shell
cd <path-to-ros-workspace>
. ./install/setup.sh
ros2 run rcld_examples listener
```