---
name: start
description: "First-time onboarding — asks where you are, then guides you to the right workflow. No assumptions."
argument-hint: "[no arguments]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, AskUserQuestion
model: sonnet
---

# Guided Onboarding

This skill writes one file: `production/review-mode.txt` (review mode config set in Phase 3b).

This skill is the entry point for new users. It does NOT assume you have a game idea, an engine preference, or any prior experience. It asks first, then routes you to the right workflow.

---

## Phase 1: Detect Project State

Before asking anything, silently gather context so you can tailor your guidance. Do NOT show these results unprompted — they inform your recommendations, not the conversation opener.

Check:
- **Engine configured?** Read `.claude/docs/technical-preferences.md`. If the Engine field contains `[TO BE CONFIGURED]`, the engine is not set.
- **Game concept exists?** Check for `design/gdd/game-concept.md`.
- **Source code exists?** Glob for source files in `src/` (`*.gd`, `*.cs`, `*.cpp`, `*.h`, `*.rs`, `*.py`, `*.js`, `*.ts`).
- **Prototypes exist?** Check for subdirectories in `prototypes/`.
- **Design docs exist?** Count markdown files in `design/gdd/`.
- **Production artifacts?** Check for files in `production/sprints/` or `production/milestones/`.

Store these findings internally to validate the user's self-assessment and tailor recommendations.

---

## Phase 2: Ask Where the User Is

This is the first thing the user sees. Use `AskUserQuestion` with these exact options so the user can click rather than type:

- **Prompt**: "欢迎使用 Claude Code Game Studios！在给出任何建议之前，我想先了解你当前的起点。你现在对自己的游戏想法处于什么阶段？"
- **Options**:
  - `A) 还没有想法` — 我完全没有游戏概念。想先探索一下，看看能做什么。
  - `B) 模糊想法` — 我脑海里有一个大致的主题、感觉或类型（比如"跟太空有关的东西"或"一款温馨的农场游戏"），但还没有具体内容。
  - `C) 清晰概念` — 我知道核心想法——类型、基础机制，也许还有一句简介——但还没有整理成文档。
  - `D) 已有工作` — 我已经有设计文档、原型、代码或大量前期规划。我想整理或继续推进这些工作。

Wait for the user's selection. Do not proceed until they respond.

---

## Phase 3: Route Based on Answer

#### If A: No idea yet

The user needs creative exploration before anything else.

1. Acknowledge that starting from zero is completely fine
2. Briefly explain what `/brainstorm` does (guided ideation using professional frameworks — MDA, player psychology, verb-first design). Mention that it has two modes: `/brainstorm open` for fully open exploration, or `/brainstorm [hint]` if they have even a vague theme (e.g., "space", "cozy", "horror").
3. Recommend running `/brainstorm open` as the next step, but invite them to use a hint if something comes to mind
4. Show the recommended path:
   **Concept phase:**
   - `/brainstorm open` — discover your game concept
   - `/setup-engine` — configure the engine (brainstorm will recommend one)
   - `/prototype` — throwaway concept build: validate the core idea is fun before designing (1–3 days)
   - `/art-bible` — define visual identity (uses the Visual Identity Anchor brainstorm produces)
   - `/map-systems` — decompose the concept into systems
   - `/design-system` — author a GDD for each MVP system
   - `/review-all-gdds` — cross-system consistency check
   - `/gate-check` — validate readiness before architecture work
   **Architecture phase:**
   - `/create-architecture` — produce the master architecture blueprint and Required ADR list
   - `/architecture-decision (×N)` — record key technical decisions, following the Required ADR list
   - `/create-control-manifest` — compile decisions into an actionable rules sheet
   - `/architecture-review` — validate architecture coverage
   **Pre-Production phase:**
   - `/ux-design` — author UX specs for key screens (main menu, HUD, core interactions)
   - `/vertical-slice` — production-quality end-to-end build to validate the full game loop
   - `/playtest-report (×1+)` — document each vertical slice playtest session
   - `/create-epics` — map systems to epics
   - `/create-stories` — break epics into implementable stories
   - `/sprint-plan` — plan the first sprint
   **Production phase:** → pick up stories with `/dev-story`

