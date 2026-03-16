{
  description = "Nix autowiring for LLM agents";

  outputs = { self, ... }: {
    homeModules.claude-code = import ./nix/agents/claude-code/home-manager-module.nix;
    homeModules.opencode = import ./nix/agents/opencode/home-manager-module.nix;
  };
}
