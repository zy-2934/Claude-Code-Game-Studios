# Language Policy (语言策略)

This project uses a **bilingual policy** to separate persistent technical
artifacts from user-facing communication. This applies globally to the main
session, every subagent, and every skill.

## English (持久化技术内容必须使用英文)

The following remain in English unconditionally:

- All code: identifiers, function/class/variable names, comments inside source
- File paths, directory names, filenames
- File contents when writing or editing source/config/test/doc files in the
  repository (the artifact itself is English; the conversation about it is Chinese)
- Technical terminology with no settled Chinese equivalent
- Conventional Commits prefixes: `feat:`, `fix:`, `chore:`, `docs:`, `test:`,
  `refactor:`, `perf:`, `build:`, `ci:`, `style:`, `revert:`
- API names, library/package names, engine API references
- Frontmatter fields in agent/skill/doc files (`name:`, `description:`, etc.)
- ADR titles, story IDs, epic slugs, sprint names

## 中文 (面向用户的所有沟通使用中文)

The following are translated to Chinese:

- All replies, status updates, progress messages to the user
- Explanations of code, design, decisions, architecture, rationale
- Summaries of work completed or planned
- File-content excerpts shown to the user — quote the file verbatim in English,
  then provide a Chinese annotation/summary alongside
- Commit message subject and body **after** the English prefix
- Pull-request titles **after** the English prefix, and PR descriptions
- AskUserQuestion content: question text, header labels, option labels and
  descriptions all in Chinese
- Test plan narratives, retrospective narratives, postmortems (the narrative
  prose; field names and identifiers stay English)
- GDD section discussion (the GDD file itself remains English; conversation
  about it is Chinese)

## Examples

**Commit message — correct:**
```
feat: 添加战斗系统的近战命中盒检测

实现 MeleeHitbox 节点，支持帧精确的命中判定。
Story: EPIC-002-S04
```

**Commit message — wrong:**
```
添加: 战斗系统命中盒                    # missing English prefix
feat: add melee hitbox detection      # subject not Chinese
```

**Reply to user — correct:**
> 我已实现 `calculate_damage()` 函数，位于 [combat.gd:42](src/gameplay/combat.gd:42)。
> 公式遵循 GDD 第 4 节：`damage = base * (1 + crit_mult * is_crit)`。

**Reply to user — wrong:**
> I've implemented `calculate_damage()` at combat.gd:42. The formula follows GDD section 4.

**File write — correct:**
The GDD file itself contains English prose. The agent's chat response about it
is Chinese.

## Edge Cases

- **Technical terms in Chinese prose:** Use Chinese first with English in
  parentheses on first mention, then either form thereafter:
  信号 (Signal), 节点 (Node), 实体组件系统 (ECS), 状态机 (State Machine)
- **Code snippets in replies:** The code itself stays English; surrounding
  explanation in Chinese.
- **Tool output, logs, error messages:** Quote verbatim (often English), then
  explain in Chinese.
- **Existing English docs and comments:** Do not auto-translate. Only new
  content authored under this policy follows the rule.
- **Conflict with engine reference docs:** Engine reference docs (e.g., under
  `docs/engine-reference/`) stay fully English — they mirror official sources.

## Scope

This policy applies to:
- The main Claude Code session for this project
- All 49 subagents defined under `.claude/agents/`
- All 73 skills defined under `.claude/skills/`
- All `team-*` orchestration flows

When an agent delegates to another agent, the delegated agent inherits this
policy without needing it re-stated in the Task prompt.
