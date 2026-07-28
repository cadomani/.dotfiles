# Global Development Standards

Written to `~/.claude/CLAUDE.md` by home-manager, so it applies to every project on this
machine. Repository-specific instructions belong in that repository's own `CLAUDE.md`, which
Claude Code picks up on its own and which wins where the two disagree.

## Commits

All commit messages follow the [Conventional Commits](https://www.conventionalcommits.org/)
specification.

- Format: `type(scope): description`. Scope is optional but encouraged when it aids clarity.
- Types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `style`, `perf`, `ci`, `build`
- Imperative mood ("add feature", not "adds feature"). Subject under 72 characters.
- Breaking changes: append `!` after the type or scope, or add a `BREAKING CHANGE:` footer.
- Body and footer are optional. Use them only when the why is not obvious from the subject.

## Punctuation in written output

Applies to documentation, code comments, and commit messages:

- Em dashes are forbidden. Rewrite the sentence.
- Dashes used as clause separators or connectors are forbidden. Rewrite the sentence.
- Dashes are permitted only for hyphenation (`well-known`, `type-safe`), markdown bullet
  items, command-line flags (`--flag`, `-v`), numeric or version ranges (`1-10`), and
  markdown horizontal rules.

When the impulse to reach for a dash arises, restructure the sentence instead.

## Code quality defaults

- Prefer editing existing files over creating new ones.
- Write no comments by default. Add one only when the *why* is not obvious: a hidden
  constraint, a workaround for a specific bug, a subtle invariant. Never describe what the
  code does.
- Avoid over-engineering. Three similar lines beats a premature abstraction. Do not design
  for hypothetical future requirements.
- Do not add error handling, fallbacks, or validation for scenarios that cannot happen. Only
  validate at true system boundaries: user input, external APIs, IPC.
- Keep changes small and focused. A change that can be split without losing coherence should
  be split.
- When the same multi-step command sequence recurs, propose a script or a Makefile target.
  Skip this when the repetition is incidental to routine feature work.

## Working style

- Give one step at a time and wait for its output before the next. Do not deliver ten steps
  at once.
- Explain what a command does and why each option is there, not just what to type.
- Write every shell command on a single line. Backslash line continuations break when
  pasted.
- Verify fast-moving things against upstream sources rather than recalling them. Module
  option names in particular get renamed, and stale guides outnumber current ones.
- Never report a check as passing without having run it.
- Before anything destructive, explain the failure mode and ask for an explicit go-ahead.
