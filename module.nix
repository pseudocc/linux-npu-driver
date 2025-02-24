packages:
{
  config,
  lib,
  ...
}:
let
  cfg = config.hardware.cpu.intel.npu;
  type.driver = with lib.types; nullOr (enum [
    "standalone"
    # TODO: "with-compiler"
  ]);
in {
  options = {
    hardware.cpu.intel.npu = {
      enable = lib.mkEnableOption "Intel NPU support";
      driver = lib.mkOption {
        type = type.driver;
        default = "standalone";
        description = "The kind of driver to build";
      };
    };
  };

  config = lib.mkIf cfg.enable (with packages; lib.mkMerge [
    {
      hardware.firmware = [ intel-npu-firmware ];
    }
    (lib.mkIf (cfg.driver != null) {
      environment.systemPackages = [ level-zero ];
      environment.sessionVariables.LD_LIBRARY_PATH = [ "${level-zero}/lib" ];
    })
    (lib.mkIf (cfg.driver == "standalone") {
      environment.systemPackages = [ intel-npu-driver-standalone ];
      environment.sessionVariables.LD_LIBRARY_PATH = [ "${intel-npu-driver-standalone}/lib" ];
    })
  ]);
}
