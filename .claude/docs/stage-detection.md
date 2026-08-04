# Stage Detection — Single Source of Truth

Every consumer that needs to answer "which phase is this project in?" uses the
ladder below. Do not re-derive it locally.

**Consumers:** `.claude/statusline.sh`, `.claude/skills/help/SKILL.md`,
`.claude/skills/project-stage-detect/SKILL.md`, `.claude/skills/gate-check/SKILL.md`
(auto-detect path), `.claude/skills/adopt/SKILL.md`.

---

## The ladder

**Step 1 — explicit override.** If `production/stage.txt` exists and is non-empty,
its value is authoritative. It is written only by `/gate-check` on a PASS the user
approved, and once by `/start`. Valid values: `Concept`, `Systems Design`,
`Technical Setup`, `Pre-Production`, `Production`, `Polish`, `Release`, `Live`.

**Step 2 — infer from artifacts.** Only if `stage.txt` is absent or empty.
Check most-advanced first; the first match wins.

| # | Condition | Stage |
|---|---|---|
| 1 | `src/` contains ≥10 source files | `Production` |
| 2 | any `production/epics/**/story-*.md` exists | `Pre-Production` |
| 3 | `docs/architecture/architecture.md` or any `docs/architecture/adr-*.md` exists | `Technical Setup` |
| 4 | `design/gdd/systems-index.md` exists | `Systems Design` |
| 5 | `design/gdd/game-concept.md` exists | `Concept` |
| 6 | none of the above | `Concept` (fresh project) |

Source file extensions for rule 1: `.gd .cs .cpp .c .h .hpp .rs .py .js .ts`.

**`Polish` and `Release` are explicit-only.** No artifact distinguishes them from
`Production` — they are reachable solely via `production/stage.txt`. A detector
must never infer them.

---

## Why the rules are what they are

Two traps produced the three mutually-inconsistent detectors this file replaces:

**Engine configuration is not a stage signal.** `/setup-engine` runs in **Concept**
(phase 1). Any ladder keyed on "engine configured" therefore misclassifies a project
that has only a concept and an engine. The previous `project-stage-detect` table used
"engine not configured → Technical Setup" and "engine configured → Pre-Production",
which skipped two whole phases for exactly that common case; `statusline.sh` used the
inverse relationship. Engine configuration appears nowhere in the ladder above.

**Story files live under epics.** `/create-stories` writes
`production/epics/[slug]/story-*.md`. The old `/help` ladder checked
`production/stories/*.md` — a path no skill in the repo writes, so the
Pre-Production rung was unreachable and such projects fell through to
`Technical Setup`.

---

## Reference implementation (shell)

```bash
detect_stage() {
  # 1. explicit override
  if [ -s "production/stage.txt" ]; then
    head -1 production/stage.txt | tr -d '\r\n'
    return
  fi

  # 2. infer, most-advanced first
  local src_count=0
  if [ -d "src" ]; then
    src_count=$(find src -type f \( -name "*.gd" -o -name "*.cs" -o -name "*.cpp" \
      -o -name "*.c" -o -name "*.h" -o -name "*.hpp" -o -name "*.rs" \
      -o -name "*.py" -o -name "*.js" -o -name "*.ts" \) 2>/dev/null | wc -l | tr -d ' ')
  fi

  if [ "$src_count" -ge 10 ] 2>/dev/null; then
    echo "Production"
  elif ls production/epics/*/story-*.md >/dev/null 2>&1; then
    echo "Pre-Production"
  elif [ -f "docs/architecture/architecture.md" ] \
    || ls docs/architecture/adr-*.md >/dev/null 2>&1; then
    echo "Technical Setup"
  elif [ -f "design/gdd/systems-index.md" ]; then
    echo "Systems Design"
  else
    echo "Concept"
  fi
}
```

Rules 5 and 6 collapse to the same answer, so the implementation stops at rule 4.

---

## Catalog phase keys

Skills that index into `.claude/docs/workflow-catalog.yaml` need the key, not the
display name:

| Display name | Catalog key |
|---|---|
| Concept | `concept` |
| Systems Design | `systems-design` |
| Technical Setup | `technical-setup` |
| Pre-Production | `pre-production` |
| Production | `production` |
| Polish | `polish` |
| Release | `release` |
| Live | *(none — post-release, no catalog phase)* |
