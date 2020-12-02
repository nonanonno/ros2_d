cmake_minimum_required(VERSION 3.5)
project(rcld)

find_package(ament_cmake REQUIRED)

add_custom_command(
  OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/source/rcld/c/rcl.d
  COMMAND CC=clang dub run -y dpp -- --preprocess-only --include-path /opt/ros/foxy/include ${CMAKE_CURRENT_SOURCE_DIR}/source/rcld/c/rcl.dpp
  DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/source/rcld/c/rcl.dpp
)

add_custom_target(dub ALL
  COMMAND dub build --root ${CMAKE_CURRENT_SOURCE_DIR} -c library 
  DEPENDS
    ${CMAKE_CURRENT_SOURCE_DIR}/source/rcld/c/rcl.d

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

  add_test(NAME rcld_test
    COMMAND ${CMAKE_COMMAND} -E env
    dub test --root=${CMAKE_CURRENT_SOURCE_DIR}
  )

endif()

ament_package()