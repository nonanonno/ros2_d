# Copyright 2020 nonanonno
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set(_output_path
  "${CMAKE_CURRENT_BINARY_DIR}/rosidl_generator_d/${PROJECT_NAME}")
set(_has_msg FALSE)
set(_has_srv FALSE)
set(_has_action FALSE)

foreach(_abs_idl_file ${rosidl_generate_interfaces_ABS_IDL_FILES})
  get_filename_component(_parent_folder "${_abs_idl_file}" DIRECTORY)
  get_filename_component(_parent_folder "${_parent_folder}" NAME)
  if(_parent_folder STREQUAL "msg")
    set(_has_msg TRUE)
  elseif(_parent_folder STREQUAL "srv")
    set(_has_srv TRUE)
  elseif(_parent_folder STREQUAL "action")
    set(_has_action TRUE)
  else()
    message(FATAL_ERROR "Interface file with unknown parent folder: ${_abs_idl_file}")
  endif()
endforeach()

set(_generated_modules "")
if(${_has_msg})
  list(APPEND _generated_modules "${_output_path}/msg.d")
endif()
if(${_has_srv})
  list(APPEND _generated_modules "${_output_path}/srv.d")
endif()
if(${_has_action})
  list(APPEND _generated_modules "${_output_path}/action.d")
endif()

set(_dependency_files "")
set(_dependencies "")
foreach(_pkg_name ${rosidl_generate_interfaces_DEPENDENCY_PACKAGE_NAMES})
  foreach(_idl_file ${${_pkg_name}_IDL_FILES})
    set(_abs_idl_file "${${_pkg_name}_DIR}/../${_idl_file}")
    normalize_path(_abs_idl_file "${_abs_idl_file}")
    list(APPEND _dependency_files "${_abs_idl_file}")
    list(APPEND _dependencies "${_pkg_name}:${_abs_idl_file}")
  endforeach()
endforeach()

set(target_dependencies
  "${rosidl_generator_d_BIN}"
  ${rosidl_generator_d_GENERATOR_FILES}
  "${rosidl_generator_d_TEMPLATE_DIR}/idl.d.em"
  "${rosidl_generator_d_TEMPLATE_DIR}/action.d.em"
  "${rosidl_generator_d_TEMPLATE_DIR}/msg.d.em"
  "${rosidl_generator_d_TEMPLATE_DIR}/srv.d.em"
  "${rosidl_generator_d_TEMPLATE_DIR}/dub.json.em"
  "${rosidl_generator_d_TEMPLATE_DIR}/idl_c_interface.d.em"
  "${rosidl_generator_d_TEMPLATE_DIR}/msg_c_interface.d.em"
  ${rosidl_generate_interfaces_ABS_IDL_FILES}
  ${_dependency_files})
foreach(dep ${target_dependencies})
  if(NOT EXISTS "${dep}")
    message(FATAL_ERROR "Target dependency '${dep}' does not exist")
  endif()
endforeach()

set(generator_arguments_file "${CMAKE_CURRENT_BINARY_DIR}/rosidl_generator_d__arguments.json")
rosidl_write_generator_arguments(
  "${generator_arguments_file}"
  PACKAGE_NAME "${PROJECT_NAME}"
  IDL_TUPLES "${rosidl_generate_interfaces_IDL_TUPLES}"
  ROS_INTERFACE_DEPENDENCIES "${_dependencies}"
  OUTPUT_DIR "${_output_path}"
  TEMPLATE_DIR "${rosidl_generator_d_TEMPLATE_DIR}"
  TARGET_DEPENDENCIES ${target_dependencies}
)

add_custom_command(
  OUTPUT ${_generated_modules}
  COMMAND ${PYTHON_EXECUTABLE} ${rosidl_generator_d_BIN}
  --generator-arguments-file "${generator_arguments_file}"
  DEPENDS ${target_dependencies}
  COMMENT "Generating D code for ROS interfaces"
  VERBATIM
)

if(TARGET ${rosidl_generate_interfaces_TARGET}__d)
  message(WARNING "Custom target ${rosidl_generate_interfaces_TARGET}__d already exists")
else()
  add_custom_target(
    ${rosidl_generate_interfaces_TARGET}__d
    DEPENDS
    ${_generated_modules}
  )
endif()

add_dependencies(
  ${rosidl_generate_interfaces_TARGET}
  ${rosidl_generate_interfaces_TARGET}__d
)

if(NOT rosidl_generate_interfaces_SKIP_INSTALL)
  if(NOT _generated_modules STREQUAL "")
    install(
      DIRECTORY ${_output_path}/
      DESTINATION "import/${PROJECT_NAME}"
    )
    install(
      CODE "execute_process(COMMAND dub remove-local ${CMAKE_INSTALL_PREFIX}/import/${PROJECT_NAME} ERROR_QUIET)"
    )

    install(
      CODE "execute_process(COMMAND dub add-local ${CMAKE_INSTALL_PREFIX}/import/${PROJECT_NAME})"
    )
  endif()
endif()