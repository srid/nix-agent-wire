{
  description = "OpenCode home-manager module tests";

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
      pkgs = nixpkgs.legacyPackages.${system};
      opencode-module = import ../home-manager-module.nix;
      configDir = builtins.path { path = ./../../../..; name = "opencode-config"; };
    in
    {
      checks.${system} = {
        opencode-home-manager-test = pkgs.testers.runNixOSTest {
          name = "opencode-home-manager-module";

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
                  skills.homeModules.opencode
                  opencode-module
                ];

                home = {
                  username = "testuser";
                  homeDirectory = "/home/testuser";
                  stateVersion = "24.11";
                };

                programs.opencode = {
                  autoWire.dir = configDir;
                };
              };
            };

            system.stateVersion = "24.11";
          };

          testScript = ''
            machine.start()
            machine.wait_for_unit("home-manager-testuser.service")

            # Verify commands are auto-wired (home-manager uses singular 'command')
            machine.succeed("test -d /home/testuser/.config/opencode/command")
            machine.succeed("test -f /home/testuser/.config/opencode/command/plan.md")

            # Verify skills are auto-wired
            machine.succeed("test -d /home/testuser/.config/opencode/skill")

            # External skills from juspay/skills
            machine.succeed("test -d /home/testuser/.config/opencode/skill/nix-flake")
            machine.succeed("test -d /home/testuser/.config/opencode/skill/nix-haskell")

            # Local skills from this repo
            machine.succeed("test -d /home/testuser/.config/opencode/skill/haskell")
            machine.succeed("test -d /home/testuser/.config/opencode/skill/technical-writer")

            # Verify opencode.json is created in XDG config location
            machine.succeed("test -f /home/testuser/.config/opencode/opencode.json")

            # Verify MCP servers are in config (home-manager uses 'mcp' key)
            machine.succeed("grep -q '\"mcp\"' /home/testuser/.config/opencode/opencode.json")

            # Verify auto-wired chrome-devtools is present
            machine.succeed("grep -q 'chrome-devtools' /home/testuser/.config/opencode/opencode.json")
          '';
        };

        opencode-mcp-merge-test = pkgs.testers.runNixOSTest {
          name = "opencode-mcp-merge";

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
                  skills.homeModules.opencode
                  opencode-module
                ];

                home = {
                  username = "testuser";
                  homeDirectory = "/home/testuser";
                  stateVersion = "24.11";
                };

                programs.opencode = {
                  autoWire.dir = configDir;
                };

                programs.mcp.servers.existing-server = {
                  url = "https://example.com/mcp";
                };
              };
            };

            system.stateVersion = "24.11";
          };

          testScript = ''
            machine.start()
            machine.wait_for_unit("home-manager-testuser.service")

            # Verify opencode.json exists
            machine.succeed("test -f /home/testuser/.config/opencode/opencode.json")

            # Verify both auto-wired and user-defined MCP servers are present (merge)
            machine.succeed("grep -q 'chrome-devtools' /home/testuser/.config/opencode/opencode.json")
            machine.succeed("grep -q 'existing-server' /home/testuser/.config/opencode/opencode.json")
          '';
        };
      };
    };
}
