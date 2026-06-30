[PT-BR](README-PTBR.md)

<div align="center">
  <h1 style="font-size: 32px; border: none; line-height: 0; font-weight: bold">Assistant CLI</h1>
  <p>A lightweight, modular, and localized shell wrapper for Ollama and OpenCode, supporting interactive chat, repository analysis, and project summaries.</p>
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
- [Usage](#usage)
- [Project Structure](#project-structure)
- [License](#license)

## Description

The **Assistant CLI** (`@assistant`) is a powerful, lightweight command-line interface (CLI) wrapper written in Zsh/Bash. It allows users to interact with local Large Language Models (LLMs) orchestrated via **Ollama** or **OpenCode** directly from the terminal. 

All configuration choices (such as active engine, selected model, language, and think mode) are saved locally and persist across terminal sessions.

## Technologies

- **Zsh / Bash** - Scripting environment and main function wrapper
- **Ollama** - Orchestration engine for local models (e.g., DeepSeek, Llama, Gemma)
- **OpenCode** - Orchestration engine and registry for coding models

## Features

### Interactive & Direct Chat
- Run `@assistant` to start an interactive chat session with your currently selected model.
- Run `@assistant "your prompt here"` to quickly send a single query to the model and receive the output.

### Multi-Engine Support
- Seamless switching between **Ollama** and **OpenCode**.
- The assistant stores preferred models per engine, meaning you won't lose your selected model configurations when switching between engines.

### Custom LLM Skills
- **Commit Assistant (`@assistant commit`)**: Analyzes your Git repository's status, staged diffs, and unstaged change statistics, and runs them against standard guidelines to generate clean, readable commit message suggestions.
- **Project Resume Generator (`@assistant resume [paths...]`)**: Automatically gathers context from your project directory (structural tree and manifest files like `package.json`, `pom.xml`, `Cargo.toml`, etc.) and formats a comprehensive markdown resume outlining project architecture and dependencies.

### Think Mode Management (Ollama)
- Enables, disables, or hides the model's reasoning/thinking steps (e.g., for models that output thoughts like `<think>...</think>`). Can be toggled per session or saved globally.

### Localization & Multi-language Support
- Built-in support for both English (`en`) and Portuguese (`pt-br`) output messages, status reports, and help sections.

## Installation & Setup

1. Clone or copy the assistant folder to your Zsh configuration directory:
   ```bash
   git clone https://github.com/lpatros/assistant-cli.git ~/.config/zsh/assistant
   ```

2. Add the following line to your `~/.zshrc` (or `~/.bashrc`):
   ```bash
   source "$HOME/.config/zsh/assistant/init.sh"
   ```

3. Reload your shell configuration:
   ```bash
   source ~/.zshrc
   ```

## Usage

When running `@assistant`, you have access to the following commands:

| Command | Description |
| :--- | :--- |
| `@assistant` | Starts interactive chat with the current model |
| `@assistant "<message>"` | Sends a direct message to the current model |
| `@assistant status` | Shows active engine, active models, think mode, and language |
| `@assistant commit` | Analyzes git staging and suggests structured commits |
| `@assistant resume [paths...]` | Scans directories and generates project resume markdown files |
| `@assistant model --list` | Interactively lists available models for the current engine to switch them |
| `@assistant model status` | Shows currently configured models for all engines |
| `@assistant engine [ollama\|opencode]` | Switches the active model orchestration engine |
| `@assistant think [on\|off\|hide\|clear]` | Toggles thinking/reasoning modes on Ollama models |
| `@assistant lang [en\|pt-br]` | Changes the CLI's language configuration |

### Examples

```bash
# Ask a general coding question
@assistant "How do I implement a debouncer in vanilla JS?"

# Generate git commits from staged changes
@assistant commit

# Create project summary docs in parallel for two folders
@assistant resume ./backend-service ./frontend-app

# Interactively change model
@assistant model --list
```

## Project Structure

```
assistant/
├── data/                    # Persistent configuration store (engine, model, lang)
├── lib/                     # Paths constants,Translates and Handles command routes.
├── locales/                 # Text translations
├── skills/
│   ├── commit/              # Git commit suggestion tools
│   └── resume/              # Project resume generator tools
│
├── utils/                   # Utility scripts and helpers
├── init.sh                  # Main entry point to source in shell config files
├── README-PTBR.md           # Documentation in Portuguese
└── README.md                # Documentation in English
```
