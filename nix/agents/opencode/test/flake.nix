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
                imports = [ opencode-module ];

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
            machine.succeed("test -d /home/testuser/.config/opencode/skill/nix")

            # Verify opencode.json is created in XDG config location
            machine.succeed("test -f /home/testuser/.config/opencode/opencode.json")

            # Verify MCP servers are in config (home-manager uses 'mcp' key)
            machine.succeed("grep -q '\"mcp\"' /home/testuser/.config/opencode/opencode.json")
          '';
        };
      };
    };
}
