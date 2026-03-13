{ config, lib, pkgs, ... }:

let
  cfg = config.programs.opencode;
in
{
  options.programs.opencode.autoWire = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether to automatically wire up commands, skills, MCP servers, and settings from autoWire.dir.
        Set to false if you want to manually configure these.
      '';
    };

    dir = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Path to the directory containing commands/, skills/, mcp/, and memory.md.
        When set, these will be automatically discovered and configured.
      '';
    };
  };

  config = let
    autoDir = cfg.autoWire.dir;
    autoWireEnabled = autoDir != null && cfg.autoWire.enable;

    commandsDir = toString autoDir + "/commands";
    skillsDir = toString autoDir + "/skills";
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

    rawMcpServers = lib.optionalAttrs (autoWireEnabled && builtins.pathExists mcpDir)
      (lib.mapAttrs'
        (fileName: _:
          lib.nameValuePair
            (lib.removeSuffix ".nix" fileName)
            (import (mcpDir + "/${fileName}"))
        )
        (builtins.readDir mcpDir));

    transformMcpServer = name: server: {
      enabled = !(server.disabled or false);
    } // (
      if server ? url then
        { type = "remote"; url = server.url; }
        // (lib.optionalAttrs (server ? headers) { headers = server.headers; })
      else if server ? command then
        { type = "local"; command = [ server.command ] ++ (server.args or [ ]); }
        // (lib.optionalAttrs (server ? env) { environment = server.env; })
      else
        { }
    );

    autoMcpServers = lib.mapAttrs transformMcpServer rawMcpServers;

    autoRules = lib.optionalString (autoWireEnabled && builtins.pathExists memoryFile)
      (builtins.readFile memoryFile);

  in lib.mkIf autoWireEnabled {
    programs.opencode = {
      enable = lib.mkDefault true;

      commands = lib.mkIf (autoCommands != { }) (lib.mkDefault autoCommands);

      skills = lib.mkIf (autoSkills != { }) (lib.mkDefault autoSkills);

      rules = lib.mkIf (autoRules != "") (lib.mkDefault autoRules);

      settings = lib.mkIf (autoMcpServers != { }) {
        mcp = lib.mkDefault autoMcpServers;
      };
    };
  };
}
