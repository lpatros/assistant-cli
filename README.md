<div align="center">

# Assistant CLI

**English** | [Português](README-PTBR.md) | [Español](README-ES.md)

  <p>A lightweight, modular, and localized shell wrapper for Ollama, OpenCode, Antigravity (agy), and Custom Engines, supporting interactive chat, repository analysis, README generation, project summaries, and more.</p>
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

The **Assistant CLI** (`assistant`) is a powerful, lightweight command-line interface (CLI) wrapper written in Bash. It allows users to interact with local or cloud Large Language Models (LLMs) orchestrated via **Ollama**, **OpenCode**, **Antigravity**, or **Custom Engines** (`custom/engines/`) directly from the terminal.

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

For **Windows** users, you can install it using PowerShell. Open your PowerShell and run:

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


**On Windows, the interactive installer will:**
1. Clone the repository to `%LOCALAPPDATA%\assistant-cli` (or a custom directory of your choice).
2. Verify if `bash` is available in your system (e.g., Git Bash or WSL) since the core project uses `.sh` scripts.
3. Add a wrapper function directly into your PowerShell profile (`$PROFILE`) that transparently calls `bash`. **This means you don't need to open Git Bash manually; the assistant will work seamlessly right inside your standard PowerShell!**
4. Guide you on how to reload your terminal.

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

### Modular & Custom Engine Support
- Built-in support for **Ollama**, **OpenCode**, and **Antigravity**.
- Create your own **Custom Engines** by saving `.sh` scripts in `custom/engines/` (e.g., `custom/engines/my_engine.sh`).
- The assistant stores preferred models per engine, meaning you won't lose your selected model configurations when switching between engines.
- Switch between engines interactively with `assistant engine --list` or directly using `assistant engine <name>`.

### Built-in Skills (Default Skills)
The assistant comes with several built-in skills to boost your workflow:
- **Commit Assistant (`assistant commit`)**: Analyzes your Git repository's status, staged diffs, and unstaged change statistics, and runs them against standard guidelines to generate clean, readable commit message suggestions.
- **Project Resume Generator (`assistant resume [paths...]`)**: Automatically gathers context from your project directory (structural tree and manifest files like `package.json`, `pom.xml`, `Cargo.toml`, etc.) and formats a comprehensive markdown resume outlining project architecture and dependencies.
- **README Generator (`assistant readme --lang [lang] --name [filename]`)**: Automatically analyzes your project structure and configuration files to generate a professional, contextualized README file.

### Custom Skills
You can create your own custom skills using Markdown files that define guidelines for the LLM.

If you try to create a custom skill with the same name as a default/built-in skill (e.g., `commit`), the CLI will ask for confirmation:
```
⚠ The skill 'commit' is a default assistant skill.
Do you really want to overwrite it? [y/N]:
```
If you choose to overwrite (`y`/`yes`), your custom skill will take precedence over the built-in skill when executing `assistant commit`.

#### Running Custom Skills
Run your custom skill directly as a command:
```bash
assistant <name> "your prompt or task"
```

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

For detailed documentation, function API contracts, and advanced step-by-step examples on creating custom AI engines, locales, skills, and dynamic shell commands, refer to the **[Customization and Extensions Guide (docs/README.md)](docs/README.md)**.

Starter templates are also available inside the [`docs/templates/`](docs/templates/)

## Usage

When running `assistant`, you have access to the following commands:

| Command | Description |
| :--- | :--- |
| `assistant` | Starts interactive chat with the current model |
| `assistant "<message>"` | Sends a direct message to the current model |
| `assistant status` | Shows active engine, active models, think mode, and language |
| `assistant commit` | Analyzes git staging and suggests structured commits |
| `assistant resume [paths...]` | Scans directories and generates project resume markdown files |
| `assistant readme --lang <lang> --name <name>` | Scans project structure and generates a README file |
| `assistant create skill <name> <path.md>` | Creates a new custom skill from a Markdown template |
| `assistant <custom-skill> [args]` | Executes a custom skill |
| `assistant lang [<lang>\|--list\|status]` | Changes active language, lists available languages, or shows current language |
| `assistant model --list` | Interactively lists available models for the current engine to switch them |
| `assistant model status` | Shows currently configured models for all engines |
| `assistant engine [<name>\|--list\|status]` | Changes active engine |
| `assistant think [on\|off\|hide\|clear]` | Toggles thinking/reasoning modes on Ollama models |

### Examples

```bash
# Ask a general coding question
assistant "How do I implement a debouncer in vanilla JS?"

# Generate git commits from staged changes
assistant commit

# Switch active engine to Antigravity (agy), Ollama, or OpenCode
assistant engine agy
assistant engine ollama
assistant engine opencode

# Interactively switch engines
assistant engine --list

# Interactively change model for the current engine
assistant model --list
```

## Project Structure

```
assistant/
├── custom/                  # User custom engines, skills, and locales
│   ├── engines/             # Custom engine scripts (.sh)
│   ├── locales/             # Custom locale translations (.sh)
│   └── skills/              # Custom markdown skills (.md)
├── data/                    # Persistent configuration store (engine, model, lang)
├── docs/                    # Customization guides and extension templates
│   ├── templates/           # Starter templates (engine, locales, skills)
│   └── README.md            # Customization guide
├── lib/                     # Modular engines (lib/engines/), core routes, utilities
├── locales/                 # Text translations
├── skills/                  # Built-in skills
├── utils/                   # Utility scripts and helpers
├── init.sh                  # Main entry point to source in shell config files
├── LICENSE.txt              # License
└── README.md                # Documentation
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE.txt) file for details.

