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
├── agents/           # Agent definitions (.md files)
│   └── code-reviewer.md
├── mcp/              # MCP server configs (.nix files)
│   ├── chrome-devtools.nix
│   └── nixos-mcp.nix
├── settings.nix      # Claude Code settings [Claude Code only]
└── memory.md         # Persistent memory/context
```

**Both modules autoWire:**

- **commands/*.md** → Slash commands
- **agents/*.md** → Custom agents (use `mode: subagent` in frontmatter for OpenCode)
- **skills/*/SKILL.md** → Skills
- **mcp/*.nix** → MCP server configurations
- **memory.md** → Global rules

**Claude Code only:**

- **settings.nix** → `programs.claude-code.settings`
- **skills/*/default.nix** → Placeholder substitution

**OpenCode only:**

- Uses `programs.mcp.servers` + `enableMcpIntegration` for MCP

### Skill Placeholder Substitution [Claude Code only]

Skills with `default.nix` can use placeholders in `SKILL.md`:

1. Create `skills/myskill/default.nix` that builds a package
2. In `skills/myskill/SKILL.md`, use `@myskill@` where you need the binary path
3. The module builds the package and replaces `@myskill@` with `/nix/store/.../bin/myskill`

This lets skill definitions reference Nix-built tools without hardcoding paths.

