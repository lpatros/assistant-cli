<div align="center">

# Customization and Extensions Guide

**English** | [Português](CUSTOMIZATION-PTBR.md) | [Español](CUSTOMIZATION-ES.md)

<p>Learn how to extend <b>Assistant CLI</b> by configuring the AI engines you use, custom languages, custom skills, and dynamic custom commands.</p>

</div>

## Table of Contents

- [Overview](#overview)
- [Custom Engines](#custom-engines-customengines)
  - [Engine Function Contract](#engine-function-contract)
  - [Step-by-Step Guide](#step-by-step-guide)
  - [Activation and Testing](#activation-and-testing)
- [Custom Locales](#custom-locales-customlocales)
  - [Message Function Structure](#message-function-structure)
  - [Step-by-Step Guide](#step-by-step-guide-1)
  - [Activation and Testing](#activation-and-testing-1)
- [Custom Skills](#custom-skills-customskills)
  - [Naming Convention](#naming-convention)
  - [Method 1: Manual Creation](#method-1-manual-creation)
  - [Method 2: CLI Creation](#method-2-cli-creation)
  - [Using a Skill](#using-a-skill)
- [Dynamic Custom Commands](#dynamic-custom-commands-custominitsh)
  - [How It Works](#how-it-works)
  - [Practical Example](#practical-example)
- [Reference Templates](#reference-templates)

## Overview

**Assistant CLI** is designed with a fully modular architecture based on the `custom/` directory. All shell script files or Markdown guidelines placed in the corresponding folders are automatically reloaded and made available without needing to recompile or reinstall the assistant.

The directory structure for extensions is as follows:

```text
custom/
├── engines/     # Shell scripts providing drivers for new LLM CLIs/services
├── locales/     # Shell scripts overriding or adding interface translations
├── skills/      # Markdown files (*-assistant.md) defining system personas and prompts
└── init.sh      # Shell script for dynamic custom commands (_cmd_<name>)
```

## Custom Engines (`custom/engines/`)

You can integrate any new model, CLI, or API (e.g., Kimi, custom APIs) by creating a driver shell script in the `custom/engines/` directory.

### Engine Function Contract

For `assistant-cli` to recognize and manage your engine, your `.sh` file must implement functions prefixed with `_engine_<engine_name>_`:

| Function | Description | Required? |
| :--- | :--- | :---: |
| `_engine_<name>_binary()` | Returns the CLI executable name in the system. | **Yes** |
| `_engine_<name>_is_installed()` | Returns status code `0` (success) if the tool is installed. | **Yes** |
| `_engine_<name>_list_models()` | Prints the list of supported models (one per line). | *No* |
| `_engine_<name>_run_prompt()` | Executes a batch prompt (single response). | **Yes** |
| `_engine_<name>_run_interactive()` | Starts an interactive chat session with the model. | **Yes** |
| `_engine_<name>_default_model()` | Returns the default model for the engine (optional). | *No* |

### Step-by-Step Guide

1. Create a `.sh` file in `custom/engines/`.
2. Use the official template at [`docs/templates/engine/example.sh.template`](templates/engine/example.sh.template) as a starting point.
3. Replace `<name>` with your engine identifier (use lowercase letters, numbers, and underscores only).
4. Implement each function according to your target CLI syntax.

### Activation and Testing

After saving your file in `custom/engines/my_engine.sh`:

1. Check if the engine appears in the list of available engines:
   ```bash
   assistant engine --list
   ```
2. Switch to the new engine:
   ```bash
   assistant engine my_engine
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
2. For reference, check the official template at [`docs/templates/locales/example.sh.template`](templates/locales/example.sh.template).
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

Skills are Markdown guidelines defining specific behaviors, personas, or pre-formatted instructions for the assistant to execute automated tasks.

### Naming Convention

Skill files in the `custom/skills/` directory must strictly follow the naming pattern:
```text
<skill_name>-assistant.md
```

For example: `translator-assistant.md`, `reviewer-assistant.md`, or `test-assistant.md`.

---

### Method 1: Manual Creation

1. Create a `.md` file in `custom/skills/` following the naming convention:
   ```bash
   touch custom/skills/my_translator-assistant.md
   ```
2. Write system instructions inside the file. You can start from the template at [`docs/templates/skills/example-assistant.md.template`](templates/skills/example-assistant.md.template).

---

### Method 2: CLI Creation

You can import a Markdown file from any directory in your system using `assistant create skill`:

```bash
assistant create skill translator /path/to/my_file.md
```

The assistant will automatically copy the file to `custom/skills/translator-assistant.md`.

---

### Using a Skill

Once saved in `custom/skills/`, you can invoke the skill directly by passing its name as a subcommand:

```bash
assistant translator "Translate this sentence into Spanish and preserve technical context"
```

---

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
| **Engine** | [`docs/templates/engine/example.sh.template`](templates/engine/example.sh.template) | Starter template for custom engine drivers |
| **Locale** | [`docs/templates/locales/example.sh.template`](templates/locales/example.sh.template) | Starter template for custom locale files |
| **Skill** | [`docs/templates/skills/example-assistant.md.template`](templates/skills/example-assistant.md.template) | Starter template for custom skill markdown files |
