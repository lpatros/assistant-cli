# Harnesses and native Codex skills

**English** | [Português](README-PTBR.md) | [Español](README-ES.md)

Assistant CLI coordinates skills and context. An adapter translates its calls into a tool's CLI; an agent harness uses project tools and a model/provider to perform tasks. The Ollama adapter runs text prompts without enabling its experimental tool loop. `assistant harness` is the public command; `assistant engine` remains a compatible alias. Existing `ASSISTANT_ENGINE`, `ASSISTANT_MODEL_*` settings, `custom/adapters/` and `_engine_*` functions remain supported.

Custom adapters are loaded only from `custom/adapters/*/init.sh`; move existing extensions to that directory. The former `custom/engines/` location is no longer scanned. `assistant custom adapters` lists the discovered extensions; `assistant custom engines` remains a command alias. Existing `_engine_*` functions and `ASSISTANT_ENGINE`/`ASSISTANT_MODEL_*` settings remain unchanged.

```bash
assistant harness status
assistant harness capabilities
assistant harness capabilities codex
assistant harness codex
```

Capabilities describe what the Assistant adapter supports, not every feature in the external tool or whether its binary is installed. `unknown` means an older custom adapter has not declared that capability.

| Adapter | Prompt | Interactive | Project tools | Model list | Final response | Native install |
| --- | --- | --- | --- | --- | --- | --- |
| agy | yes | yes | yes | yes | yes | no |
| codex | yes | yes | yes | no | yes | yes |
| copilot | yes | yes | yes | no | yes | no |
| ollama | yes | yes | no | yes | yes | no |
| opencode | yes | yes | yes | yes | yes | no |

Prompt execution returns only final response text on stdout or in the requested file. Diagnostics and progress use stderr. Nonzero executor exit codes are preserved; empty or malformed final results fail. The destination is not truncated when the executor fails. Publication itself is not an atomic filesystem transaction. Custom adapters remain responsible for separating their own logs from response text.

Codex uses `exec --output-last-message`; Copilot uses `-p --silent`; AGY uses print/text mode; Ollama hides reasoning for document generation. OpenCode uses raw JSON events internally and requires `jq` to extract the final assistant step. Missing `jq` fails before inference; no public JSON response mode was added. Existing custom adapters keep their prompt and interactive fallback. Explicit messages use prompt mode, while `assistant` with no message opens the interactive CLI.

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

Installation rejects an existing destination, duplicate declared identities within the destination skills directory and symbolic links in managed paths. It does not merge or overwrite. Removal validates ownership metadata and hashes and refuses edited files, edited metadata, symlinks or additional files. It removes only its three files and their empty skill folder; it does not remove the shared skills directory. A file-operation failure is reported and may require inspecting a partially created target.

`verify` validates metadata, content, ownership and placement at the documented discovery path. It does not prove that a running Codex session has loaded the skill; restart Codex if it does not appear. Conflicts in other scopes, parent-project directories, system skills or a running session are outside the local destination check. [Official skill discovery paths](https://developers.openai.com/codex/skills) and [Codex final output](https://developers.openai.com/codex/noninteractive) were checked for this implementation.

### Test without inference

```bash
bash tests/smoke.sh
bash tests/harness.sh
zsh tests/harness.sh
shellcheck -S error init.sh lib/*.sh lib/adapters/*/init.sh utils/*.sh skills/*/init.sh locales/*.sh install.sh tests/*.sh
```

The harness suite copies the code into a temporary directory, simulates executors and redirects user-scope writes only inside its fixture. It does not change `HOME` or install skills into the real account. Fish validation requires Fish to be installed. Real inference and version-specific compatibility of all external CLIs are not covered by simulated tests.
