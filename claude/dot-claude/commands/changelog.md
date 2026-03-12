Update the project's CHANGELOG.md to comprehensively document changes for a release.

**Arguments**: $ARGUMENTS

Interpret arguments as follows:
- No arguments: auto-detect and document the latest tag
- A git tag or version (e.g., "v0.2.0", "orchestra-v0.2.0"): document that specific tag
- `init`: create or rebuild a CHANGELOG.md from scratch covering all tags

**Process:**

1. **Gather data**
   Run the helper script to collect all relevant git history in one shot:
   - Default/specific tag: `~/.claude/scripts/changelog-gather.sh` or `~/.claude/scripts/changelog-gather.sh --tag <tag>`
   - Init mode: `~/.claude/scripts/changelog-gather.sh --all`

   If the script does not exist, fall back to manual git commands:
   - `git tag --sort=creatordate`
   - `git log <from>..<to> --oneline --no-merges`
   - `git log <from>..<to> --oneline --merges`
   - `git diff --stat <from>..<to>`
   - Read the current CHANGELOG.md

2. **Generate changelog entries**
   Use a haiku subagent (Agent tool with `model: "haiku"`) to process the gathered data. Pass the subagent the full script output along with these instructions:

   Categorize the commits into Keep a Changelog sections:
   - **Added**: new features, new crates/packages, new endpoints, new UI pages
   - **Changed**: modifications to existing behavior, refactors, migrations, dependency changes
   - **Deprecated**: features marked for future removal
   - **Removed**: removed features, deleted crates/modules, dropped support
   - **Fixed**: bug fixes, corrections
   - **Security**: vulnerability patches, security improvements

   Rules for the subagent:
   - Collapse related commits into single coherent entries
   - Focus on user-facing and developer-facing impact, not individual commit noise
   - Omit categories that have no entries
   - Use backticks for crate names, config fields, CLI flags, and code identifiers
   - Avoid commit-message style language; write in terms of what changed
   - Each entry should start with a capital letter and not end with a period unless it contains multiple sentences
   - For breaking changes, prefix the entry with `**Breaking**:` within whichever category the change belongs to
   - Do not add link references at the bottom unless the existing changelog uses them
   - Output ONLY the markdown for the version section(s), no extra commentary

   For init mode, the subagent should generate sections for every tag range.

3. **Apply changes**
   - If CHANGELOG.md does not exist, create it with the Keep a Changelog header and the generated sections.
   - If a version section already exists, compare the subagent's output against existing entries and merge in any missing items.
   - If a version section does not exist, insert it below `[Unreleased]`.
   - Preserve existing formatting conventions in the file.

4. **Validate**
   - Check for duplicate version headers.
   - Verify chronological ordering of versions.
   - Flag and fix any anomalies (e.g., duplicate versions, misordered dates).
