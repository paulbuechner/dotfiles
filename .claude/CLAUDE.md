## Core Principles

- Never use emojis.

## When to Commit

Never commit on your own initiative. Make the changes, report what changed, and leave the commit to me.

Commit when I ask. If a commit seems warranted and I have not said so — a batch of work is finished, or a risky step is coming that deserves a checkpoint — ask first rather than deciding. The same goes for history rewrites and pushes.

## Commit Authorship

When committing code changes:
- Never add Claude as a commit author.
- Always commit as using the default git settings

## Commit Format

Work repositories, which have an issue tracker:

```
[<ticket>|#noissue] <type>[(<scope>)]: <description>
```

Personal repositories — no ticket field at all, start with the type:

```
<type>[(<scope>)]: <description>
```

- **Ticket prefix** — work repos only. Use the issue key when the change belongs to a ticket, otherwise `#noissue`. Never use either in a personal repo, unless requested.
- **Type** — `feat`, `fix`, `chore`, `refactor`, `test`, `build`, `ci`, `docs`.
- **Scope** — optional, in parentheses; names the project or subsystem.
- **Description** — short imperative phrase, lowercase, no trailing period.

Examples:
```
feat(bash): add Git Bash config as os.Msys alternate
fix(cache): invalidate entries on config reload
chore(deps): update build scripts
#noissue refactor(parser): split tokenizer out of the reader
PROJ-14 feat(api): accept multi-segment curves
```

## Documentation Style

When creating or updating markdown documentation files:
- **Never create .md files unless explicitly instructed.**
- **Be extremely concise** - engineers scan, they don't read novels
- **Only include essential information** - what they need to know, not what's possible to explain
- **Prefer examples over prose** - show the pattern, not the theory
- **Assume technical competence** - skip obvious explanations
- **Front-load critical info** - put warnings and key concepts first
- **Delete verbose explanations** - if it takes more than 3 sentences, it's probably too long

Default to 1-2 sentence explanations. Only expand when complexity absolutely requires it.