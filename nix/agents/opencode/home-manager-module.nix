{ config, lib, pkgs, ... }:

let
  cfg = config.programs.opencode;
  autoLib = import ../../autowire-lib.nix { inherit lib; };

  autoDirs = cfg.autoWire.dirs;
  autoWireEnabled = autoDirs != [ ] && cfg.autoWire.enable;

  autoCommands = autoLib.mergeAttrsList (map autoLib.readCommands autoDirs);
  autoSkills = autoLib.mergeAttrsList (map autoLib.readSkills autoDirs);
  autoAgents = autoLib.mergeAttrsList (map autoLib.readAgentsPath autoDirs);
  autoMcpServers = autoLib.mergeAttrsList (map autoLib.readMcpServers autoDirs);
  autoRules = lib.concatStringsSep "\n\n" (lib.filter (s: s != "") (map autoLib.readMemoryString autoDirs));

in
{
  options.programs.opencode.autoWire = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether to automatically wire up commands, skills, agents, MCP servers, and rules from autoWire.dirs.
        Set to false if you want to manually configure these.
      '';
    };

    dirs = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      default = [ ];
      description = ''
        List of directories containing commands/, skills/, agents/, mcp/, and memory.md.
        All directories are merged, with later directories taking precedence.
      '';
    };
  };

  config = lib.mkIf autoWireEnabled {
    programs.opencode = {
      enable = lib.mkDefault true;
      enableMcpIntegration = lib.mkDefault true;

      commands = lib.mkIf (autoCommands != { }) (lib.mkDefault autoCommands);

      skills = lib.mkMerge [
        (lib.mkIf (autoSkills != { }) autoSkills)
      ];

      agents = lib.mkIf (autoAgents != { }) (lib.mkDefault autoAgents);

      rules = lib.mkIf (autoRules != "") (lib.mkDefault autoRules);
    };

    programs.mcp = {
      enable = lib.mkDefault true;
      servers = autoMcpServers;
    };
  };
}
