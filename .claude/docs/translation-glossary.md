# Translation Glossary (翻译术语表)

Shared vocabulary for translating AskUserQuestion user-facing strings (prompts,
headers, option labels, option descriptions) to Chinese. Used by anyone updating
agent or skill files for bilingual UX.

This glossary exists because the global language policy
(`.claude/docs/language-policy.md`) deliberately does not name the AskUserQuestion
tool — mentioning it there breaks the JSON schema construction. So translation
of AskUserQuestion content is done **at the source file** (the natural-language
description inside the skill/agent that the LLM copies verbatim into the tool
call).

## Scope of translation

When editing a skill or agent file, translate these strings to Chinese:

- `**Prompt**: "..."` — the question text shown to the user
- `**Header**: "..."` — the chip label (4–6 Chinese chars, ≤12 char limit)
- `**Options**: - \`label\` — description` — both the option label and description

**Do NOT translate** in those files:

- Field names in the markdown structure: `**Prompt**`, `**Header**`, `**Options**`
- The surrounding LLM-facing instructions (e.g. "Use `AskUserQuestion` with these exact options")
- Slash commands: `/start`, `/setup-engine`, `/gate-check`, etc.
- File paths: `production/sprints/`, `design/gdd/`, etc.
- Code identifiers, function names, class names
- Tool/parameter names: `AskUserQuestion`, `questions`, `options`, `multiSelect`, `label`, `description`
- Template variables: `[recommended first step]`, `[concept]`, `[hint]`, etc.
- File-content mapping table values: when a label maps to a literal file value
  like `Full` → `full`, only the label changes; the value stays English.

## Header conventions

**DO NOT add `Header:` lines to skill files during translation.** Earlier we
tried to "harden" schemas by adding explicit `- Header: "..."` bullets next to
`- Prompt:` and `- Options:` — this is an anti-pattern. Listing three fields
side-by-side makes the description look like a flat object, and the model then
constructs `{ prompt, header, options }` at the top level, missing the required
outer `questions: [...]` array wrapper. The exact error:

```
InputValidationError: AskUserQuestion failed due to the following issue:
The required parameter `questions` is missing.
```

**Correct approach**: leave the original 2-bullet format (`Prompt` + `Options`)
unchanged in structure, and only translate the string values. The model will
generate a Chinese `header` value at runtime — that is fine. Never name the
`Header` field explicitly in skill prose.

## Common verdicts and decisions

Translate consistently across all skills:

| English | 中文 |
|---|---|
| PASS | 通过 |
| CONCERNS | 有问题 |
| FAIL | 不通过 / 失败 |
| BLOCKED | 受阻 |
| READY | 就绪 |
| NEEDS WORK | 需修改 |
| MISSING | 缺失 |
| INCOMPLETE | 不完整 |
| ADEQUATE | 达标 |
| APPROVED | 批准 |
| MAJOR REVISION NEEDED | 需大改 |
| PROCEED | 推进 |
| PIVOT | 转向 |
| KILL | 终止 |
| ABANDON | 放弃 |
| GO / NO-GO | 通过 / 不通过 |

## Common action choices

| English | 中文 |
|---|---|
| Yes | 是 |
| No | 否 |
| Approve | 批准 |
| Revise | 修改 |
| Reject | 拒绝 |
| Cancel | 取消 |
| Continue | 继续 |
| Skip | 跳过 |
| Retry | 重试 |
| Confirm | 确认 |
| Acknowledge | 知悉 / 已确认 |
| Roll back | 回滚 |
| Sign off | 签字通过 |

## Workflow phases

| English | 中文 |
|---|---|
| Concept | 概念 |
| Systems Design | 系统设计 |
| Architecture | 架构 |
| Pre-Production | 预制作 |
| Production | 制作 |
| Polish | 打磨 |
| Release | 发布 |
| Live-Ops | 运营 |

## Review modes (from /start)

| English label | 中文 label | File value (English, do NOT change) |
|---|---|---|
| Full | 完整审核 | `full` |
| Lean (recommended) | 精简审核（推荐） | `lean` |
| Solo | 独立模式 | `solo` |

## Stays in English (proper nouns / framework terms)

These are CCGS-framework or industry-standard terms that do not get translated:

- **Roles**: Director (e.g., Creative Director, Art Director), Producer, QA Lead, Lead Programmer
- **Artifacts**: GDD, ADR, MVP, PR, ID, TR (traceability requirement)
- **Workflow concepts**: Story, Epic, Sprint, Milestone, Backlog
- **Industry terms**: game jam, DLC, KPI
- **All slash commands**: `/brainstorm`, `/setup-engine`, `/dev-story`, etc.
- **All file paths**: `design/gdd/...`, `production/sprints/...`
- **All code identifiers**: function names, class names, parameter names

## Style guidance

- Use Chinese full-width punctuation in Chinese prose: `（）`、`，`、`：`、`？`、`！`
- Keep ASCII half-width punctuation when adjacent to English/code: `Full / Lean / Solo` (slashes), `text — more` (em dashes for prose)
- When a literal English term appears inside Chinese (e.g. brand or command),
  use the English term without translation: `运行 /brainstorm 命令` (not `運行 brainstorm 命令`)
- Avoid translating identifying letter prefixes: `A) 还没有想法` (keep `A)`)
- Avoid translating `[bracket-template-variables]`

## Example translation

**Before:**
```markdown
- **Prompt**: "Is the gate ready to advance?"
- **Options**:
  - `PASS` — All criteria met, advance to next phase
  - `CONCERNS` — Most criteria met, document gaps before advancing
  - `FAIL` — Critical criteria unmet, blocked
```

**After:**
```markdown
- **Prompt**: "闸口可以推进到下一阶段了吗？"
- **Header**: "闸口判定"
- **Options**:
  - `通过` — 所有标准达成，可推进到下一阶段
  - `有问题` — 大部分标准达成，推进前需记录缺口
  - `不通过` — 关键标准未达成，受阻
```

Note: a `**Header**` line was added — this hardens the AskUserQuestion call
against schema-construction errors when the field would otherwise be inferred.
