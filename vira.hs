-- Pipeline configuration for Vira <https://vira.nixos.asia/>

\ctx pipeline ->
  let
    isMain = ctx.branch == "master"
  in
    pipeline
      { build.systems = ["x86_64-linux", "aarch64-darwin"]
      , build.flakes = [".", "./nix/agents/claude-code/test"]
      , signoff.enable = True
      }
