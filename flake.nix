{
  description = "Intel® NPU driver";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    lib = nixpkgs.lib;
    pkgs = import nixpkgs { system = system; };

    getVersion = regex: file: with builtins; let
      lines = lib.splitString "\n" (readFile file);
      extract = match regex;
    in elemAt (
      lib.findFirst isList null (map extract lines)
    ) 0;

    version = getVersion "set\\(STACK_VERSION ([\\.0-9]+) .+\\)" ./CMakeLists.txt;

    level-zero-version = getVersion "project\\(level-zero VERSION ([\\.0-9]+)\\)" ./third_party/level-zero/CMakeLists.txt;

    cmake-build = { standalone ? true, }: pkgs.stdenv.mkDerivation {
      name = "cmake-build";
      src = ./.;

      buildInputs = with pkgs; [
        udev
        openssl
        boost
      ];

      nativeBuildInputs = with pkgs; [
        cmake
        git
        git-lfs
        patchelf
      ];

      cmakeFlags = [
        (lib.optionalString (!standalone) "-DENABLE_NPU_COMPILER_BUILD=ON")

        "-DUPDATE_FIRMWARE=OFF"
      ];
    };
  in {
    devShells.${system}.default = pkgs.mkShell {
      nativeBuildInputs = with pkgs; [
        git
        git-lfs
        cmake
        udev
        openssl
        boost
        patchelf
      ];
    };

    packages.${system} = let
      build.standalone = cmake-build {};
      # TODO: have problems with the compiler build (cloning llvm-project)
      # build.withCompiler = cmake-build { standalone = false; };
    in rec {
      intel-npu-firmware = pkgs.stdenvNoCC.mkDerivation {
        pname = "intel-npu-firmware";
        version = version;
        src = build.standalone;

        installPhase = ''
          mkdir -p $out/lib/firmware/intel/vpu
          cp -P lib/firmware/intel/vpu/*.bin $out/lib/firmware/intel/vpu
        '';
      };

      intel-npu-driver-standalone = pkgs.stdenvNoCC.mkDerivation {
        pname = "intel-npu-driver";
        version = version;
        src = build.standalone;

        installPhase = ''
          mkdir -p $out/lib/
          mkdir -p $out/bin/
          cp -P lib/libze_intel_vpu.so* $out/lib
          cp bin/* $out/bin/
        '';
      };

      level-zero = pkgs.stdenvNoCC.mkDerivation {
        pname = "level-zero";
        version = level-zero-version;
        src = build.standalone;

        installPhase = ''
          mkdir -p $out/lib/
          cp -P lib/libze_loader.so* $out/lib
          cp -P lib/libze_validation_layer.so* $out/lib
        '';
      };

      default = intel-npu-firmware;
    };

    nixosModules.intel-npu-driver = import ./module.nix self.packages.${system};
  };
}
