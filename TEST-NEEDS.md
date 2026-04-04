# TEST-NEEDS.md — vscode-k9

## CRG Grade: C — ACHIEVED 2026-04-04

## Current Test State

| Category | Count | Notes |
|----------|-------|-------|
| Test infrastructure | Present | `tests/` directory structure |
| FFI tests | Present | `src/interface/ffi/test/` |
| Verification tests | Present | `verification/tests/` |
| Aspect modules | Present | `src/aspects/` |

## What's Covered

- [x] Test framework infrastructure
- [x] FFI verification layer
- [x] Aspect-based organization

## Still Missing (for CRG B+)

- [ ] K9 language syntax tests
- [ ] VSCode extension integration tests
- [ ] Syntax highlighting tests
- [ ] Performance benchmarks
- [ ] End-to-end editor tests

## Run Tests

```bash
cd /var/mnt/eclipse/repos/vscode-k9 && npm test
```

## Session 9 additions (2026-04-04)

### What Was Added

| Area | Tests Added | Location |
|------|-------------|----------|
| E2E tests | 6 sections: extension files, package.json manifest fields, TextMate grammar JSON validity, snippets body/prefix structure, language-configuration JSON, grammar–manifest path consistency | `tests/e2e.sh` |
| CI runner | GitHub Actions workflow for E2E suite | `.github/workflows/e2e.yml` |

### Updated Test Counts

| Suite | Count | Status |
|-------|-------|--------|
| E2E (shell-based) | 6 test sections | All passing |
| CI workflows | 21 | Running tests on GitHub Actions |
