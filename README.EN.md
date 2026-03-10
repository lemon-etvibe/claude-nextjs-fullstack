<p align="center">
  <img src="https://img.shields.io/badge/Claude_Code-Plugin-5A67D8?style=for-the-badge&logo=anthropic&logoColor=white" alt="Claude Code Plugin" />
  <img src="https://img.shields.io/badge/Next.js-16-000000?style=for-the-badge&logo=next.js&logoColor=white" alt="Next.js 16" />
  <img src="https://img.shields.io/badge/Drizzle_ORM-0.45-C5F74F?style=for-the-badge&logo=drizzle&logoColor=black" alt="Drizzle ORM" />
  <img src="https://img.shields.io/badge/TypeScript-5.x-3178C6?style=for-the-badge&logo=typescript&logoColor=white" alt="TypeScript" />
</p>

# etvibe-nextjs-fullstack

> 🇰🇷 [한국어 README](./README.md)

> **AI-First Full-Stack Development Workflow**
> A Claude Code plugin for Next.js 16 + Drizzle ORM + Better Auth projects

```
Plugin Name: enf
Namespace:   /enf:command (e.g. /enf:commit, /enf:code-review)
```

---

## Why This Plugin?

| Problem | Solution |
|---------|----------|
| Inconsistent code styles across teams | **6 Skills** auto-enforce conventions |
| Repetitive boilerplate | **17 Commands** automate workflows |
| Steep learning curve for the tech stack | **4 Agents** guide best practices |
| Code review bottlenecks | AI-powered pre-review for quality |

---

## Quick Start

```bash
# 1. Add marketplace (one-time)
claude plugin marketplace add https://github.com/lemon-etvibe/claude-nextjs-fullstack

# 2. Install plugin
claude plugin install enf@enf

# 3. Use in your project
cd ~/projects/my-app && claude
```

```bash
# Verify
/agents      # List agents
/enf:init    # Plugin guide
```

---

## Tech Stack

| Technology | Version | Purpose |
|:-----------|:-------:|---------|
| **Next.js** | 16.x | App Router + Turbopack |
| **React** | 19.x | Server Components first |
| **Drizzle ORM** | 0.45.x | PostgreSQL + pgTable |
| **Better Auth** | 1.4.x | Session-based authentication |
| **Tailwind CSS** | 4.x | CSS-first configuration |
| **shadcn/ui** | latest | Radix-based components |

---

## What's Included

### Agents (4)

Role-specific AI agents to support your development workflow.

| Agent | Role | Features |
|-------|------|----------|
| **dev-assistant** | Code implementation/review/refactoring | Write/Edit capable, context7 integration |
| **architecture-expert** | System design/data modeling | Design only (no implementation) |
| **performance-expert** | Bundle analysis/Core Web Vitals | next-devtools integration |
| **docs-writer** | API/component documentation | Template-based automation |

### Commands (17)

All commands use the `/enf:` namespace.

| Category | Command | Description |
|:--------:|---------|-------------|
| **Core** | `code-review` | Code quality inspection (TypeScript, performance, security) |
| | `design-feature` | Architecture design for new features (Route, Model, API) |
| | `schema-design` | Drizzle schema design and review |
| | `perf-audit` | Bundle size, waterfall, Core Web Vitals analysis |
| **Dev** | `refactor` | Code refactoring suggestions and application |
| | `type-check` | TypeScript strict mode verification |
| | `waterfall-check` | Sequential await detection → Promise.all suggestion |
| **Git** | `task` | Task definition → automatic branch creation |
| | `commit` | Conventional Commits format |
| | `push` | Safety checks before remote push |
| | `pr` | GitHub PR creation (auto-applied template) |
| **Docs** | `generate-docs` | Auto-generate Server Action/API docs |
| | `component-docs` | Component Props documentation |
| | `update-changelog` | CHANGELOG.md auto-update |
| **Test** | `test` | Test execution and test code generation (Vitest, Playwright) |
| **Diagnostics** | `health` | Project version compatibility check |
| **Guide** | `init` | Plugin usage and project guide |

### Skills (6)

Keyword-activated knowledge bases.

| Skill | Activation Keywords | Content |
|-------|--------------------|---------|
| **coding-conventions** | convention, naming | Import order, naming rules, commit messages |
| **better-auth** | auth, login, session | Session management, RBAC, Server Action integration |
| **drizzle** | Drizzle, schema, DB | pgTable schema, query patterns, drizzle-kit CLI |
| **tailwind-v4-shadcn** | Tailwind, shadcn, form | CSS-first config, Form patterns, theming |
| **testing** | test, vitest, playwright | Vitest, Testing Library, Playwright E2E |
| **error-handling** | error, API Route, Error Boundary | Server Action/API Route/DB error handling patterns |

### MCP Servers (2)

| Server | Purpose |
|--------|---------|
| **context7** | Real-time library docs lookup (Next.js, Drizzle, etc.) |
| **next-devtools** | Next.js dev server integration (routes, error analysis) |

---

## Bundled Plugins

Verified plugins automatically installed by the setup script.

### Anthropic Official

| Plugin | Purpose |
|--------|---------|
| **playwright** | Playwright-based E2E test authoring/execution |
| **pr-review-toolkit** | 6-perspective PR code review (`/review-pr`) |
| **commit-commands** | Change analysis-based commit message generation (`/commit`) |
| **feature-dev** | Feature development workflow guide |
| **security-guidance** | OWASP Top 10 security vulnerability scanning |
| **context7** | Real-time library documentation lookup |
| **frontend-design** | High-quality frontend UI design generation |
| **code-review** | Automated code review and improvement suggestions |

### Community

| Plugin | Source | Purpose |
|--------|--------|---------|
| **javascript-typescript** | wshobson/agents | Advanced JS/TS patterns and optimization |
| **database-design** | wshobson/agents | Database schema design expert |

---

## Workflow

```
/enf:task "feature"          →  Branch creation
       ↓
/enf:design-feature          →  Architecture design (optional)
       ↓
    [Implement]              →  dev-assistant
       ↓
/enf:code-review             →  Quality inspection
       ↓
/enf:commit → /enf:push → /enf:pr
```

---

## Documentation

| Document | Description |
|----------|-------------|
| **[Team Onboarding](./docs/TEAM-ONBOARDING.md)** | Quick start for new team members |
| [Commands Reference](./docs/COMMANDS-REFERENCE.md) | Command quick reference |
| [Installation](./docs/INSTALLATION.md) | Detailed installation and troubleshooting |
| [Guidelines](./docs/GUIDELINES.md) | Plugin philosophy and workflow |
| [Customization](./docs/CUSTOMIZATION.md) | Plugin extension guide |
| [Agents Manual](./docs/AGENTS-MANUAL.md) | Detailed agent usage |
| [Scenario Guides](./docs/SCENARIO-GUIDES.md) | Workflow guides by scenario |
| [Compatibility](./docs/COMPATIBILITY.md) | Supported version matrix |
| [Contributing](./docs/CONTRIBUTING.md) | Contribution guide |
| [CHANGELOG](./CHANGELOG.md) | Version history |

---

## Update

```bash
claude plugin update enf@enf
```

---

<p align="center">
  <sub>Built with Claude Code by <b>etvibe</b> AI Team</sub>
</p>

## Contact

- **Issues**: [GitHub Issues](https://github.com/lemon-etvibe/claude-nextjs-fullstack/issues)
- **Email**: won4519@etribe.co.kr

## License

MIT
