{
  description = "AI Code Agent Nix configuration";

  outputs = { self, ... }: {
    homeManagerModules.claude-code = import ./nix/agents/claude-code/home-manager-module.nix;
    homeManagerModules.opencode = import ./nix/agents/opencode/home-manager-module.nix;
  };
}
