cmake_minimum_required(VERSION 3.5)
project(rcld_examples)

# Default to C99
if(NOT CMAKE_C_STANDARD)
  set(CMAKE_C_STANDARD 99)
endif()

# Default to C++14
if(NOT CMAKE_CXX_STANDARD)
  set(CMAKE_CXX_STANDARD 14)
endif()

if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  add_compile_options(-Wall -Wextra -Wpedantic)
endif()

# find dependencies
find_package(ament_cmake REQUIRED)
find_package(rcld REQUIRED)
find_package(std_msgs REQUIRED)

add_custom_target(talker ALL
  COMMAND dub build --root ${CMAKE_CURRENT_SOURCE_DIR} -c talker
  BYPRODUCTS ${CMAKE_CURRENT_SOURCE_DIR}/bin/talker
)

install(PROGRAMS ${CMAKE_CURRENT_SOURCE_DIR}/bin/talker DESTINATION lib/${PROJECT_NAME})

add_custom_target(listener ALL
  COMMAND dub build --root ${CMAKE_CURRENT_SOURCE_DIR} -c listener
  BYPRODUCTS ${CMAKE_CURRENT_SOURCE_DIR}/bin/listener
)
install(PROGRAMS ${CMAKE_CURRENT_SOURCE_DIR}/bin/listener DESTINATION lib/${PROJECT_NAME})


if(BUILD_TESTING)
  find_package(ament_lint_auto REQUIRED)
  # the following line skips the linter which checks for copyrights
  # uncomment the line when a copyright and license is not present in all source files
  #set(ament_cmake_copyright_FOUND TRUE)
  # the following line skips cpplint (only works in a git repo)
  # uncomment the line when this package is not in a git repo
  #set(ament_cmake_cpplint_FOUND TRUE)
  ament_lint_auto_find_test_dependencies()
endif()

ament_package()
