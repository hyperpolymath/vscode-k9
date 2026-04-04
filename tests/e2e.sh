#!/usr/bin/env bash
# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# vscode-k9 — End-to-End Tests
#
# Validates the K9 VS Code extension manifest, grammar files, snippets,
# language configuration, and example K9 contract file structure.
# No VS Code runtime required — these are static validation tests.
#
# Usage:
#   bash tests/e2e.sh
#   just e2e

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

PASS=0
FAIL=0
SKIP=0

# ─── Colour helpers ──────────────────────────────────────────────────
green() { printf '\033[32m%s\033[0m\n' "$*"; }
red()   { printf '\033[31m%s\033[0m\n' "$*"; }
yellow(){ printf '\033[33m%s\033[0m\n' "$*"; }
bold()  { printf '\033[1m%s\033[0m\n' "$*"; }

# ─── Assertion helpers ───────────────────────────────────────────────

check() {
    local name="$1" expected="$2" actual="$3"
    if echo "$actual" | grep -q "$expected"; then
        green "  PASS: $name"
        PASS=$((PASS + 1))
    else
        red "  FAIL: $name (expected '$expected', got '${actual:0:120}')"
        FAIL=$((FAIL + 1))
    fi
}

# check_json_valid <label> <file>
check_json_valid() {
    local name="$1" file="$2"
    if python3 -c "import json; json.load(open('$file'))" 2>/dev/null; then
        green "  PASS: $name is valid JSON"
        PASS=$((PASS + 1))
    else
        red "  FAIL: $name is NOT valid JSON ($file)"
        FAIL=$((FAIL + 1))
    fi
}

check_exists() {
    local name="$1" path="$2"
    if [ -e "$path" ]; then
        green "  PASS: $name"
        PASS=$((PASS + 1))
    else
        red "  FAIL: $name (path not found: $path)"
        FAIL=$((FAIL + 1))
    fi
}

skip_test() {
    yellow "  SKIP: $1 ($2)"
    SKIP=$((SKIP + 1))
}

echo "═══════════════════════════════════════════════════════════════"
echo "  vscode-k9 — End-to-End Tests"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# ─── Section 1: Required extension files ─────────────────────────────
bold "Section 1: Required extension files"

check_exists "package.json exists"                         "$PROJECT_DIR/package.json"
check_exists "language-configuration.json exists"          "$PROJECT_DIR/language-configuration.json"
check_exists "language-configuration-nickel.json exists"   "$PROJECT_DIR/language-configuration-nickel.json"
check_exists "syntaxes/k9.tmLanguage.json exists"          "$PROJECT_DIR/syntaxes/k9.tmLanguage.json"
check_exists "syntaxes/k9-nickel.tmLanguage.json exists"   "$PROJECT_DIR/syntaxes/k9-nickel.tmLanguage.json"
check_exists "snippets/k9.json exists"                     "$PROJECT_DIR/snippets/k9.json"
check_exists "snippets/k9-nickel.json exists"              "$PROJECT_DIR/snippets/k9-nickel.json"
check_exists "icons/ directory exists"                     "$PROJECT_DIR/icons"

echo ""

# ─── Section 2: package.json manifest validation ─────────────────────
bold "Section 2: Extension manifest (package.json)"

check_json_valid "package.json" "$PROJECT_DIR/package.json"

PKG=$(cat "$PROJECT_DIR/package.json")
check "package.json has name field"            '"name"'                  "$PKG"
check "package.json has displayName"           '"displayName"'           "$PKG"
check "package.json has description"           '"description"'           "$PKG"
check "package.json has publisher"             '"publisher".*hyperpolymath' "$PKG"
check "package.json has vscode engine"         '"vscode"'                "$PKG"
check "package.json contributes languages"     '"languages"'             "$PKG"
check "package.json contributes grammars"      '"grammars"'              "$PKG"
check "package.json contributes snippets"      '"snippets"'              "$PKG"
check "package.json references k9 language"   '"k9"'                    "$PKG"
check "package.json has license field"         '"license"'               "$PKG"
check "package.json has repository"            '"repository"'            "$PKG"

echo ""

# ─── Section 3: Grammar files (TextMate) ─────────────────────────────
bold "Section 3: TextMate grammar files"

check_json_valid "k9.tmLanguage.json" "$PROJECT_DIR/syntaxes/k9.tmLanguage.json"
check_json_valid "k9-nickel.tmLanguage.json" "$PROJECT_DIR/syntaxes/k9-nickel.tmLanguage.json"

K9_GRAMMAR=$(cat "$PROJECT_DIR/syntaxes/k9.tmLanguage.json")
check "k9 grammar has scopeName"   "scopeName"          "$K9_GRAMMAR"
check "k9 grammar has patterns"    "patterns"           "$K9_GRAMMAR"
check "k9 grammar has source.k9"   "source.k9"          "$K9_GRAMMAR"
check "k9 grammar has fileTypes"   "fileTypes"          "$K9_GRAMMAR"

