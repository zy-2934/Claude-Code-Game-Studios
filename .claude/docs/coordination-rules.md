# Agent Coordination Rules

1. **Vertical Delegation**: Leadership agents delegate to department leads, who
   delegate to specialists. Never skip a tier for complex decisions.
2. **Horizontal Consultation**: Agents at the same tier may consult each other
   but must not make binding decisions outside their domain.
3. **Conflict Resolution**: When two agents disagree, escalate to the shared
   parent. If no shared parent, escalate to `creative-director` for design
   conflicts or `technical-director` for technical conflicts.
4. **Change Propagation**: When a design change affects multiple domains, the
   `producer` agent coordinates the propagation.
5. **No Unilateral Cross-Domain Changes**: An agent must never modify files
   outside its designated directories without explicit delegation.

## Model Tier Assignment

This fork runs a **quality-first tier policy**: Opus is the default for skills and
agents, with a higher tier reserved for the heaviest synthesis work. This is a
deliberate divergence from upstream, which defaulted to Sonnet and used Haiku for
read-only skills. Do not "restore" the upstream tiers — the trade is accepted:
higher per-call latency and cost in exchange for better judgement everywhere.

| Tier | When it is used here |
|------|----------------------|
| **Fable** | The three highest-stakes synthesis skills and the three Tier-1 directors |
| **Opus** | Default for everything else — authoring, implementation, review, orchestration |
| **Sonnet** | A small set of read-only report/formatting skills where output is mechanical |
| **Haiku** | Not used |

### Current assignment

**Skills (73 total):** 63 `opus`, 7 `sonnet`, 3 `fable`.

- `model: fable` — `/architecture-review`, `/gate-check`, `/review-all-gdds`
- `model: sonnet` — `/changelog`, `/help`, `/onboard`, `/patch-notes`,
  `/project-stage-detect`, `/scope-check`, `/sprint-status`
- everything else — `model: opus`

**Agents (49 total):** 44 `opus`, 3 `fable`, 2 `sonnet`.

- `model: fable` — `creative-director`, `producer`, `technical-director`
- `model: sonnet` — `community-manager`, `devops-engineer`
- everything else — `model: opus`

### When creating a new skill or agent

Set `model: opus` unless it is a pure read-and-format report, in which case use
`model: sonnet`. Reserve `fable` for cross-document synthesis with a binding
verdict. Never leave `model:` unset — every file in this repo sets it explicitly,
and an unset value silently inherits the session model instead.

## Subagents vs Agent Teams

This project uses two distinct multi-agent patterns:

### Subagents (current, always active)
Spawned via `Task` within a single Claude Code session. Used by all `team-*` skills
and orchestration skills. Subagents share the session's permission context, run
sequentially or in parallel within the session, and return results to the parent.

**When to spawn in parallel**: If two subagents' inputs are independent (neither
needs the other's output to begin), spawn both Task calls simultaneously rather
than waiting. Example: `/review-all-gdds` Phase 1 (consistency) and Phase 2
(design theory) are independent — spawn both at the same time.

### Agent Teams (experimental — opt-in)
Multiple independent Claude Code *sessions* running simultaneously, coordinated
via a shared task list. Each session has its own context window and token budget.
Requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` environment variable.

**Use agent teams when**:
- Work spans multiple subsystems that will not touch the same files
- Each workstream would take >30 minutes and benefits from true parallelism
- A senior agent (technical-director, producer) needs to coordinate 3+ specialist
  sessions working on different epics simultaneously

**Do not use agent teams when**:
- One session's output is required as input for another (use sequential subagents)
- The task fits in a single session's context (use subagents instead)
- Cost is a concern — each team member burns tokens independently

**Current status**: Opt-in via `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`. Document first usage here when adopted.

## Parallel Task Protocol

When an orchestration skill spawns multiple independent agents:

1. Issue all independent Task calls before waiting for any result
2. Collect all results before proceeding to dependent phases
3. If any agent is BLOCKED, surface it immediately — do not silently skip
4. Always produce a partial report if some agents complete and others block
