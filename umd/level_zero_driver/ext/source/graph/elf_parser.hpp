/*
 * Copyright (C) 2022 Intel Corporation
 *
 * SPDX-License-Identifier: MIT
 *
 */

#pragma once

#include "level_zero/ze_graph_ext.h"
#include "level_zero_driver/ext/source/graph/interface_parser.hpp"
#include "vpu_driver/source/command/vpu_command.hpp"
#include "vpu_driver/source/device/vpu_device_context.hpp"
#include "vpu_driver/source/command/vpu_inference_execute.hpp"
#include "vpu_driver/source/memory/vpu_buffer_object.hpp"

#include <cstdint>
#include <memory>
#include <vpux_hpi.hpp>
#include <vpux_headers/buffer_manager.hpp>
#include <vpux_elf/accessor.hpp>

namespace L0 {

class ElfParser : public IParser {
  public:
    ElfParser(VPU::VPUDeviceContext *ctx,
              std::unique_ptr<elf::BufferManager> manager,
              std::unique_ptr<elf::AccessManager> access,
              std::shared_ptr<elf::HostParsedInference> loader);

    static bool checkMagic(uint8_t *ptr, size_t size);
    static std::unique_ptr<ElfParser>
    getElfParser(VPU::VPUDeviceContext *ctx, uint8_t *ptr, size_t size);

    bool getArgumentProperties(std::vector<ze_graph_argument_properties_3_t> &props) const;
    bool getArgumentMetadata(std::vector<ze_graph_argument_metadata_t> &args) const;
    bool getProfilingSize(uint32_t &size) const;

    std::shared_ptr<VPU::VPUInferenceExecute>
    createInferenceExecuteCommand(const std::vector<std::pair<const void *, uint32_t>> &inputPtrs,
                                  const std::vector<std::pair<const void *, uint32_t>> &outputPtrs,
                                  const std::pair<void *, uint32_t> &profilingPtr,
                                  std::shared_ptr<elf::HostParsedInference> &execHpi);

    ze_result_t parse(std::vector<ze_graph_argument_properties_3_t> &argumentProperties,
                      std::vector<ze_graph_argument_metadata_t> &argumentMetadata,
                      uint32_t &profilingOutputSize) override;

    std::shared_ptr<VPU::VPUCommand> allocateInitCommand(VPU::VPUDeviceContext *ctx,
                                                         uint8_t *graphBlobRawData,
                                                         size_t graphBlobRawSize) override;

    std::shared_ptr<VPU::VPUCommand>
    allocateExecuteCommand(VPU::VPUDeviceContext *ctx,
                           const std::vector<std::pair<const void *, uint32_t>> &inputArgs,
                           const std::vector<std::pair<const void *, uint32_t>> &outputArgs,
                           const std::pair<void *, uint32_t> &profilingPtr,
                           std::shared_ptr<elf::HostParsedInference> &execHpi) override;

  private:
    static ze_graph_argument_precision_t getTensorPrecision(elf::DType type);

    bool applyInputOutputs(elf::HostParsedInference &hpi,
                           const std::vector<std::pair<const void *, uint32_t>> &inputs,
                           const std::vector<std::pair<const void *, uint32_t>> &outputs,
                           const std::pair<const void *, uint32_t> &profilingPtr,
                           std::vector<VPU::VPUBufferObject *> &bos);

    VPU::VPUDeviceContext *ctx;
    std::unique_ptr<elf::BufferManager> bufferManager;
    std::unique_ptr<elf::AccessManager> accessManager;
    std::shared_ptr<elf::HostParsedInference> hpi;
    bool firstInference = true;
};

} // namespace L0
