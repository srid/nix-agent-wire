# Srid's AI Code Agent Configuration

This repo provides home-manager modules for auto-wiring AI code agent configurations:

- `homeManagerModules.claude-code` - Claude Code
- `homeManagerModules.opencode` - OpenCode

## Usage

Add as flake input:

```nix
{
  inputs = {
    AI.url = "github:srid/AI";
  };
}
```

### Claude Code

```nix
{
  imports = [
    AI.homeManagerModules.claude-code
  ];

  programs.claude-code = {
    enable = true;
    autoWire.dir = AI;
  };
}
```

### OpenCode

```nix
{
  imports = [
    AI.homeManagerModules.opencode
  ];

  programs.opencode = {
    enable = true;
    autoWire.dir = AI;
  };
}
```

## Directory Layout

Both modules use `autoWire` to discover configuration from a directory:

```
.
├── commands/         # Slash commands (.md files)
│   ├── hack.md       # /hack command
│   └── pr.md         # /pr command
├── skills/           # Local skill directories
│   └── haskell/
│       └── SKILL.md  # Skill definition
├── agents/           # Agent definitions (.md files)
│   └── code-reviewer.md
├── mcp/              # MCP server configs (.nix files)
│   ├── chrome-devtools.nix
│   └── nixos-mcp.nix
├── settings/         # Tool-specific settings
│   └── claude-code.nix  # Claude Code settings
└── memory.md         # Persistent memory/context
```

**External Skills:**

Nix skills (`nix-flake`, `nix-haskell`) are provided by [juspay/skills](https://github.com/juspay/skills) and automatically included.

**Both modules autoWire:**

- **commands/*.md** → Slash commands
- **agents/*.md** → Custom agents (use `mode: subagent` in frontmatter for OpenCode)
- **skills/*/** → Skills (symlinked)
- **mcp/*.nix** → MCP server configurations
- **memory.md** → Global rules

**Claude Code only:**

- **settings/claude-code.nix** → `programs.claude-code.settings`

**OpenCode only:**

- Uses `programs.mcp.servers` + `enableMcpIntegration` for MCP
