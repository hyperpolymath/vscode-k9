<!-- SPDX-License-Identifier: MPL-2.0 -->
<!-- (PMPL-1.0-or-later preferred; MPL-2.0 required for VS Code marketplace) -->
<!-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> -->
# TOPOLOGY.md — vscode-k9

## Purpose

VS Code extension providing syntax highlighting, language configuration, and snippets for K9 contractile validator files. Supports both `.k9` (YAML-like Kennel format) and `.k9.ncl` (Nickel-based Yard/Hunt format). Published to the VS Code marketplace (MPL-2.0 required by platform).

## Module Map

```
vscode-k9/
├── syntaxes/                          # TextMate grammars (K9 + Nickel variants)
├── snippets/                          # Code snippets for K9 patterns
├── src/                               # Extension TypeScript entry point
├── icons/                             # File type icons
├── language-configuration.json        # Config for .k9 (Kennel format)
├── language-configuration-nickel.json # Config for .k9.ncl (Nickel format)
├── package.json                       # VS Code extension manifest
└── docs/                              # Extension documentation
```

## Data Flow

```
[.k9 / .k9.ncl file opened] ──► [syntaxes/ grammar]      ──► [syntax highlighting]
                            └──► [snippets/]              ──► [completions]
                            └──► [language-configuration] ──► [bracket/comment behaviour]
```
