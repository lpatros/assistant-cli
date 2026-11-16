# Harnesses and native Codex skills

**English** | [Português](README-PTBR.md) | [Español](README-ES.md)

Assistant CLI coordinates skills and context. An adapter translates its calls into a tool's CLI; an agent harness uses project tools and a model/provider to perform tasks. The Ollama adapter runs text prompts without enabling its experimental tool loop. `assistant adapters` is the main command; `assistant engine` and `assistant harness` are compatible aliases. Existing `ASSISTANT_ENGINE`, `ASSISTANT_MODEL_*` settings, `custom/adapters/` and `_engine_*` functions remain supported.

Custom adapters are loaded only from `custom/adapters/*/init.sh`. `assistant custom adapters --list` lists custom extensions only; `assistant custom engine`, `assistant custom harness` and `assistant custom engines` are aliases. Existing `_engine_*` functions and `ASSISTANT_ENGINE`/`ASSISTANT_MODEL_*` settings remain unchanged.

```bash
assistant adapters --list
assistant adapters select
assistant adapters status
assistant adapters capabilities
assistant adapters capabilities codex
assistant adapters codex
assistant custom adapters --list
```

`--list` (and `list`) prints a noninteractive table, including through the `engine` and `harness` aliases. Use `select` for the interactive menu. The table shows each adapter's origin, executable availability and active state. Selection rejects names that are not discovered. When a custom adapter has the same name as a built-in adapter, the custom adapter takes precedence and appears once.

The same operations are available under `assistant custom adapters`: `--list`, `select`, `status`, `capabilities [name]` and `<name>`. Lists, capabilities and selection are restricted to custom adapters. `status` reports whether the active adapter is custom; selecting here still changes the single global active adapter.

Capabilities describe what the Assistant adapter supports, not every feature in the external tool or whether its binary is installed. `unknown` means a custom adapter does not declare that capability.

| Adapter | Prompt | Interactive | Project tools | Model list | Final response | Native install |
| --- | --- | --- | --- | --- | --- | --- |
| agy | yes | yes | yes | yes | yes | no |
| codex | yes | yes | yes | no | yes | yes |
| copilot | yes | yes | yes | no | yes | no |
| ollama | yes | yes | no | yes | yes | no |
| opencode | yes | yes | yes | yes | yes | no |

Prompt execution returns only final response text on stdout or in the requested file. Diagnostics and progress use stderr. Nonzero executor exit codes are preserved; empty or malformed final results fail. The destination is not truncated when the executor fails. Publication itself is not an atomic filesystem transaction. Custom adapters remain responsible for separating their own logs from response text.

Codex uses `exec --output-last-message`; Copilot uses `-p --silent`; AGY uses print/text mode; Ollama hides reasoning for document generation. OpenCode uses raw JSON events internally and requires `jq` to extract the final assistant step. Missing `jq` fails before inference; the public response is text. Existing custom adapters keep their prompt and interactive fallback. Explicit messages use prompt mode, while `assistant` with no message opens the interactive CLI.

The OpenCode response filter lives next to its adapter at `lib/adapters/opencode/result.jq`.

### Install in Codex

Choose both the target and scope explicitly. The native installation workflow does not invoke Codex or make model calls:

```bash
assistant skills install commit --harness codex --scope project --dry-run
assistant skills install commit --harness codex --scope project
assistant skills verify commit --harness codex --scope project
assistant skills remove commit --harness codex --scope project --dry-run
assistant skills remove commit --harness codex --scope project

assistant skills install readme --harness codex --scope user --dry-run
assistant skills install readme --harness codex --scope user
```

Project scope writes `<project>/.agents/skills/<name>/`. The project defaults to the Git root, or the current directory outside Git; `--project <existing-directory>` selects another project. User scope writes `~/.agents/skills/<name>/` and cannot be combined with `--project`. `CODEX_HOME` does not redirect that documented user-skill location. Dry runs may use temporary files but never change the destination.

The effective `SKILL.md` is exported unchanged. Built-in instructions are self-contained: they reuse supplied evidence and collect missing Git/project context when the harness has tools. README and summary skills distinguish raw responses captured by a caller from direct file creation. No supplemental context file, Assistant handler or package script is installed or executed. Custom overrides are also exported unchanged and must provide their own complete instructions; local Assistant handlers still collect context for overrides. Arbitrary package assets and relative references are not copied in this pilot.

Each installation contains `SKILL.md`, `.assistant-install.tsv` and `.assistant-install.sha256`. Provenance records the source path, its Git revision when tracked (or `unversioned`), the source SHA-256, rendered SHA-256 and renderer version. A modified tracked source is marked `:modified`. SHA-256 uses `sha256sum` or `shasum`; if neither exists the operation fails clearly. Provenance is read as data, never sourced as shell code.