#### If B: Vague idea

1. Ask them to share their vague idea — even a few words is enough
2. Validate the idea as a starting point (don't judge or redirect)
3. Recommend running `/brainstorm [their hint]` to develop it
4. Show the recommended path:
   **Concept phase:**
   - `/brainstorm [hint]` — develop the idea into a full concept
   - `/setup-engine` — configure the engine
   - `/prototype` — throwaway concept build: validate the core idea is fun before designing (1–3 days)
   - `/art-bible` — define visual identity (uses the Visual Identity Anchor brainstorm produces)
   - `/map-systems` — decompose the concept into systems
   - `/design-system` — author a GDD for each MVP system
   - `/review-all-gdds` — cross-system consistency check
   - `/gate-check` — validate readiness before architecture work
   **Architecture phase:**
   - `/create-architecture` — produce the master architecture blueprint and Required ADR list
   - `/architecture-decision (×N)` — record key technical decisions, following the Required ADR list
   - `/create-control-manifest` — compile decisions into an actionable rules sheet
   - `/architecture-review` — validate architecture coverage
   **Pre-Production phase:**
   - `/ux-design` — author UX specs for key screens (main menu, HUD, core interactions)
   - `/vertical-slice` — production-quality end-to-end build to validate the full game loop
   - `/playtest-report (×1+)` — document each vertical slice playtest session
   - `/create-epics` — map systems to epics
   - `/create-stories` — break epics into implementable stories
   - `/sprint-plan` — plan the first sprint
   **Production phase:** → pick up stories with `/dev-story`

#### If C: Clear concept

1. Ask them to describe their concept in one sentence — genre and core mechanic. Use plain text, not AskUserQuestion (it's an open response).
2. Acknowledge the concept, then use `AskUserQuestion` to offer two paths:
   - **Prompt**: "你想如何推进？"
   - **Options**:
     - `先正式整理` — 运行 `/brainstorm [concept]` 把它结构化为正式的游戏概念文档
     - `直接开始` — 现在就去 `/setup-engine`，之后再手动编写 GDD
3. Show the recommended path:
   **Concept phase:**
   - `/brainstorm` or `/setup-engine` — (their pick from step 2)
   - `/prototype` — throwaway concept build: validate the core idea is fun before designing (1–3 days)
   - `/art-bible` — define visual identity (after brainstorm if run, or after concept doc exists)
   - `/design-review` — validate the concept doc
   - `/map-systems` — decompose the concept into individual systems
   - `/design-system` — author a GDD for each MVP system
   - `/review-all-gdds` — cross-system consistency check
   - `/gate-check` — validate readiness before architecture work
   **Architecture phase:**
   - `/create-architecture` — produce the master architecture blueprint and Required ADR list
   - `/architecture-decision (×N)` — record key technical decisions, following the Required ADR list
   - `/create-control-manifest` — compile decisions into an actionable rules sheet
   - `/architecture-review` — validate architecture coverage
   **Pre-Production phase:**
   - `/ux-design` — author UX specs for key screens (main menu, HUD, core interactions)
   - `/vertical-slice` — production-quality end-to-end build to validate the full game loop
   - `/playtest-report (×1+)` — document each vertical slice playtest session
   - `/create-epics` — map systems to epics
   - `/create-stories` — break epics into implementable stories
   - `/sprint-plan` — plan the first sprint
   **Production phase:** → pick up stories with `/dev-story`

#### If D: Existing work

1. Share what you found in Phase 1:
   - "I can see you have [X source files / Y design docs / Z prototypes]..."
   - "Your engine is [configured as X / not yet configured]..."

2. **Sub-case D1 — Early stage** (engine not configured or only a game concept exists):
   - Recommend `/setup-engine` first if engine not configured
   - Then `/project-stage-detect` for a gap inventory

   **Sub-case D2 — GDDs, ADRs, or stories already exist:**
   - Explain: "Having files isn't the same as the template's skills being able to use them. GDDs might be missing required sections. `/adopt` checks this specifically."
   - Recommend:
     1. `/project-stage-detect` — understand what phase and what's missing entirely
     2. `/adopt` — audit whether existing artifacts are in the right internal format

3. Show the recommended path for D2:
   - `/project-stage-detect` — phase detection + existence gaps
   - `/adopt` — format compliance audit + migration plan
   - `/setup-engine` — if engine not configured
   - `/design-system retrofit [path]` — fill missing GDD sections
   - `/architecture-decision retrofit [path]` — add missing ADR sections
   - `/architecture-review` — bootstrap the TR requirement registry
   - `/gate-check` — validate readiness for next phase

---

## Phase 3c: Write Initial Stage File

After confirming the starting path (and before asking about review mode), write the initial stage to `production/stage.txt`. Create the `production/` directory if it does not exist.

Stage mapping:
- **Path A, B, or C (starting from scratch)**: write `Concept`
- **Path D, existing project, engine not configured or only a game concept exists**: write `Concept`
- **Path D, existing project with GDDs but no architecture documents**: write `Systems Design`
- **Path D, existing project with full architecture (ADRs, architecture doc)**: write `Technical Setup`

Do this silently — no "May I write?" needed for this single-line file.

Say: "I've set `production/stage.txt` to `[stage]` — this anchors your status line and stage detection."

---

## Phase 3b: Set Review Mode

Check if `production/review-mode.txt` already exists.

**If it exists**: Read it and show the current mode — "Review mode is set to `[current]`." — then proceed to Phase 4. Do not ask again.

**If it does not exist**: Use `AskUserQuestion`:

- **Prompt**: "一项设置选择：在你走完整个工作流时，希望接受多少设计审核？"
- **Options**:
  - `完整审核` — Director 专家在每个关键工作流步骤都进行审核。适合团队、学习工作流，或希望对每个决策都获得详尽反馈的场景。
  - `精简审核（推荐）` — Director 仅在阶段闸口转换（/gate-check）时介入，跳过单技能审核。适合个人开发者和小团队的平衡方案。
  - `独立模式` — 不进行 Director 审核，最大速度。适合 game jam、原型，或者觉得审核是负担的场景。

Write the choice to `production/review-mode.txt` immediately after the user
selects — no separate "May I write?" needed, as the write is a direct
consequence of the selection:
- `完整审核` → write `full`
- `精简审核（推荐）` → write `lean`
- `独立模式` → write `solo`

Create the `production/` directory if it does not exist.

---

## Phase 4: Confirm Before Proceeding

After presenting the recommended path, use `AskUserQuestion` to ask the user which step they'd like to take first. Never auto-run the next skill.

- **Prompt**: "你想从 [recommended first step] 开始吗？"
- **Options**:
  - `好，从 [recommended first step] 开始`
  - `我想先做别的事`

---

## Phase 5: Hand Off

When the user confirms their next step, respond with a single short line: "Type `[skill command]` to begin." Nothing else. Do not re-explain the skill or add encouragement. The `/start` skill's job is done.

Verdict: **COMPLETE** — user oriented and handed off to next step.

---

## Edge Cases

- **User picks D but project is empty**: Gently redirect — "It looks like the project is a fresh template with no artifacts yet. Would Path A or B be a better fit?"
- **User picks A but project has code**: Mention what you found — "I noticed there's already code in `src/`. Did you mean to pick D (existing work)?"
- **User is returning (engine configured, concept exists)**: Skip onboarding entirely — "It looks like you're already set up! Your engine is [X] and you have a game concept at `design/gdd/game-concept.md`. Review mode: `[read from production/review-mode.txt, or 'lean (default)' if missing]`. Want to pick up where you left off? Try `/sprint-plan` or just tell me what you'd like to work on."
- **User doesn't fit any option**: Let them describe their situation in their own words and adapt.

---

## Collaborative Protocol

1. **Ask first** — never assume the user's state or intent
2. **Present options** — give clear paths, not mandates
3. **User decides** — they pick the direction
4. **No auto-execution** — recommend the next skill, don't run it without asking
5. **Adapt** — if the user's situation doesn't fit a template, listen and adjust
