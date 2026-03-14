{ config, lib, pkgs, ... }:

let
  cfg = config.programs.claude-code;

  autoDir = cfg.autoWire.dir;
  autoWireEnabled = autoDir != null && cfg.autoWire.enable;

  agentsDir = toString autoDir + "/agents";
  commandsDir = toString autoDir + "/commands";
  skillsDir = toString autoDir + "/skills";
  mcpDir = toString autoDir + "/mcp";
  settingsFile = toString autoDir + "/settings/claude-code.nix";
  memoryFile = toString autoDir + "/memory.md";

  autoAgents = lib.optionalAttrs (autoWireEnabled && builtins.pathExists agentsDir)
    (lib.mapAttrs'
      (fileName: _:
        lib.nameValuePair
          (lib.removeSuffix ".md" fileName)
          (builtins.readFile (agentsDir + "/${fileName}"))
      )
      (builtins.readDir agentsDir));

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

  autoMcpServers = lib.optionalAttrs (autoWireEnabled && builtins.pathExists mcpDir)
    (lib.mapAttrs'
      (fileName: _:
        lib.nameValuePair
          (lib.removeSuffix ".nix" fileName)
          (import (mcpDir + "/${fileName}"))
      )
      (builtins.readDir mcpDir));

  autoSettings = lib.optionalAttrs (autoWireEnabled && builtins.pathExists settingsFile)
    (import settingsFile);

  autoMemory = lib.optionalAttrs (autoWireEnabled && builtins.pathExists memoryFile)
    { text = builtins.readFile memoryFile; };

in
{
  options.programs.claude-code = {
    autoWire = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Whether to automatically wire up agents, commands, skills, and MCP servers from autoWire.dir.
          Set to false if you want to manually configure these.
        '';
      };

      dir = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = ''
          Path to the claude-code directory containing agents/, commands/, skills/, mcp/, settings/claude-code.nix, and memory.md.
          When set, these will be automatically discovered and configured.
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

      skills = lib.mkMerge [
        (lib.mkIf (autoSkills != { }) autoSkills)
      ];

      mcpServers = lib.mkDefault autoMcpServers;
    };
  };
}
