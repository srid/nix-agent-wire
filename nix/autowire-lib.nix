{ lib }:

{
  mergeAttrsList = lib.foldl' lib.mergeAttrs { };

  readCommands = dir:
    let path = toString dir + "/commands";
    in lib.optionalAttrs (builtins.pathExists path)
      (lib.mapAttrs'
        (fileName: _:
          lib.nameValuePair
            (lib.removeSuffix ".md" fileName)
            (builtins.readFile (path + "/${fileName}"))
        )
        (builtins.readDir path));

  readSkills = dir:
    let path = toString dir + "/skills";
    in lib.optionalAttrs (builtins.pathExists path)
      (lib.mapAttrs'
        (skillName: _:
          lib.nameValuePair
            skillName
            (path + "/" + skillName)
        )
        (lib.filterAttrs (_: type: type == "directory") (builtins.readDir path)));

  readAgentsContent = dir:
    let path = toString dir + "/agents";
    in lib.optionalAttrs (builtins.pathExists path)
      (lib.mapAttrs'
        (fileName: _:
          lib.nameValuePair
            (lib.removeSuffix ".md" fileName)
            (builtins.readFile (path + "/${fileName}"))
        )
        (builtins.readDir path));

  readAgentsPath = dir:
    let path = toString dir + "/agents";
    in lib.optionalAttrs (builtins.pathExists path)
      (lib.mapAttrs'
        (fileName: _:
          lib.nameValuePair
            (lib.removeSuffix ".md" fileName)
            (builtins.readFile (path + "/${fileName}"))
        )
        (builtins.readDir path));

  readMcpServers = dir:
    let path = toString dir + "/mcp";
    in lib.optionalAttrs (builtins.pathExists path)
      (lib.mapAttrs'
        (fileName: _:
          lib.nameValuePair
            (lib.removeSuffix ".nix" fileName)
            (import (path + "/${fileName}"))
        )
        (builtins.readDir path));

  readMemoryAttrset = dir:
    let path = toString dir + "/memory.md";
    in lib.optionalAttrs (builtins.pathExists path)
      { text = builtins.readFile path; };

  readMemoryString = dir:
    let path = toString dir + "/memory.md";
    in lib.optionalString (builtins.pathExists path)
      (builtins.readFile path);

  readSettings = name: dir:
    let path = toString dir + "/settings/${name}.nix";
    in lib.optionalAttrs (builtins.pathExists path)
      (import path);
}