Installation rejects an existing destination, duplicate declared identities within the destination skills directory and symbolic links in managed paths. It does not merge or overwrite. Removal validates ownership metadata and hashes and refuses edited files, edited metadata, symlinks or additional files. It removes only the three owned files and empty directory of each managed installation or backup, preserving the shared skills directory. A file-operation failure is reported and may require inspecting a partially created target.

`verify` validates metadata, content, ownership and placement at the documented discovery path. It does not prove that a running Codex session has loaded the skill; restart Codex if it does not appear. See [official skill discovery paths](https://learn.chatgpt.com/docs/build-skills#where-codex-loads-local-skills) and [Codex final output](https://developers.openai.com/codex/noninteractive).

### Managed updates and diagnostics

```bash
assistant skills installed --harness codex
assistant skills status commit --harness codex
assistant skills diff commit --harness codex --scope project
assistant skills update commit --harness codex --scope project --dry-run
assistant skills update commit --harness codex --scope project
assistant skills restore commit --harness codex --scope project --dry-run
assistant skills restore commit --harness codex --scope project
```

Native management compares source contents rather than requiring a version field in SKILL.md. The recorded Git revision identifies the source snapshot; a different repository revision alone does not mean a skill `update` is available. Commands do not invoke Codex or perform inference.

Use `installed` to list native packages and `status` to inspect a specific name. These commands show source, installed revision, local changes, available updates, backup state and destination. A named `status` also compares installed/current source revisions and SHA-256 values. They require `--harness codex`; `--scope` defaults to all and also accepts project or user. `assistant skills list` continues to list the Assistant source registry.

Tables abbreviate paths in the middle and display Git revisions with 12 characters, retaining the modification suffix. Below 160 terminal columns, summary and paths use separate tables. Named `status` output keeps full paths, revisions and hashes in its details.

`update` follows the absolute source path recorded during installation. A newer effective custom override produces a warning and does not switch that origin. If the recorded source is missing, invalid, linked or changes while rendering, `update` fails without replacing the installation. A content change marks an `update` as available. `diff` and `update --dry-run` show a unified `diff`; a real `update` also prints the `diff`. `diff` permits inspection of locally edited instructions when their provenance is valid. Read-only commands do not accept `--dry-run`.

`update` refuses locally edited content, edited records, extra files, symlinks, unsupported records and duplicates within the same skill directory. It displays the content `diff` before reporting local edits. There is no force replacement or automatic merge. Dry runs do not change the destination or backup. All mutating commands require an explicit project or user scope.

Each successful `update` retains one previous managed installation, including its original provenance, in `.agents/.assistant-skill-backups/codex/<name>/` beside the skills directory. Backups are not native skills and are not scanned as installations. A later `update` replaces this slot only when the existing backup validates. `restore` exchanges the current installation with this previous version, so one slot can also undo a restoration. It does not need the original source. Edited current installations or backups block restoration. `remove` deletes a valid owned backup along with the installation; edited backups are preserved and block removal.

Discovery inspects the selected working directory, its ancestors up to the Git repository root, and the user skill directory. Outside Git, only the selected directory and user directory are inspected. `--project` selects the discovery starting directory for `installed/status`. Duplicates between user/project/ancestor directories produce warnings and do not block changes. Two folders declaring the same name inside one skill directory block installation, `update`, `restore` and `verify`; inventory lists both and returns nonzero. Unmanaged and damaged packages remain visible. Diagnostics do not cover administrator/system bundles, runtime activation or disabled-skill settings.

Writes use a per-skill lock under `.agents/.assistant-skill-locks/`. A competing operation fails clearly. Replacement stages and validates files on the same filesystem, then moves directories with rollback on a detected move failure. It is not an atomic transaction across the installation and backup. An interruption can leave a lock or a `.assistant-skill-transaction.*` directory; inspect these paths before manual recovery. If automatic rollback fails, the recovery path is reported and preserved.

### Test without inference

```bash
bash tests/smoke.sh
bash tests/harness.sh
zsh tests/harness.sh
bash tests/skill-update.sh
zsh tests/skill-update.sh
shellcheck -S error init.sh lib/*.sh lib/adapters/*/init.sh utils/*.sh skills/*/init.sh locales/*.sh install.sh tests/*.sh
```

The harness suite copies the code into a temporary directory, simulates executors and redirects user-scope writes only inside its fixture. It does not change `HOME` or install skills into the real account. Fish validation requires Fish to be installed. Real inference and version-specific compatibility of all external CLIs are not covered by simulated tests.
