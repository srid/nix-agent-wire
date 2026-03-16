{
  description = "OpenCode home-manager module tests";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      opencode-module = import ../home-manager-module.nix;
      configDir = builtins.path { path = ./../../../../example; name = "opencode-config"; };
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

            # Verify commands are auto-wired
            machine.succeed("test -d /home/testuser/.config/opencode/command")
            machine.succeed("test -f /home/testuser/.config/opencode/command/example.md")

            # Verify skills are auto-wired
            machine.succeed("test -d /home/testuser/.config/opencode/skill")

            # Local skill from example/
            machine.succeed("test -d /home/testuser/.config/opencode/skill/example")

            # Verify agent is auto-wired
            machine.succeed("test -f /home/testuser/.config/opencode/agent/example.md")

            # Verify opencode.json is created
            machine.succeed("test -f /home/testuser/.config/opencode/opencode.json")

            # Verify MCP servers are in config
            machine.succeed("grep -q '\"mcp\"' /home/testuser/.config/opencode/opencode.json")

            # Verify auto-wired example MCP server is present
            machine.succeed("grep -q 'example' /home/testuser/.config/opencode/opencode.json")
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

            # Verify both auto-wired and user-defined MCP servers are present
            machine.succeed("grep -q 'example' /home/testuser/.config/opencode/opencode.json")
            machine.succeed("grep -q 'existing-server' /home/testuser/.config/opencode/opencode.json")
          '';
        };
      };
    };
}
