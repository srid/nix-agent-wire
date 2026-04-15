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
      configDir = builtins.path { path = ./../../../../example/1; name = "opencode-config"; };
      configDir2 = builtins.path { path = ./../../../../example/2; name = "opencode-config2"; };
    in
    {
      checks.${system}.opencode-test = pkgs.testers.runNixOSTest {
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
                autoWire.dirs = [ configDir configDir2 ];
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

          # Verify commands from both dirs are present
          machine.succeed("test -f /home/testuser/.config/opencode/command/example.md")
          machine.succeed("test -f /home/testuser/.config/opencode/command/second.md")

          # Verify skills from both dirs
          machine.succeed("test -d /home/testuser/.config/opencode/skill/example")
          machine.succeed("test -d /home/testuser/.config/opencode/skill/second-skill")

          # Verify skill SKILL.md contains actual content, not a store path string
          machine.succeed("grep -q 'Example Skill' /home/testuser/.config/opencode/skill/example/SKILL.md")
          machine.fail("grep -q '/nix/store' /home/testuser/.config/opencode/skill/example/SKILL.md")

          # Verify agents from both dirs
          machine.succeed("test -f /home/testuser/.config/opencode/agent/example.md")
          machine.succeed("test -f /home/testuser/.config/opencode/agent/second.md")

          # Verify agent files contain actual content, not a store path string
          machine.succeed("grep -q 'Example Agent' /home/testuser/.config/opencode/agent/example.md")
          machine.fail("grep -q '/nix/store' /home/testuser/.config/opencode/agent/example.md")

          # Verify opencode.json is created
          machine.succeed("test -f /home/testuser/.config/opencode/opencode.json")

          # Verify MCP servers from both dirs plus user-defined
          machine.succeed("grep -q 'example' /home/testuser/.config/opencode/opencode.json")
          machine.succeed("grep -q 'second-mcp' /home/testuser/.config/opencode/opencode.json")
          machine.succeed("grep -q 'existing-server' /home/testuser/.config/opencode/opencode.json")
        '';
      };
    };
}
