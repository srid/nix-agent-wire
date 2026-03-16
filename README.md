# Nix Autowiring for LLM Agents

> **WIP** - This project is under active development.

Home-manager modules that auto-wire standard configuration formats for LLM coding agents.

## Supported Agents

- **Claude Code** - `homeManagerModules.claude-code`
- **OpenCode** - `homeManagerModules.opencode`

## How It Works

Point `autoWire.dir` to a directory containing standard-format files:

```
your-config/
├── agents/*.md          # Agent definitions
├── commands/*.md        # Slash commands
├── skills/*/SKILL.md    # Local skills
├── mcp/*.nix            # MCP server configs
├── settings/claude-code.nix  # Tool-specific settings
└── memory.md            # Global rules/context
```

The modules automatically discover and wire these into the agent's configuration.

## Usage

```nix
{
  inputs.nix-agent-wire.url = "github:srid/nix-agent-wire";

  imports = [ nix-agent-wire.homeManagerModules.opencode ];

  programs.opencode.autoWire.dir = /path/to/your/config;
}
```

See `example/` for a minimal template.

## External Skills

Nix skills (`nix-flake`, `nix-haskell`) are automatically included from [juspay/skills](https://github.com/juspay/skills).

## CI

Run locally: `vira ci -b`
