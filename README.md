<div align="center">

# Assistant CLI

**English** | [Português](README-PTBR.md) | [Español](README-ES.md)

  <p>A lightweight, modular, and localized shell wrapper for Ollama and OpenCode, supporting interactive chat, commit generation, README generation, project summaries, and more.</p>
    <div style="margin-bottom: 10px">
    <img src="https://img.shields.io/badge/Language-Shell-orange.svg" alt="Language: Zsh/Bash"/>
    <img src="https://img.shields.io/badge/Engines-Ollama%20%7C%20OpenCode-blue.svg" alt="Engines: Ollama & OpenCode"/>
    <img src="https://img.shields.io/badge/Think_Mode-Supported-yellow.svg" alt="Think Mode"/>
    </div>
    <br>
</div>

# Quick Links

- [Description](#description)
- [Technologies](#technologies)
- [Features](#features)
- [Installation & Setup](#installation--setup)
- [Update](#update)
- [Usage](#usage)
- [Project Structure](#project-structure)

## Description

The **Assistant CLI** (`assistant`) is a powerful, lightweight command-line interface (CLI) wrapper written in Bash. It allows users to interact with local Large Language Models (LLMs) orchestrated via **Ollama** or **OpenCode** directly from the terminal. 

All configuration choices (such as active engine, selected model, language, and think mode) are saved locally and persist across terminal sessions.

## Technologies

- **Bash** - Scripting environment and main function wrapper
- **Ollama** - Orchestration engine for local models (e.g., DeepSeek, Llama, Gemma)
- **OpenCode** - Orchestration engine and registry for coding models

## Features

### Interactive & Direct Chat
- Run `assistant` to start an interactive chat session with your currently selected model.
- Run `assistant "your prompt here"` to quickly send a single query to the model and receive the output.

### Multi-Engine Support
- Seamless switching between **Ollama** and **OpenCode**.
- The assistant stores preferred models per engine, meaning you won't lose your selected model configurations when switching between engines.

### Built-in Skills (Default Skills)
The assistant comes with several built-in skills to boost your workflow:
- **Commit Assistant (`assistant commit`)**: Analyzes your Git repository's status, staged diffs, and unstaged change statistics, and runs them against standard guidelines to generate clean, readable commit message suggestions.
- **Project Resume Generator (`assistant resume [paths...]`)**: Automatically gathers context from your project directory (structural tree and manifest files like `package.json`, `pom.xml`, `Cargo.toml`, etc.) and formats a comprehensive markdown resume outlining project architecture and dependencies.
- **README Generator (`assistant readme --lang [en|pt-br] --name [filename]`)**: Automatically analyzes your project structure and configuration files to generate a professional, contextualized README file.

### Custom Skills
You can create your own custom skills using Markdown files that define guidelines for the LLM.

#### Creating a Custom Skill
```bash
assistant create skill <name> <path-to-markdown-file>
```
This will save your custom skill rules in `custom/<name>-assistant.md`.

#### Overwriting Default Skills
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
> Also ensure that Git Bash is included in your system's Environment Variables (usually located at `C:\Program Files\Git\bin`).

**On Windows, the interactive installer will:**
1. Clone the repository to `%LOCALAPPDATA%\assistant-cli` (or a custom directory of your choice).
2. Verify if `bash` is available in your system (e.g., Git Bash or WSL) since the core project uses `.sh` scripts.
3. Add a wrapper function directly into your PowerShell profile (`$PROFILE`) that transparently calls `bash`. **This means you don't need to open Git Bash manually; the assistant will work seamlessly right inside your standard PowerShell!**
4. Guide you on how to reload your terminal.

## Update

You can easily update your Assistant CLI to the latest version by running the update command. This will pull the latest changes from the repository and ensure your local installation is up to date.

```bash
assistant update
```

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
| `assistant model --list` | Interactively lists available models for the current engine to switch them |
| `assistant model status` | Shows currently configured models for all engines |
| `assistant engine [ollama\|opencode]` | Switches the active model orchestration engine |
| `assistant think [on\|off\|hide\|clear]` | Toggles thinking/reasoning modes on Ollama models |

### Examples

```bash
# Ask a general coding question
assistant "How do I implement a debouncer in vanilla JS?"

# Generate git commits from staged changes
assistant commit

# Create project summary docs in parallel for two folders
assistant resume ./backend-service ./frontend-app

# Interactively change model
assistant model --list
```

## Project Structure

```
assistant/
├── custom/                  # User-defined custom skills
├── data/                    # Persistent configuration store (engine, model, lang)
├── lib/                     # Paths constants,Translates and Handles command routes.
├── locales/                 # Text translations
├── skills/                  # Assistant tools
├── utils/                   # Utility scripts and helpers
├── init.sh                  # Main entry point to source in shell config files
└── README.md                # Documentation
```
