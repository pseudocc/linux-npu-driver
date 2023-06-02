# Copyright 2022-2023 Intel Corporation.
#
# This software and the related documents are Intel copyrighted materials, and
# your use of them is governed by the express license under which they were
# provided to you ("License"). Unless the License provides otherwise, you may
# not use, modify, copy, publish, distribute, disclose or transmit this
# software or the related documents without Intel's prior written permission.
#
# This software and the related documents are provided as is, with no express
# or implied warranties, other than those that are expressly stated in
# the License.

cmake_minimum_required(VERSION 3.18 FATAL_ERROR)

include(compiler_source.cmake)

include(ProcessorCount)
ProcessorCount(PARALLEL_PROCESSES)

set(VPUX_COMPILER_BINARY_DIR "${VPUX_PLUGIN_PREFIX_DIR}/build-cid")
file(MAKE_DIRECTORY ${VPUX_COMPILER_BINARY_DIR})

set(VPUX_COMPILER_INCLUDE_DIR "${VPUX_PLUGIN_SOURCE_DIR}/src/VPUXCompilerL0/include")
file(MAKE_DIRECTORY ${VPUX_COMPILER_INCLUDE_DIR})

list(APPEND VPUX_COMPILER_CMAKE_FLAGS -DBUILD_COMPILER_FOR_DRIVER=ON)
list(APPEND VPUX_COMPILER_CMAKE_FLAGS -DBUILD_SHARED_LIBS=OFF)
list(APPEND VPUX_COMPILER_CMAKE_FLAGS -DCMAKE_BUILD_TYPE=Release)
list(APPEND VPUX_COMPILER_CMAKE_FLAGS -DENABLE_CLANG_FORMAT=OFF)
list(APPEND VPUX_COMPILER_CMAKE_FLAGS -DENABLE_GAPI_PREPROCESSING=OFF)
list(APPEND VPUX_COMPILER_CMAKE_FLAGS -DENABLE_HETERO=OFF)
list(APPEND VPUX_COMPILER_CMAKE_FLAGS -DENABLE_INTEL_CPU=OFF)
list(APPEND VPUX_COMPILER_CMAKE_FLAGS -DENABLE_INTEL_GNA=OFF)
list(APPEND VPUX_COMPILER_CMAKE_FLAGS -DENABLE_INTEL_GPU=OFF)
list(APPEND VPUX_COMPILER_CMAKE_FLAGS -DENABLE_INTEL_MYRIAD=OFF)
list(APPEND VPUX_COMPILER_CMAKE_FLAGS -DENABLE_INTEL_MYRIAD_COMMON=OFF)
list(APPEND VPUX_COMPILER_CMAKE_FLAGS -DENABLE_IR_V7_READER=OFF)
list(APPEND VPUX_COMPILER_CMAKE_FLAGS -DENABLE_MULTI=OFF)
list(APPEND VPUX_COMPILER_CMAKE_FLAGS -DENABLE_OV_IR_FRONTEND=ON)
list(APPEND VPUX_COMPILER_CMAKE_FLAGS -DENABLE_OV_ONNX_FRONTEND=OFF)
list(APPEND VPUX_COMPILER_CMAKE_FLAGS -DENABLE_OV_PADDLE_FRONTEND=OFF)
list(APPEND VPUX_COMPILER_CMAKE_FLAGS -DENABLE_OV_TF_FRONTEND=OFF)
list(APPEND VPUX_COMPILER_CMAKE_FLAGS -DENABLE_PYTHON=OFF)
list(APPEND VPUX_COMPILER_CMAKE_FLAGS -DENABLE_TEMPLATE=OFF)
list(APPEND VPUX_COMPILER_CMAKE_FLAGS -DENABLE_TESTS=ON)
list(APPEND VPUX_COMPILER_CMAKE_FLAGS -DENABLE_WHEEL=OFF)
list(APPEND VPUX_COMPILER_CMAKE_FLAGS -DIE_EXTRA_MODULES=${VPUX_PLUGIN_SOURCE_DIR})
list(APPEND VPUX_COMPILER_CMAKE_FLAGS -DOUTPUT_ROOT=${VPUX_COMPILER_BINARY_DIR})

# TODO: WA to not take libtbb.so.2 from system
list(APPEND VPUX_COMPILER_CMAKE_FLAGS -DENABLE_SYSTEM_TBB=OFF)

ExternalProject_Add(
  vpux_compiler_build
  DOWNLOAD_COMMAND ""
  DEPENDS vpux_plugin_source openvino_source
  PREFIX ${OPENVINO_PREFIX_DIR}
  SOURCE_DIR ${OPENVINO_SOURCE_DIR}
  BINARY_DIR ${VPUX_COMPILER_BINARY_DIR}
  CMAKE_ARGS ${VPUX_COMPILER_CMAKE_FLAGS}
  BUILD_COMMAND
    ${CMAKE_COMMAND}
      --build ${VPUX_COMPILER_BINARY_DIR}
      --target VPUXCompilerL0
      --parallel ${PARALLEL_PROCESSES}
  INSTALL_COMMAND
    cp ${VPUX_COMPILER_BINARY_DIR}/bin/intel64/Release/libVPUXCompilerL0.so
       ${OPENVINO_SOURCE_DIR}/temp/tbb/lib/libtbb.so.2
       ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/
  BUILD_BYPRODUCTS
    ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/libVPUXCompilerL0.so
    ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/libtbb.so.2)

set(VPUX_COMPILER_DEPENDENCY vpux_compiler_build)