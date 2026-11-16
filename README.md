<div align="center">

# Assistant CLI

**English** | [Português](README-PTBR.md) | [Español](README-ES.md)

  <p>A lightweight, modular, and localized shell wrapper for Antigravity (agy), Codex, Copilot, Ollama, OpenCode, and Custom Adapters, supporting interactive chat, repository analysis, README generation, project summaries, and more.</p>
    <div style="margin-bottom: 10px">
    <img src="https://img.shields.io/badge/Language-Shell-orange.svg"/>
    </div>
    <br>
</div>

# Quick Links

- [Description](#description)
- [Installation & Setup](#installation--setup)
- [Update & Version](#update--version)
- [Features](#features)
- [Usage](#usage)
- [Project Structure](#project-structure)
- [License](#license)

## Description

The **Assistant CLI** (`assistant`) is a powerful, lightweight command-line interface (CLI) wrapper written in Bash. It allows users to interact with local or cloud Large Language Models (LLMs) orchestrated via **Antigravity**, **Codex**, **Copilot**, **Ollama**, **OpenCode**, or **Custom Adapters** (`custom/adapters/`) directly from the terminal.

All configuration choices (such as active engine, saved models per engine, language, and think mode) are saved locally and persist across terminal sessions.

## Installation & Setup

The Assistant CLI provides installation scripts tailored for different operating systems.

### Linux and macOS

You can install Assistant CLI directly using `curl`:

```bash
curl -fsSL https://raw.githubusercontent.com/lpatros/assistant-cli/main/install.sh | bash
```

**On Linux and macOS, the interactive installer will:**
1. Clone the repository to `~/.config/assistant-cli` (or a custom directory of your choice).
2. Automatically add the configuration to your shell profile (`~/.zshrc`, `~/.bashrc`, or `config.fish`).
3. Guide you on how to reload your terminal to start using the assistant.

### Windows

#### PowerShell

For **Windows** users using PowerShell, you can install it by running:

> [!IMPORTANT]
> Make sure your script execution policy is enabled before running the installer. You can set it by running:
> ```powershell
> Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
> ```

```powershell
irm https://raw.githubusercontent.com/lpatros/assistant-cli/main/install.ps1 | iex
```

> [!NOTE]
> Also ensure that Git Bash is added to your system's Environment Variables (usually in `C:\Program Files\Git\bin`).

<details>
<summary> <b>How to add or fix Git Bash in Windows Environment Variables (PATH)</b></summary>

### Step-by-Step:

1. **Verify if it is already configured:**
   - Open **PowerShell** or **Command Prompt (CMD)**.
   - Type `bash --version` or `where bash` and press Enter.
   - If the command returns the Bash version or the executable path, it is already configured! Otherwise, follow the steps below.

2. **Locate the Git Bash installation path:**
   - By default, Git Bash is installed at: `C:\Program Files\Git\bin` (or `C:\Program Files (x86)\Git\bin`).
   - Open Windows File Explorer, navigate to this folder, and make sure the `bash.exe` file is there. Copy the folder path (`C:\Program Files\Git\bin`).

3. **Open Environment Variables:**
   - Press the `Windows` key, type **"environment variables"**, and select the option **"Edit the system environment variables"**.
   - In the window that opens, click the **"Environment Variables..."** button (located in the bottom right corner).

4. **Edit the PATH variable:**
   - Under **"User variables"** (to apply only to your user) or **"System variables"** (to apply to all users), locate the variable named **`Path`** and select it.
   - Click the **"Edit..."** button.

5. **Add the path:**
   - Click the **"New"** button on the right side.
   - Paste the path copied in Step 2 (e.g., `C:\Program Files\Git\bin`).
   - Click **"OK"** in all open windows to save and apply the changes.

6. **Validate the configuration:**
   - **Important:** Close all open PowerShell or CMD windows and open a new terminal to load the new environment variables.
   - Type `bash --version` in the new terminal. If the Bash version is successfully displayed, the setup is complete!
</details>


**On Windows via PowerShell, the interactive installer will:**
1. Clone the repository to `%LOCALAPPDATA%\assistant-cli` (or a custom directory of your choice).
2. Verify if `bash` is available in your system (e.g., Git Bash or WSL) since the core project uses `.sh` scripts.
3. Add a wrapper function directly into your PowerShell profile (`$PROFILE`) that transparently calls `bash`. **This means you don't need to open Git Bash manually; the assistant will work seamlessly right inside your standard PowerShell!**
4. Guide you on how to reload your terminal.

#### Bash (Git Bash / WSL)

If you use **Bash** as your terminal on Windows, you can install Assistant CLI directly using `curl`:

```bash
curl -fsSL https://raw.githubusercontent.com/lpatros/assistant-cli/main/install.sh | bash
```

**On Bash, the interactive installer will:**
1. Clone the repository to the installation directory (`%LOCALAPPDATA%\assistant-cli` or `~/.config/assistant-cli`).
2. Automatically add the configuration to your shell profile (`~/.bashrc`, `~/.zshrc`, or `config.fish`).
3. Guide you on how to reload your terminal to start using the assistant.

## Update & Version

You can check the current version of the assistant with:

```bash
assistant --version
```

You can easily update your Assistant CLI to the latest version or switch to a specific version:

```bash
assistant update                     # Update to the latest version on current channel
assistant update --list              # List available versions (or -l)
assistant update @1.2.0              # Update/switch to version 1.2.0
assistant update --version 1.2.0     # Alternative syntax to set target version
```

You can also switch release channels (between stable and beta):

```bash
assistant channel status  # Show current release channel
assistant channel beta    # Switch to beta channel (dev branch) and update
assistant channel stable  # Switch to stable channel (main branch) and update
```

## Features

### Interactive & Direct Chat
- Run `assistant` to start an interactive chat session with your currently selected model.
- Run `assistant "your prompt here"` to quickly send a single query to the model and receive the output.

### Harnesses and native Codex skills

Inspect capabilities with `assistant adapters capabilities`. `engine` and `harness` are aliases of `adapters`. Native skill installation in Codex supports explicit project/user scopes, previews, verification and removal that preserves local edits. See the [harness and installation guide](docs/harnesses/README.md).

### Modular & Custom Engine Support
- Built-in support for **Antigravity**, **Codex**, **Copilot**, **Ollama**, and **OpenCode**.
- Create your own **Custom Adapters** with an entry point at `custom/adapters/<name>/init.sh`. The directory name identifies the adapter; auxiliary files stay beside its entry point.
- The assistant stores preferred models per engine, meaning you won't lose your selected model configurations when switching between engines.
- Switch between adapters interactively with `assistant adapters select` or directly using `assistant adapters <name>`.

### Built-in Skills (Default Skills)
The assistant comes with several built-in skills to boost your workflow:
- **Commit Assistant (`assistant commit`)**: Analyzes your Git repository's status, staged diffs, and unstaged change statistics, and runs them against standard guidelines to generate clean, readable commit message suggestions.
- **Branch Separation Assistant (`assistant branch`)**: Analyzes your Git repository's status, diffs, and history to split mixed work into separate, purpose-focused branches (e.g. `fix/...`, `test/...`, `feature/...`), each with atomic commits, Conventional Commit messages, and safe Git commands to run manually.
- **Project Resume Generator (`assistant resume [paths...]`)**: Automatically gathers context from your project directory (structural tree and manifest files like `package.json`, `pom.xml`, `Cargo.toml`, etc.) and formats a comprehensive markdown resume outlining project architecture and dependencies.
- **README Generator (`assistant readme --lang [lang] --name [filename]`)**: Automatically analyzes your project structure and configuration files to generate a professional, contextualized README file.

### Custom Skills

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

To migrate an old custom skill, move its instructions to `custom/skills/<name>/SKILL.md` and add the required frontmatter. The old filename is ignored. Start from [SKILL.md.template](docs/templates/skills/SKILL.md.template).

#### Custom Dynamic Shell Commands
You can also define custom Shell functions that execute dynamic logic.

To do this, create or edit `custom/init.sh` and define functions using the `_cmd_<name>` naming convention:

```bash
# custom/init.sh
_cmd_hello() {
  echo "Hello from custom shell function!"
  echo "Arguments received: $*"
}
```

Any function named `_cmd_<name>` defined in `custom/init.sh` is automatically dispatched when running:
```bash
assistant hello "world"
```

#### Custom Locales
You can add your own custom language translation by placing a `.sh` file inside `custom/locales/<lang>.sh` (e.g. `custom/locales/fr.sh`).

In your custom locale file, define translation functions (e.g. `t_lang_changed`, `t_lang_status`). Any function not defined in your custom file automatically falls back to `locales/en.sh`.

```bash
# custom/locales/fr.sh
t_lang_changed() {
  _success "Langue modifiée en: ${BOLD}$1${RESET}"
}
t_lang_status() {
  _info "Langue actuelle: ${CYAN}${BOLD}$1${RESET}"
}
```

Switch to your custom locale or list available locales:
```bash
# Set custom language
assistant lang fr

# List all available languages (built-in and custom)
assistant lang --list
```

#### Complete Customization Guide & Templates

For detailed documentation, function API contracts, and advanced step-by-step examples on creating custom AI engines, locales, skills, and dynamic shell commands, refer to the **[Customization and Extensions Guide (docs/customization/README.md)](docs/customization/README.md)**.

Starter templates are also available inside the [`docs/templates/`](docs/templates)

## Usage

When running `assistant`, you have access to the following commands:

| Command | Description |
| :--- | :--- |
| `assistant` | Starts interactive chat with the current model |
| `assistant "<message>"` | Sends a direct message to the current model |
| `assistant status` | Shows active engine, active models, think mode, and language |
| `assistant commit` | Analyzes git staging and suggests structured commits |
| `assistant branch` | Analyzes git changes and suggests separate, purpose-focused branches |
| `assistant resume [paths...]` | Scans directories and generates project resume markdown files |
| `assistant readme --lang <lang> --name <name>` | Scans project structure and generates a README file |
| `assistant adapters [<name>\|status]` | Select an adapter by name or show its status |
| `assistant adapters --list` | List built-in and custom adapters without prompting |
| `assistant adapters select` | Open the interactive selection menu |
| `assistant custom adapters --list` | List custom adapters only |
| `assistant engine …` / `assistant harness …` | Aliases of `assistant adapters`, with identical behavior |
| `assistant adapters capabilities [name]` | Show adapter capabilities |
| `assistant skills install <name> --harness codex --scope <project\|user> [--project <dir>] [--dry-run]` | Preview or install a native Codex skill |
| `assistant skills verify <name> --harness codex --scope <project\|user> [--project <dir>]` | Validate the managed installation |
| `assistant skills diff <name> --harness codex --scope <project\|user>` | Compare an installation with its recorded source |
| `assistant skills update <name> --harness codex --scope <project\|user> [--dry-run]` | Preview or apply a managed update |
| `assistant skills restore <name> --harness codex --scope <project\|user> [--dry-run]` | Preview or restore the previous managed version |
| `assistant skills <installed\|status> [name] --harness codex [--scope <project\|user\|all>]` | List native installations and diagnose a name |
| `assistant skills remove <name> --harness codex --scope <project\|user> [--project <dir>] [--dry-run]` | Remove an unedited managed installation |
| `assistant skills list` | List skills, origins and conflicts |
| `assistant create skill <name> <path.md>` | Creates a new custom skill from a Markdown template |
| `assistant <custom-skill> [args]` | Executes a custom skill |
| `assistant lang [<lang>\|--list\|status]` | Changes active language, lists available languages, or shows current language |
| `assistant model --list` | Interactively lists available models for the current engine to switch them |
| `assistant model status` | Shows currently configured models for all engines |
| `assistant think [on\|off\|hide\|clear]` | Toggles thinking/reasoning modes on Ollama models |

`--list` (and `list`) prints a noninteractive table, including through the `engine` and `harness` aliases. Use `select` for the interactive menu. The table shows each adapter's origin, executable availability and active state. Selection rejects names that are not discovered. When a custom adapter has the same name as a built-in adapter, the custom adapter takes precedence and appears once.

The same operations are available under `assistant custom adapters`: `--list`, `select`, `status`, `capabilities [name]` and `<name>`. Lists, capabilities and selection are restricted to custom adapters. `status` reports whether the active adapter is custom; selecting here still changes the single global active adapter.

### Examples

```bash
# Ask a general coding question
assistant "How do I implement a debouncer in vanilla JS?"

# Generate git commits from staged changes
assistant commit

# Split mixed changes into separate, purpose-focused branches
assistant branch

# Switch active engine to Antigravity (agy), Codex, Copilot, Ollama, or OpenCode
assistant adapters agy
assistant adapters codex
assistant adapters copilot
assistant adapters ollama
assistant adapters opencode

# List adapters without opening a menu
assistant adapters --list

# Interactively switch adapters
assistant adapters select

# Interactively change model for the current engine
assistant model --list
```

## Project Structure

```
assistant/
├── custom/                  # User custom engines, skills, and locales
│   ├── adapters/            # Custom adapter scripts (.sh)
│   ├── locales/             # Custom locale translations (.sh)
│   └── skills/              # Custom skills (<name>/SKILL.md)
├── data/                    # Persistent configuration store (engine, model, lang)
├── docs/                    # Customization guides and extension templates
│   ├── customization/       # Customization guides (README*.md)
│   ├── harnesses/           # Harness and native skill guides (README*.md)
│   └── templates/           # Starter templates (adapters, locales, skills)
├── lib/                     # Modular engines (lib/adapters/), core routes, utilities
├── locales/                 # Text translations
├── skills/                  # Built-in skills
├── utils/                   # Utility scripts and helpers
├── init.sh                  # Main entry point to source in shell config files
├── LICENSE.txt              # License
└── README.md                # Documentation
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE.txt) file for details.

