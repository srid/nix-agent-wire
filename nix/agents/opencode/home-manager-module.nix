{ config, lib, pkgs, ... }:

let
  cfg = config.programs.opencode;

  autoDir = cfg.autoWire.dir;
  autoWireEnabled = autoDir != null && cfg.autoWire.enable;

  commandsDir = toString autoDir + "/commands";
  skillsDir = toString autoDir + "/skills";
  agentsDir = toString autoDir + "/agents";
  mcpDir = toString autoDir + "/mcp";
  memoryFile = toString autoDir + "/memory.md";

  autoCommands = lib.optionalAttrs (autoWireEnabled && builtins.pathExists commandsDir)
    (lib.mapAttrs'
      (fileName: _:
        lib.nameValuePair
          (lib.removeSuffix ".md" fileName)
          (builtins.readFile (commandsDir + "/${fileName}"))
      )
      (builtins.readDir commandsDir));

  autoSkills = lib.optionalAttrs (autoWireEnabled && builtins.pathExists skillsDir)
    (lib.mapAttrs'
      (skillName: _:
        lib.nameValuePair
          skillName
          (skillsDir + "/" + skillName)
      )
      (lib.filterAttrs (_: type: type == "directory") (builtins.readDir skillsDir)));

  autoAgents = lib.optionalAttrs (autoWireEnabled && builtins.pathExists agentsDir)
    (lib.mapAttrs'
      (fileName: _:
        lib.nameValuePair
          (lib.removeSuffix ".md" fileName)
          (agentsDir + "/" + fileName)
      )
      (builtins.readDir agentsDir));

  autoMcpServers = lib.optionalAttrs (autoWireEnabled && builtins.pathExists mcpDir)
    (lib.mapAttrs'
      (fileName: _:
        lib.nameValuePair
          (lib.removeSuffix ".nix" fileName)
          (import (mcpDir + "/${fileName}"))
      )
      (builtins.readDir mcpDir));

  autoRules = lib.optionalString (autoWireEnabled && builtins.pathExists memoryFile)
    (builtins.readFile memoryFile);

in
{
  options.programs.opencode.autoWire = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether to automatically wire up commands, skills, agents, MCP servers, and rules from autoWire.dir.
        Set to false if you want to manually configure these.
      '';
    };

    dir = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Path to the directory containing commands/, skills/, agents/, mcp/, and memory.md.
        When set, these will be automatically discovered and configured.
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
