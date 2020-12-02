cmake_minimum_required(VERSION 3.5)
project(rosidl_generator_d)

find_package(ament_cmake REQUIRED)

ament_export_dependencies(rosidl_cmake)

ament_index_register_resource("rosidl_generator_packages")

ament_python_install_package(${PROJECT_NAME})

if(BUILD_TESTING)
  find_package(rosidl_cmake REQUIRED)

  find_package(ament_lint_auto REQUIRED)
  ament_lint_auto_find_test_dependencies()

  find_package(test_interface_files REQUIRED)

  include(cmake/register_d.cmake)
  # need typesupport

  # Trick ament_target_dependencies() into thinking this package has been found
  set(rosidl_generator_d_DIR "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

  rosidl_generator_d_extras(
    "${CMAKE_CURRENT_SOURCE_DIR}/bin/rosidl_generator_d"
    "${CMAKE_CURRENT_SOURCE_DIR}/rosidl_generator_d/__init__.py"
    "${CMAKE_CURRENT_SOURCE_DIR}/resource"
  )

  # typesupport

  rosidl_generate_interfaces(${PROJECT_NAME}
    ${test_interface_files_MSG_FILES}
    ADD_LINTER_TESTS
    SKIP_INSTALL
  )

  set(_append_library_dirs "")
  if(WIN32)
    set(_append_library_dirs "${CMAKE_CURRENT_BINARY_DIR}/$<CONFIG>")
  endif()

  add_test(NAME test_interfaces_d_register
    COMMAND dub add-local ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}/${PROJECT_NAME}
  )
  add_test(NAME test_interfaces_d
    COMMAND ${CMAKE_COMMAND} -E env
    LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:.:/opt/ros/foxy/lib
    dub test --root=${CMAKE_CURRENT_SOURCE_DIR}/test
  )
  add_test(NAME test_interfaces_d_unregister
    COMMAND dub remove-local ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}/${PROJECT_NAME}
  )

endif()

ament_package(
  CONFIG_EXTRAS "rosidl_generator_d-extras.cmake.in"
)

install(
  PROGRAMS bin/rosidl_generator_d
  DESTINATION lib/rosidl_generator_d
)
install(
  DIRECTORY cmake resource
  DESTINATION share/${PROJECT_NAME}
)