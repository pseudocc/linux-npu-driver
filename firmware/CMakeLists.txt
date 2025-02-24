#
# Copyright (C) 2023-2024 Intel Corporation
#
# SPDX-License-Identifier: MIT
#

project(fw_vpu_api_headers)

add_library(${PROJECT_NAME} INTERFACE)
target_include_directories(${PROJECT_NAME} INTERFACE include)

option(UPDATE_FIRMWARE "Install firmware updates" ON)
set(FIRMWARE_INSTALL_DIR ${CMAKE_INSTALL_PREFIX})
cmake_path(APPEND FIRMWARE_INSTALL_DIR "lib" "firmware")
if(UPDATE_FIRMWARE)
  cmake_path(APPEND FIRMWARE_INSTALL_DIR "updates")
endif()
cmake_path(APPEND FIRMWARE_INSTALL_DIR "intel" "vpu")

file(GLOB FIRMWARE_BINARIES ${CMAKE_CURRENT_SOURCE_DIR}/bin/*.bin)
if (FIRMWARE_BINARIES)
  install(FILES ${FIRMWARE_BINARIES}
    DESTINATION ${FIRMWARE_INSTALL_DIR}
    PERMISSIONS OWNER_READ
    COMPONENT fw-npu)
endif()
