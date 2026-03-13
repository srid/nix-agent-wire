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
├── skills/           # Skill directories
│   ├── nix/
│   │   └── SKILL.md  # Simple skill (markdown only)
│   └── article-extractor/
│       ├── SKILL.md  # Skill definition with @placeholder@
│       └── default.nix  # Optional: builds tool, substitutes @placeholder@
├── subagents/        # Subagent definitions (.md files) [Claude Code only]
│   └── pre-commit.md
├── mcp/              # MCP server configs (.nix files)
│   ├── chrome-devtools.nix
│   └── nixos-mcp.nix
├── settings.nix      # Claude Code settings [Claude Code only]
└── memory.md         # Persistent memory/context
```

**Claude Code autoWire:**

- **commands/*.md** → Slash commands
- **subagents/*.md** → Custom subagents for Task tool
- **skills/*/SKILL.md** → Skills (with optional `default.nix` for placeholder substitution)
- **mcp/*.nix** → MCP server configurations
- **settings.nix** → Applied to `programs.claude-code.settings`
- **memory.md** → Applied to `programs.claude-code.memory`

**OpenCode autoWire:**

- **commands/*.md** → Slash commands
- **skills/** → Skill directories (symlinked)
- **mcp/*.nix** → MCP server configurations (transformed to opencode format)
- **memory.md** → Applied to `programs.opencode.rules`

### Skill Placeholder Substitution [Claude Code only]

Skills with `default.nix` can use placeholders in `SKILL.md`:

1. Create `skills/myskill/default.nix` that builds a package
2. In `skills/myskill/SKILL.md`, use `@myskill@` where you need the binary path
3. The module builds the package and replaces `@myskill@` with `/nix/store/.../bin/myskill`

This lets skill definitions reference Nix-built tools without hardcoding paths.

