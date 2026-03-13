{
  description = "Claude Code Nix configuration";

  outputs = { self, ... }: {
    homeManagerModules.claude-code = import ./nix/agents/claude-code/home-manager-module.nix;
  };
}
