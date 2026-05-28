# docs.page Documentation Setup

**Date:** 2026-05-28
**Status:** Approved

## Overview

Set up [docs.page](https://docs.page) (by Invertase) as the documentation site for `impaktfull_cli`. Documentation is fully auto-generated from Dart source files and committed to the repo. docs.page reads from GitHub — no external build pipeline required.

Published URL: `https://docs.page/impaktfull/impaktfull_cli`

## Goals

- Comprehensive, public-facing documentation for all CLI commands
- Single source of truth: docs derived from Dart command/config source files
- CI enforces docs stay in sync with source
- `cli.impaktfull.com` redirects to docs.page; `install.sh` and `assets/backgrounds/` remain accessible at their existing URLs

## File Structure

```
impaktfull_cli/
├── docs.json                        ← docs.page config (name, theme, navigation)
├── docs/
│   ├── index.mdx                    ← Overview + quick install
│   ├── installation.mdx             ← Install methods (script, pub.dev, source)
│   ├── configuration.mdx            ← ENV variables reference (auto-generated)
│   ├── extending.mdx                ← Plugin system / subclassing ImpaktfullCli
│   └── commands/
│       ├── index.mdx                ← Commands overview
│       ├── android.mdx              ← auto-generated
│       ├── apple.mdx                ← auto-generated
│       ├── ci_cd.mdx                ← auto-generated
│       ├── open_source.mdx          ← auto-generated
│       ├── slack.mdx                ← auto-generated
│       └── test_coverage.mdx        ← auto-generated
├── tool/
│   └── generate_docs.dart           ← Generation script
└── web/
    └── index.html                   ← Replaced with meta-redirect to docs.page
```

## docs.json

```json
{
  "name": "impaktfull CLI",
  "description": "A CLI that combines all tools for development, testing, CI/CD",
  "theme": {
    "primary": "#7D64F2"
  },
  "sidebar": [
    {
      "group": "Getting Started",
      "pages": ["index", "installation", "configuration"]
    },
    {
      "group": "Commands",
      "pages": [
        "commands/index",
        "commands/android",
        "commands/apple",
        "commands/ci_cd",
        "commands/open_source",
        "commands/slack",
        "commands/test_coverage"
      ]
    },
    {
      "group": "Advanced",
      "pages": ["extending"]
    }
  ]
}
```

## Generation Script (`tool/generate_docs.dart`)

The script uses **ArgParser introspection** — it programmatically instantiates every root command class, walks the command tree via `Command.subcommands`, and reads `command.argParser.options` directly. This is guaranteed accurate with no source parsing.

ENV variables are extracted by reading `impaktfull_cli_environment_variables.dart` with regex on the `static const` string declarations (the only file that needs source-level parsing).

### Sources

| Source                                                                 | Extracted data                                                          | Method                                             |
| ---------------------------------------------------------------------- | ----------------------------------------------------------------------- | -------------------------------------------------- |
| Root command classes (`AndroidRootCommand`, etc.)                      | Command tree: names, descriptions, subcommands                          | Programmatic instantiation + `Command.subcommands` |
| `ArgParser.options` on each command                                    | Option name, `help`, `defaultsTo`, `allowed`, `mandatory`, `isMultiple` | ArgParser introspection API                        |
| `lib/src/core/util/args/env/impaktfull_cli_environment_variables.dart` | All `static const` env key strings                                      | Regex on source file                               |

### Generated output per command page

Each `docs/commands/<integration>.mdx` is structured as:

````mdx
---
title: <root command name>
---

<root command description>

## <subcommand name>

<subcommand description>

**Usage:**

```bash
dart run impaktfull_cli <root> <sub> [options]
```
````

| Option   | Description | Required | Default      | Allowed   |
| -------- | ----------- | -------- | ------------ | --------- |
| --<name> | <help>      | Yes/No   | <defaultsTo> | <allowed> |

````

### Commands covered

All 6 root commands and their subcommands:

| Root | Subcommands |
|---|---|
| `android` | `create_keystore` |
| `apple` | `provisioning_profile install` |
| `ci_cd` | `report_status`, `setup` |
| `open_source` | `report_new_release` |
| `slack` | `send_message` |
| `test_coverage` | `dart`, `flutter` |

### Invocation

```bash
dart run tool/generate_docs.dart
````

Run locally after changing any command or config file, then commit the updated `docs/` files.

## Manually Written Pages

These pages are written once and maintained by hand (they describe concepts, not command flags):

- `docs/index.mdx` — project overview, one-liner install command
- `docs/installation.mdx` — install script, pub.dev install, from source
- `docs/extending.mdx` — how to subclass `ImpaktfullCli`, add custom plugins
- `docs/commands/index.mdx` — brief overview of the command groups

`docs/configuration.mdx` (ENV variables) is auto-generated by the script.

## CI Integration

Add a step to `.github/workflows/test.yaml`:

```yaml
- name: Check docs are up to date
  run: |
    dart run tool/generate_docs.dart
    git diff --exit-code docs/
```

This fails the build if any source change affects command names, descriptions, or options without a corresponding `docs/` update.

## web/index.html

Replace the current landing page content with a meta-redirect:

```html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8" />
    <meta
      http-equiv="refresh"
      content="0; url=https://docs.page/impaktfull/impaktfull_cli"
    />
    <title>impaktfull CLI</title>
  </head>
  <body>
    <p>
      Redirecting to
      <a href="https://docs.page/impaktfull/impaktfull_cli"
        >docs.page/impaktfull/impaktfull_cli</a
      >…
    </p>
  </body>
</html>
```

`web/install.sh` and `web/assets/backgrounds/` are not touched — they remain accessible at their current URLs on `cli.impaktfull.com`.

## Out of Scope

- Custom domain for docs.page (not supported for slash-based URLs like `/impaktfull/impaktfull_cli`)
- Documentation for plugins that are not exposed as CLI commands (appcenter, flutter, git, one_password, testflight, playstore, impaktfull_dashboard) — these are programmatic APIs, not CLI commands
