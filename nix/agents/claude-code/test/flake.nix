{
  description = "Claude Code home-manager module tests";

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
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      claude-code-module = import ../home-manager-module.nix;
      configDir = builtins.path { path = ./../../../../example/1; name = "claude-code-config"; };
      configDir2 = builtins.path { path = ./../../../../example/2; name = "claude-code-config2"; };
    in
    {
      checks.${system}.claude-code-test = pkgs.testers.runNixOSTest {
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
                claude-code-module
              ];

              home = {
                username = "testuser";
                homeDirectory = "/home/testuser";
                stateVersion = "24.11";
              };

              programs.claude-code = {
                autoWire.dirs = [ configDir configDir2 ];
              };
            };
          };

          system.stateVersion = "24.11";
        };

        testScript = ''
          machine.start()
          machine.wait_for_unit("home-manager-testuser.service")

          # Verify skills from both dirs
          machine.succeed("test -d /home/testuser/.claude/skills/example")
          machine.succeed("test -d /home/testuser/.claude/skills/second-skill")

          # Verify skill SKILL.md contains actual content, not a store path string
          machine.succeed("grep -q 'Example Skill' /home/testuser/.claude/skills/example/SKILL.md")
          machine.fail("grep -q '/nix/store' /home/testuser/.claude/skills/example/SKILL.md")

          # Verify agents from both dirs
          machine.succeed("test -f /home/testuser/.claude/agents/example.md")
          machine.succeed("test -f /home/testuser/.claude/agents/second.md")

          # Verify agent files contain actual content, not a store path string
          machine.succeed("grep -q 'Example Agent' /home/testuser/.claude/agents/example.md")
          machine.fail("grep -q '/nix/store' /home/testuser/.claude/agents/example.md")

          # Verify commands from both dirs
          machine.succeed("test -f /home/testuser/.claude/commands/example.md")
          machine.succeed("test -f /home/testuser/.claude/commands/second.md")

          # Verify settings.json exists and has expected content
          machine.succeed("test -f /home/testuser/.claude/settings.json")
          machine.succeed("grep -q 'bypassPermissions' /home/testuser/.claude/settings.json")
        '';
      };
    };
}
