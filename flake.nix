{
  description = "AI Code Agent Nix configuration";

  inputs.skills.url = "github:juspay/skills";

  outputs = { self, skills, ... }: {
    homeManagerModules.claude-code = { lib, ... }: {
      imports = [
        skills.homeModules.claude-code
        (import ./nix/agents/claude-code/home-manager-module.nix)
      ];
    };
    homeManagerModules.opencode = { lib, ... }: {
      imports = [
        skills.homeModules.opencode
        (import ./nix/agents/opencode/home-manager-module.nix)
      ];
    };
  };
}
