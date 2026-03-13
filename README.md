# Srid's Claude Code Configuration

This repo provides the `homeManagerModules.claude-code` flake output for auto-wiring your Claude Code configuration. My own Claude Code configuration exists in this same repo.

## Usage

Add as flake input:

```nix
{
  inputs = {
    AI.url = "github:srid/AI";
  };
}
```

Import the home-manager module and set `autoWire.dir`:

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

## Directory Layout

The `autoWire` feature expects this structure:

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
├── subagents/        # Subagent definitions (.md files)
│   └── pre-commit.md
├── mcp/              # MCP server configs (.nix files)
│   ├── chrome-devtools.nix
│   └── nixos-mcp.nix
├── settings.nix      # Claude Code settings
└── memory.md         # Persistent memory/context
```

**Files processed by autoWire:**

- **commands/*.md** → Slash commands (e.g., `/hack`, `/pr`)
- **subagents/*.md** → Custom subagents for Task tool
- **skills/*/SKILL.md** → Skills for specialized tasks
  - If `default.nix` exists, builds package and substitutes `@skillname@` placeholders
  - Example: `@article-extractor@` in SKILL.md becomes `/nix/store/.../bin/article-extractor`
- **mcp/*.nix** → MCP server configurations
- **settings.nix** → Applied to `programs.claude-code.settings`
- **memory.md** → Applied to `programs.claude-code.memory`

### Skill Placeholder Substitution

Skills with `default.nix` can use placeholders in `SKILL.md`:

1. Create `skills/myskill/default.nix` that builds a package
2. In `skills/myskill/SKILL.md`, use `@myskill@` where you need the binary path
3. The module builds the package and replaces `@myskill@` with `/nix/store/.../bin/myskill`

This lets skill definitions reference Nix-built tools without hardcoding paths.

