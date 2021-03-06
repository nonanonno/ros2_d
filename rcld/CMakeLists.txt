cmake_minimum_required(VERSION 3.5)
project(rcld)

find_package(ament_cmake REQUIRED)

add_custom_target(dub ALL
  COMMAND dub build --root ${CMAKE_CURRENT_SOURCE_DIR} -c library
)

install(
  DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  DESTINATION "./import"
  PATTERN "package.xml" EXCLUDE
  PATTERN "CMakeLists.txt" EXCLUDE
)

install(
  CODE "execute_process(COMMAND dub remove-local ${CMAKE_INSTALL_PREFIX}/import/${PROJECT_NAME} ERROR_QUIET)"
)

install(
  CODE "execute_process(COMMAND dub add-local ${CMAKE_INSTALL_PREFIX}/import/${PROJECT_NAME})"
)

if(BUILD_TESTING)

  find_package(rosidl_generator_d REQUIRED)

  add_test(NAME rcld_test
    COMMAND ${CMAKE_COMMAND} -E env
    dub test --root=${CMAKE_CURRENT_SOURCE_DIR}
  )
  
  add_subdirectory(test)

endif()

ament_package()