K9NCL_GRAMMAR=$(cat "$PROJECT_DIR/syntaxes/k9-nickel.tmLanguage.json")
check "k9-nickel grammar has scopeName"   "scopeName"         "$K9NCL_GRAMMAR"
check "k9-nickel grammar has source.k9"   "source.k9"         "$K9NCL_GRAMMAR"

echo ""

# ─── Section 4: Snippets file validation ─────────────────────────────
bold "Section 4: Snippets files"

check_json_valid "k9.json snippets"           "$PROJECT_DIR/snippets/k9.json"
check_json_valid "k9-nickel.json snippets"    "$PROJECT_DIR/snippets/k9-nickel.json"

K9_SNIPPETS=$(cat "$PROJECT_DIR/snippets/k9.json")
# Snippets should be a non-empty JSON object
if python3 -c "
import json, sys
d = json.load(open('$PROJECT_DIR/snippets/k9.json'))
if not isinstance(d, dict) or len(d) == 0:
    sys.exit(1)
# Each snippet must have 'body' and 'prefix'
for name, snip in d.items():
    if 'body' not in snip or 'prefix' not in snip:
        print(f'Snippet {name} missing body or prefix')
        sys.exit(1)
" 2>/dev/null; then
    green "  PASS: k9 snippets have valid body/prefix structure"
    PASS=$((PASS + 1))
else
    red "  FAIL: k9 snippets structure invalid (missing body or prefix in entries)"
    FAIL=$((FAIL + 1))
fi

echo ""

# ─── Section 5: Language configuration ───────────────────────────────
bold "Section 5: Language configuration files"

check_json_valid "language-configuration.json"         "$PROJECT_DIR/language-configuration.json"
check_json_valid "language-configuration-nickel.json"  "$PROJECT_DIR/language-configuration-nickel.json"

LC=$(cat "$PROJECT_DIR/language-configuration.json")
check "language config has comments"   "comments"    "$LC"
check "language config has brackets"   "brackets"    "$LC"

echo ""

# ─── Section 6: Grammar–manifest consistency ─────────────────────────
bold "Section 6: Grammar–manifest consistency"

# Grammar paths in package.json should match actual files
GRAMMAR_PATHS=$(python3 -c "
import json
p = json.load(open('$PROJECT_DIR/package.json'))
for g in p.get('contributes', {}).get('grammars', []):
    print(g['path'])
" 2>/dev/null || echo "")

if [ -n "$GRAMMAR_PATHS" ]; then
    while IFS= read -r rel_path; do
        abs_path="$PROJECT_DIR/${rel_path#./}"
        if [ -f "$abs_path" ]; then
            green "  PASS: grammar path exists: $rel_path"
            PASS=$((PASS + 1))
        else
            red "  FAIL: grammar path missing: $rel_path (resolved: $abs_path)"
            FAIL=$((FAIL + 1))
        fi
    done <<< "$GRAMMAR_PATHS"
else
    skip_test "grammar path consistency" "python3 not available or no grammars"
fi

# Snippet paths in package.json should match actual files
SNIPPET_PATHS=$(python3 -c "
import json
p = json.load(open('$PROJECT_DIR/package.json'))
for s in p.get('contributes', {}).get('snippets', []):
    print(s['path'])
" 2>/dev/null || echo "")

if [ -n "$SNIPPET_PATHS" ]; then
    while IFS= read -r rel_path; do
        abs_path="$PROJECT_DIR/${rel_path#./}"
        if [ -f "$abs_path" ]; then
            green "  PASS: snippet path exists: $rel_path"
            PASS=$((PASS + 1))
        else
            red "  FAIL: snippet path missing: $rel_path"
            FAIL=$((FAIL + 1))
        fi
    done <<< "$SNIPPET_PATHS"
else
    skip_test "snippet path consistency" "python3 not available or no snippets"
fi

echo ""

# ═══════════════════════════════════════════════════════════════════════
# Summary
# ═══════════════════════════════════════════════════════════════════════
echo "═══════════════════════════════════════════════════════════════"
printf "  Results: "
green "PASS=$PASS" | tr -d '\n'
echo -n "  "
if [ "$FAIL" -gt 0 ]; then red "FAIL=$FAIL" | tr -d '\n'; else echo -n "FAIL=0"; fi
echo -n "  "
if [ "$SKIP" -gt 0 ]; then yellow "SKIP=$SKIP"; else echo "SKIP=0"; fi
echo "═══════════════════════════════════════════════════════════════"

exit "$FAIL"
