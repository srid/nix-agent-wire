{
  description = "Claude Code home-manager module tests";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    skills.url = "github:juspay/skills";
  };

  outputs = { self, nixpkgs, home-manager, skills }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      claude-code-module = import ../home-manager-module.nix;
      configDir = builtins.path { path = ./../../../..; name = "claude-code-config"; };
    in
    {
      checks.${system} = {
        claude-code-home-manager-test = pkgs.testers.runNixOSTest {
          name = "claude-code-home-manager-module";

          nodes.machine = { config, pkgs, ... }: {
            imports = [
              home-manager.nixosModules.home-manager
            ];

            users.users.testuser = {
              isNormalUser = true;
              uid = 1000;
            };

            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.testuser = {
                imports = [
                  skills.homeModules.claude-code
                  claude-code-module
                ];

                home = {
                  username = "testuser";
                  homeDirectory = "/home/testuser";
                  stateVersion = "24.11";
                };

                programs.claude-code = {
                  autoWire.dir = configDir;
                };
              };
            };

            system.stateVersion = "24.11";
          };

          testScript = ''
            machine.start()
            machine.wait_for_unit("home-manager-testuser.service")

            # Verify skills are auto-wired
            machine.succeed("test -d /home/testuser/.claude/skills")

            # External skills from juspay/skills
            machine.succeed("test -d /home/testuser/.claude/skills/nix-flake")
            machine.succeed("test -d /home/testuser/.claude/skills/nix-haskell")

            # Local skills from this repo
            machine.succeed("test -d /home/testuser/.claude/skills/haskell")
            machine.succeed("test -d /home/testuser/.claude/skills/technical-writer")
          '';
        };
      };
    };
}
