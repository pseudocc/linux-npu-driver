#
# Copyright (C) 2024 Intel Corporation
#
# SPDX-License-Identifier: MIT

find_program(DPKG_EXECUTABLE dpkg REQUIRED)

include(${CPACK_PROJECT_CONFIG_FILE})

set(CPACK_GENERATOR DEB)

# Create package per component
set(CPACK_DEB_COMPONENT_INSTALL ON)

# Enable detection of component dependencies
set(CPACK_DEBIAN_PACKAGE_SHLIBDEPS ON)
list(APPEND SHLIBDEPS_PRIVATE_DIRS ${CMAKE_LIBRARY_OUTPUT_DIRECTORY})
list(APPEND SHLIBDEPS_PRIVATE_DIRS ${OPENVINO_LIBRARY_DIR})
list(APPEND SHLIBDEPS_PRIVATE_DIRS ${OPENCV_LIBRARY_DIR})
set(CPACK_DEBIAN_PACKAGE_SHLIBDEPS_PRIVATE_DIRS ${SHLIBDEPS_PRIVATE_DIRS})

# Component conflicts
set(CPACK_DEBIAN_LEVEL-ZERO_PACKAGE_CONFLICTS "level-zero, level-zero-devel")

# Get Debian architecture
execute_process(
    COMMAND ${DPKG_EXECUTABLE} --print-architecture
    OUTPUT_VARIABLE OUT_DPKG_ARCH
    OUTPUT_STRIP_TRAILING_WHITESPACE
    COMMAND_ERROR_IS_FATAL ANY)

set(PACKAGE_POSTFIX_NAME ${CPACK_PACKAGE_VERSION}_${LINUX_SYSTEM_NAME}${LINUX_SYSTEM_VERSION_ID}_${OUT_DPKG_ARCH}.deb)
foreach(COMPONENT ${CPACK_COMPONENTS_ALL})
    string(TOUPPER ${COMPONENT} COMPONENT_UPPER)
    set(CPACK_DEBIAN_${COMPONENT_UPPER}_FILE_NAME ${CPACK_PACKAGE_NAME}-${COMPONENT}_${PACKAGE_POSTFIX_NAME})
    if (${COMPONENT_UPPER}_POSTINST)
        list(APPEND CPACK_DEBIAN_${COMPONENT_UPPER}_PACKAGE_CONTROL_EXTRA ${${COMPONENT_UPPER}_POSTINST})
    endif()
    if (${COMPONENT_UPPER}_PRERM)
        list(APPEND CPACK_DEBIAN_${COMPONENT_UPPER}_PACKAGE_CONTROL_EXTRA ${${COMPONENT_UPPER}_PRERM})
    endif()
    if (${COMPONENT_UPPER}_POSTRM)
        list(APPEND CPACK_DEBIAN_${COMPONENT_UPPER}_PACKAGE_CONTROL_EXTRA ${${COMPONENT_UPPER}_POSTRM})
    endif()
    if (${COMPONENT_UPPER}_DEPENDS)
        set(CPACK_DEBIAN_${COMPONENT_UPPER}_PACKAGE_DEPENDS ${${COMPONENT_UPPER}_DEPENDS})
    endif()
endforeach()

set(CPACK_DEBIAN_DEBUGINFO_PACKAGE OFF)
set(CPACK_DEBIAN_LEVEL-ZERO_DEBUGINFO_PACKAGE ON)
set(CPACK_DEBIAN_LEVEL-ZERO-NPU_DEBUGINFO_PACKAGE ON)
set(CPACK_DEBIAN_DRIVER-COMPILER-NPU_DEBUGINFO_PACKAGE ON)
set(CPACK_DEBIAN_VALIDATION-NPU_DEBUGINFO_PACKAGE ON)