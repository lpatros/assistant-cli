<div align="center">

# Customization and Extensions Guide

**English** | [Português](README-PTBR.md) | [Español](README-ES.md)

<p>Learn how to extend <b>Assistant CLI</b> by configuring the AI engines you use, custom languages, custom skills, and dynamic custom commands.</p>

</div>

## Table of Contents

- [Overview](#overview)
- [Custom Adapters](#custom-adapters-customadapters)
  - [Adapter Function Contract](#adapter-function-contract)
  - [Step-by-Step Guide](#step-by-step-guide)
  - [Activation and Testing](#activation-and-testing)
- [Custom Locales](#custom-locales-customlocales)
  - [Message Function Structure](#message-function-structure)
  - [Step-by-Step Guide](#step-by-step-guide-1)
  - [Activation and Testing](#activation-and-testing-1)
- [Custom Skills](#custom-skills-customskills)
- [Dynamic Custom Commands](#dynamic-custom-commands-custominitsh)
  - [How It Works](#how-it-works)
  - [Practical Example](#practical-example)
- [Reference Templates](#reference-templates)

## Overview

**Assistant CLI** is designed with a fully modular architecture based on the `custom/` directory. All shell script files or Markdown guidelines placed in the corresponding folders are automatically reloaded and made available without needing to recompile or reinstall the assistant.

The directory structure for extensions is as follows:

```text
custom/
├── adapters/   # Shell scripts providing drivers for new LLM CLIs/services
├── locales/    # Shell scripts overriding or adding interface translations
├── skills/     # Markdown packages (<name>/SKILL.md) defining system personas and prompts
└── init.sh     # Shell script for dynamic custom commands (_cmd_<name>)
```

## Custom Adapters (`custom/adapters/`)

You can integrate any new model, CLI, or API (e.g., Kimi, custom APIs) by creating a driver shell script in the `custom/adapters/` directory.

Custom adapters are loaded only from `custom/adapters/*/init.sh`. `assistant custom adapters --list` lists custom extensions only; `assistant custom engine`, `assistant custom harness` and `assistant custom engines` are aliases. Existing `_engine_*` functions and `ASSISTANT_ENGINE`/`ASSISTANT_MODEL_*` settings remain unchanged.

Only `<name>/init.sh` is discovered and sourced. Keep helpers, filters and assets in the same directory and load them explicitly from the adapter when needed. Flat `.sh` files directly inside `lib/adapters/` or `custom/adapters/` are ignored.

`--list` (and `list`) prints a noninteractive table, including through the `engine` and `harness` aliases. Use `select` for the interactive menu. The table shows each adapter's origin, executable availability and active state. Selection rejects names that are not discovered. When a custom adapter has the same name as a built-in adapter, the custom adapter takes precedence and appears once.

The same operations are available under `assistant custom adapters`: `--list`, `select`, `status`, `capabilities [name]` and `<name>`. Lists, capabilities and selection are restricted to custom adapters. `status` reports whether the active adapter is custom; selecting here still changes the single global active adapter.

### Adapter Function Contract

For `assistant-cli` to recognize and manage your engine, your `.sh` file must implement functions prefixed with `_engine_<engine_name>_`:

| Function | Description | Required? |
| :--- | :--- | :---: |
| `_engine_<name>_binary()` | Returns the CLI executable name in the system. | **Yes** |
| `_engine_<name>_is_installed()` | Returns status code `0` (success) if the tool is installed. | **Yes** |
| `_engine_<name>_list_models()` | Prints the list of supported models (one per line). | *No* |
| `_engine_<name>_run_prompt()` | Executes a batch prompt (single response). | **Yes** |
| `_engine_<name>_run_interactive()` | Starts an interactive chat session with the model. | **Yes** |
| `_engine_<name>_default_model()` | Returns the default model for the engine (optional). | *No* |

### Optional adapter capabilities

The `_engine_<name>_capabilities()` hook prints one supported token per line: `prompt`, `interactive`, `workspace_tools`, `model_list`, `final_output`, `native_skills`. This is a complete declaration: omitted tokens mean unsupported. Without the hook, legacy prompt/interactive execution remains enabled, native installation is disabled and other capabilities are unknown.

Prompt hooks must emit only the final text, keep diagnostics on stderr and return the executor exit code. `_harness_capture_text <name> <output_file> <command> [args...]` buffers text from a CLI mode that already emits only the final response; it cannot remove logs from an arbitrary stream. It rejects empty results and publishes only after successful execution. Native-install adapters additionally implement `_engine_<name>_skill_root <scope> <project>` (absolute discovery path) and `_engine_<name>_render_skill <name> <source_file>` (valid rendered SKILL.md on stdout). Only the Codex adapter ships native installation in this release.

The optional `_engine_<name>_skill_roots <working-directory>` hook prints `project`, `ancestor` or `user`, a tab, and an absolute discovery directory per line. It supplies native inventory and cross-scope duplicate warnings; it does not change installation destinations. Adapters without this hook use only project/user roots. Recorded source paths remain pinned during updates; renderers must not silently switch sources.

### Step-by-Step Guide

1. Create `custom/adapters/<name>/init.sh`; the directory name is the adapter identifier.
2. Use the official template at [`docs/templates/adapters/init.sh.template`](../templates/adapters/init.sh.template) as a starting point.
3. Replace `<name>` with your engine identifier (use lowercase letters, numbers, and underscores only).
4. Implement each function according to your target CLI syntax.

### Activation and Testing

After saving your file in `custom/adapters/my_engine/init.sh`:

1. Check if the engine appears in the list of available engines:
   ```bash
   assistant adapters --list
   assistant custom adapters --list
   ```
2. Switch to the new engine:
   ```bash
   assistant adapters my_engine
   ```
3. Set a model for the engine if needed:
   ```bash
   assistant model model-a
   ```

## Custom Locales (`custom/locales/`)

You can translate the assistant interface into new languages or customize existing messages by creating shell files in the `custom/locales/` directory.

### Message Function Structure

Locale files override translation functions prefixed with `t_` used by the assistant rendering system.

| Function | Description |
| :--- | :--- |
| `t_lang_changed()` | Message displayed when changing the active language. |
| `t_lang_status()` | Displays status and current active language. |
| `t_lang_not_found()` | Error message when a language does not exist. |
| `t_engine_changed()` | Message displayed when switching active engine. |
| `t_engine_status()` | Displays engine status and active model. |
| `t_model_changed()` | Message displayed when changing model. |
| `t_think_enabled()` | Message when enabling reasoning/think mode. |
| `t_think_disabled()` | Message when disabling reasoning/think mode. |

### Step-by-Step Guide

1. Create a `.sh` file in `custom/locales/`.
2. For reference, check the official template at [`docs/templates/locales/example.sh.template`](../templates/locales/example.sh.template).
3. Define only the `t_*` functions you wish to translate or customize.

### Activation and Testing

1. List registered languages:
   ```bash
   assistant lang --list
   ```
2. Switch to your custom language:
   ```bash
   assistant lang fr
   ```

## Custom Skills (`custom/skills/`)

Skills use `skills/<name>/SKILL.md` (built-in) or `custom/skills/<name>/SKILL.md` (custom). Only this format is discovered; legacy `*-assistant.md` files are unsupported.

```markdown
---
name: translator
description: Translate text while preserving technical context.
---
Translate the user input into the requested language.
```

`name` and `description` are required. The name must match the folder and use lowercase letters, digits, underscores or hyphens, beginning with a letter or digit. Frontmatter supports only these two single-line scalar fields, optionally enclosed in matching quotes. Escapes, multiline values, inline comments and other YAML constructs are unsupported. Quote descriptions containing a colon followed by a space. Metadata is read as data and excluded from the model prompt.

```bash
assistant skills list
assistant create skill translator /path/to/SKILL.md
assistant translator "Translate this text into Spanish"
```

The import validates metadata and copies the file to `custom/skills/translator/SKILL.md`. An existing destination or duplicate identity is rejected. Importing instructions for a built-in skill asks for confirmation. Custom instructions take precedence while preserving the built-in handler, context collection, arguments and output behavior.

Discovery reads only immediate `<name>/SKILL.md` files and never executes package scripts. New Markdown-only skills require no changes to `init.sh`. The existing built-in context handlers remain trusted bootstrap code; custom package `init.sh` and `scripts/` are not executed. Custom dynamic commands in `custom/init.sh` remain a separate, trusted extension mechanism.

`assistant skills list` shows name, origin, format, state, path and description, including overridden definitions and invalid entries. Invalid metadata, mismatched folder names and duplicate names within an origin block the affected skill and cause listing to return nonzero. An invalid custom override never silently falls back to the built-in definition. Duplicate declared names are reported even when placed in different folders. Unrelated valid skills remain usable.

Administrative commands and aliases are reserved: `create`, `skills`, `model`, `adapters`, `engine`, `harness`, `think`, `lang`, `custom`, `status`, `update`, `channel`, `changelog`, `version`, `--version`, `-v`, `help`, `--help`, `-h`, `--think`, `--no-think`, `--hide-think`. Skills cannot intercept them. Resolution order is administrative commands, validated skills (custom instructions before built-in), dynamic custom commands, then direct prompts.

To migrate an old custom skill, move its instructions to `custom/skills/<name>/SKILL.md` and add the required frontmatter. The old filename is ignored. Start from [SKILL.md.template](../templates/skills/SKILL.md.template).

## Dynamic Custom Commands (`custom/init.sh`)

You can create custom Bash commands executed directly by the CLI by defining functions prefixed with `_cmd_<name>` inside `custom/init.sh`.

### How It Works

When you run `assistant <name> [arguments...]`, Assistant CLI checks if a matching function named `_cmd_<name>` loaded from `custom/init.sh` exists. If it exists, it is automatically invoked, passing all provided arguments.

### Practical Example

Edit or add to `custom/init.sh`:

```bash
# custom/init.sh

_cmd_hello() {
  echo "👋 Hello! This is a dynamic custom function loaded from custom/init.sh."
  if [[ -n "$1" ]]; then
    echo "Received arguments: $*"
  fi
}
```

To run your custom command:

```bash
assistant hello "world"
```

---

## Reference Templates

The repository includes templates to jumpstart extension development in `docs/templates/`:

| Category | Template Path | Description |
| :--- | :--- | :--- |
| **Engine** | [`docs/templates/adapters/init.sh.template`](../templates/adapters/init.sh.template) | Starter template for custom engine drivers |
| **Locale** | [`docs/templates/locales/example.sh.template`](../templates/locales/example.sh.template) | Starter template for custom locale files |
| **Skill** | [`docs/templates/skills/SKILL.md.template`](../templates/skills/SKILL.md.template) | Starter template for custom skill markdown files |

## Harnesses and native Codex skills

[Harnesses and native Codex skills](../harnesses/README.md).
