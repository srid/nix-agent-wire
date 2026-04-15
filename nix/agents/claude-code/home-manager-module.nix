{ config, lib, pkgs, ... }:

let
  cfg = config.programs.claude-code;
  autoLib = import ../../autowire-lib.nix { inherit lib; };

  autoDirs = cfg.autoWire.dirs;
  autoWireEnabled = autoDirs != [ ] && cfg.autoWire.enable;

  autoAgents = autoLib.mergeAttrsList (map autoLib.readAgentsContent autoDirs);
  autoCommands = autoLib.mergeAttrsList (map autoLib.readCommands autoDirs);
  autoSkills = autoLib.mergeAttrsList (map autoLib.readSkills autoDirs);
  autoMcpServers = autoLib.mergeAttrsList (map autoLib.readMcpServers autoDirs);
  autoSettings = autoLib.mergeAttrsList (map (autoLib.readSettings "claude-code") autoDirs);
  autoMemory = autoLib.mergeAttrsList (map autoLib.readMemoryAttrset autoDirs);

in
{
  options.programs.claude-code = {
    autoWire = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Whether to automatically wire up agents, commands, skills, and MCP servers from autoWire.dirs.
          Set to false if you want to manually configure these.
        '';
      };

      dirs = lib.mkOption {
        type = lib.types.listOf lib.types.path;
        default = [ ];
        description = ''
          List of directories containing agents/, commands/, skills/, mcp/, settings/claude-code.nix, and memory.md.
          All directories are merged, with later directories taking precedence.
        '';
      };
    };
  };

  config = lib.mkIf autoWireEnabled {
    programs.claude-code = {
      enable = lib.mkDefault true;

      settings = lib.mkDefault autoSettings;

      memory = lib.mkDefault autoMemory;

      commands = lib.mkDefault autoCommands;

      agents = lib.mkDefault autoAgents;

      mcpServers = lib.mkDefault autoMcpServers;
    };

    # Wire skills as directory symlinks via home.file directly.
    # programs.claude-code.skills uses `either lines path` which matches
    # string store paths as `lines` (writing the path string as text).
    # Using home.file with source creates proper directory symlinks.
    home.file = lib.mkIf (autoSkills != { }) (
      lib.mapAttrs' (name: path:
        lib.nameValuePair ".claude/skills/${name}" {
          source = path;
        }
      ) autoSkills
    );
  };
}
