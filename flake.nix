{
  description = "Linux_Learner";
  nixConfig.bash-prompt = "[nix(Linux_Learner)] ";
  inputs = {nixpkgs.url = "github:nixos/nixpkgs/23.11";};

  outputs = {
    self,
    nixpkgs,
  } @ inputs: let
    # Systems supported
    allSystems = [
      "x86_64-linux" # 64-bit Intel/AMD Linux
      "aarch64-linux" # 64-bit ARM Linux
      "x86_64-darwin" # 64-bit Intel macOS
      "aarch64-darwin" # 64-bit ARM macOS
    ];

    # Helper to provide system-specific attributes
    forAllSystems = f:
      nixpkgs.lib.genAttrs allSystems
      (system: f {pkgs = import nixpkgs {inherit system;};});
  in {
    devShells = forAllSystems ({pkgs}: let
      # Funtions targerPkgs multiPkgs (require a pkgs)
      targetPkgs = pkgs:
        with pkgs; [
          # tools to gen prompt
          ctags
          bear
          bison
          gnumake
          flex
          clang-tools
          ccls
          llvmPackages.clang
          # other
          util-linux
          git
          bc
          python3
        ];
      multiPkgs = pkgs: with pkgs; [ncurses libelf glibc];
    in {
      linux_learning_fhs = let
        linux_learning_env = pkgs.buildFHSUserEnv {
          name = "linux_learning_fhs";
          inherit targetPkgs multiPkgs;
          runScript = "bash";
          profile = ''
            export FHS=1
          '';
          extraOutputsToInstall = ["dev"];
        };
      in
        pkgs.mkShell {
          name = "Linux_Learner_FHS";
          buildInputs = [linux_learning_env];
          shellHook = ''
            echo "Welcome in $name"
            exec linux_learning_fhs
          '';
        };
      linux_learning = let
      in
        pkgs.mkShell {
          name = "Linux_Learner";
          packages = (targetPkgs pkgs) ++ (multiPkgs pkgs);
          shellHook = ''
            echo "Welcome in $name"
          '';
        };
    });
  };
}
