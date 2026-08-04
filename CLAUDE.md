# Claude Code Game Studios -- Game Studio Agent Architecture

Indie game development managed through 49 coordinated Claude Code subagents.
Each agent owns a specific domain, enforcing separation of concerns and quality.

## Technology Stack

- **Engine**: [CHOOSE: Godot 4 / Unity / Unreal Engine 5]
- **Language**: [CHOOSE: GDScript / C# / C++ / Blueprint]
- **Version Control**: Git with trunk-based development
- **Build System**: [SPECIFY after choosing engine]
- **Asset Pipeline**: [SPECIFY after choosing engine]

> **Note**: Engine-specialist agents exist for Godot, Unity, and Unreal with
> dedicated sub-specialists. Use the set matching your engine.

## Project Structure

@.claude/docs/directory-structure.md

## Engine Version Reference

@docs/engine-reference/godot/VERSION.md

## Technical Preferences

@.claude/docs/technical-preferences.md

## Coordination Rules

@.claude/docs/coordination-rules.md

## Collaboration Protocol

**User-driven collaboration, not autonomous execution.**
Every task follows: **Question -> Options -> Decision -> Draft -> Approval**

- Agents MUST ask "May I write this to [filepath]?" before using Write/Edit tools
- Agents MUST show drafts or summaries before requesting approval
- Multi-file changes require explicit approval for the full changeset

See `docs/COLLABORATIVE-DESIGN-PRINCIPLE.md` for full protocol and examples.

### Version Control — self-managed

**Commit and push autonomously. Do not ask for permission to commit or to push.**
This is a deliberate exception to the approval protocol above: file *content* still
requires approval before it is written, but once content is approved, getting it
into git is your job, not the user's.

- Commit at each natural checkpoint — a section written to file, a story closed, a
  gate passed, a self-contained fix. Do not batch a whole session into one commit.
- Group commits by intent, not by file. One coherent change per commit, even when
  it spans several files.
- Push after each commit unless work is mid-sequence and the intermediate state
  would not build or read coherently; then push once the sequence completes.
- Never commit directly to the default branch. Branch first, then commit.
- Never use `--force` or `--force-with-lease` on a shared branch, never rewrite
  pushed history, and never commit secrets or generated build output.
- If a commit would include unrelated pre-existing changes, say so and split it.

Report what you committed and pushed in your reply — the user should always be able
to see what landed without checking `git log`.

> **First session?** If the project has no engine configured and no game concept,
> run `/start` to begin the guided onboarding flow.

## Coding Standards

@.claude/docs/coding-standards.md

## Context Management

@.claude/docs/context-management.md
