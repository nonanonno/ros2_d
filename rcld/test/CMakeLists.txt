find_package(rosidl_default_generators REQUIRED)

set(_PROJECT_NAME ${PROJECT_NAME})
set(PROJECT_NAME ${_PROJECT_NAME}_test_msgs)

rosidl_generate_interfaces(${PROJECT_NAME}
    msg/TestA.msg
    msg/TestB.msg
    LIBRARY_NAME ${PROJECT_NAME}
    SKIP_INSTALL
)

set(PROJECT_NAME ${_PROJECT_NAME})

add_test(NAME rcld_test_register
    COMMAND dub add-local ${CMAKE_CURRENT_BINARY_DIR}/rosidl_generator_d/${PROJECT_NAME}_test_msgs
)

add_test(NAME rcld_test
    COMMAND ${CMAKE_COMMAND} -E env
    LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:.:/opt/ros/foxy/lib
    dub test --root=${CMAKE_CURRENT_SOURCE_DIR} -- -t 1
)

add_test(NAME rcld_test_unregister
    COMMAND dub remove-local ${CMAKE_CURRENT_BINARY_DIR}/rosidl_generator_d/${PROJECT_NAME}_test_msgs
)

