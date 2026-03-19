# Nix Autowiring for LLM Agents

Home-manager modules that auto-wire standard configuration formats for LLM coding agents.

## Why

LLM agents like Claude Code and OpenCode need configs scattered across multiple files and formats. This module lets you:

- Keep all agent configs in one directory structure
- Auto-discover and wire configs without manual symlinks
- Share configs across machines via Nix

## Supported Agents

| Agent | Module |
|-------|--------|
| Claude Code | `homeModules.claude-code` |
| OpenCode | `homeModules.opencode` |

## Usage

Add to your home-manager config:

```nix
{
  inputs.nix-agent-wire.url = "github:srid/nix-agent-wire";

  outputs = { inputs, ... }: {
    homeConfigurations.myuser = inputs.home-manager.lib.homeManagerConfiguration {
      modules = [
        inputs.nix-agent-wire.homeModules.opencode
        {
          programs.opencode.autoWire.dirs = [ ./my-agent-config ];
        }
      ];
    };
  };
}
```

## Directory Structure

```
your-config/
├── memory.md            # Global rules/context (injected into every session)
├── agents/*.md          # Sub-agents for specialized tasks
├── commands/*.md        # Slash commands (/my-command)
├── skills/*/SKILL.md    # Reusable skill modules
├── mcp/*.nix            # MCP server configs
└── settings/*.nix       # Tool-specific settings
```

### File Types

| File | Purpose |
|------|---------|
| `memory.md` | Rules/context added to every conversation. Put coding standards, git policies, tool preferences here. |
| `agents/*.md` | Specialized sub-agents. Each has YAML frontmatter with `name`, `description`, `tools`. |
| `commands/*.md` | Slash commands invoked as `/command-name`. Automate repetitive workflows. |
| `skills/*/SKILL.md` | Reusable skill modules. Loaded on demand when working with specific file types or frameworks. |
| `mcp/*.nix` | MCP server definitions. Return `{ command, args }` attrset. |
| `settings/*.nix` | Agent-specific settings (e.g., `claude-code.nix` for Claude Code permissions). |

## Examples

- [srid/nixos-config](https://github.com/srid/nixos-config/tree/master/AI) - Srid's configuration
- [juspay/AI](https://github.com/juspay/AI/tree/main/.agents/) - Collection of reusable skills for LLM coding agents
- `example/` in this repo - Minimal template showing all file types

## CI

Run locally: `vira ci -b`
