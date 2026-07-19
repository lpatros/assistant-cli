[EN](README.md)

<div align="center">
  <h1 style="font-size: 32px; border: none; line-height: 0; font-weight: bold">Assistant CLI</h1>
  <p>Um wrapper de terminal leve, modular e localizado para Ollama e OpenCode, com suporte a chat interativo, análise de repositórios, geração de README, resumos de projetos e muito mais.</p>
    <div style="margin-bottom: 10px">
    <img src="https://img.shields.io/badge/Language-Shell-orange.svg" alt="Linguagem: Zsh/Bash"/>
    <img src="https://img.shields.io/badge/Engines-Ollama%20%7C%20OpenCode-blue.svg" alt="Engines: Ollama & OpenCode"/>
    <img src="https://img.shields.io/badge/Think_Mode-Suportado-yellow.svg" alt="Modo Think"/>
    </div>
    <br>
</div>

# Links Rápidos

- [Descrição](#descrição)
- [Tecnologias](#tecnologias)
- [Funcionalidades](#funcionalidades)
- [Instalação e Configuração](#instalação-e-configuração)
- [Atualização](#atualização)
- [Uso](#uso)
- [Estrutura do Projeto](#estrutura-do-projeto)

## Descrição

O **Assistant CLI** (`assistant`) é uma interface de linha de comando (CLI) poderosa e leve escrita em Zsh/Bash. Ela permite que os usuários interajam com Modelos de Linguagem de Grande Porte (LLMs) locais orquestrados via **Ollama** ou **OpenCode** diretamente a partir do terminal.

Todas as escolhas de configuração (como engine ativa, modelo selecionado, idioma e modo de pensamento) são salvas localmente e persistem entre as sessões do terminal.

## Tecnologias

- **Zsh / Bash** - Ambiente de script e wrapper da função principal
- **Ollama** - Engine de orquestração para modelos locais (ex: DeepSeek, Llama, Gemma)
- **OpenCode** - Engine de orquestração e registro para modelos voltados a código

## Funcionalidades

### Chat Interativo e Direto
- Execute `assistant` para iniciar uma sessão de chat interativo com o seu modelo selecionado.
- Execute `assistant "sua pergunta aqui"` para enviar uma pergunta rápida e obter a resposta diretamente no terminal.

### Suporte a Múltiplas Engines
- Alternância rápida entre **Ollama** e **OpenCode**.
- O assistente salva os modelos de preferência por engine. Desta forma, você não perde as configurações de modelo ao alternar de engine.

### Habilidades Padrão (Built-in Skills)
O assistente vem com várias habilidades prontas para acelerar o seu fluxo de trabalho:
- **Assistente de Commit (`assistant commit`)**: Analisa o status do seu repositório Git, diffs da staging e estatísticas de alterações para gerar sugestões de mensagens de commit claras e estruturadas, seguindo as diretrizes recomendadas.
- **Gerador de Resumos de Projeto (`assistant resume [caminhos...]`)**: Coleta informações estruturais do diretório (árvore estrutural e arquivos de manifesto como `package.json`, `pom.xml`, `Cargo.toml`, etc.) e formata um resumo completo em markdown descrevendo a arquitetura e dependências do projeto.
- **Gerador de README (`assistant readme --lang [en|pt-br] --name [nome_do_arquivo]`)**: Analisa automaticamente a estrutura do seu projeto e arquivos de configuração para gerar um README profissional e contextualizado.

### Habilidades Personalizadas (Custom Skills)
Você pode criar suas próprias habilidades personalizadas usando arquivos Markdown que definem as instruções e diretrizes para o LLM.

#### Criando uma Skill Customizada
```bash
assistant create skill <nome> <caminho-do-arquivo-md>
```
Isso salvará as regras da sua skill personalizada em `custom/<nome>-assistant.md`.

#### Sobrescrevendo Skills Padrão
Se você tentar criar uma skill customizada com o mesmo nome de uma skill padrão/embutida (como `commit`), o CLI solicitará confirmação antes de prosseguir:
```
⚠ A skill 'commit' é uma skill padrão do assistente.
Deseja realmente sobrescrevê-la? [y/N]:
```
Se você optar por sobrescrever (`y`/`yes`), sua skill customizada terá prioridade sobre a embutida ao executar `assistant commit`.

#### Executando Skills Customizadas
Execute sua skill customizada diretamente como um comando do assistente:
```bash
assistant <nome> "sua instrução ou tarefa"
```

### Gerenciamento do Modo Think (Ollama)
- Ativa, desativa ou oculta as etapas de raciocínio do modelo (para modelos com suporte a pensamento/reasoning que utilizam tags `<think>...</think>`). Pode ser configurado por sessão ou salvo globalmente.

### Tradução e Suporte Multilíngue
- Suporte nativo para mensagens, status e menus de ajuda em inglês (`en`) e português (`pt-br`).

## Instalação e Configuração

O Assistant CLI oferece scripts de instalação adequados para diferentes sistemas operacionais.

### Linux e macOS

Você pode instalar o Assistant CLI diretamente usando o `curl`:

```bash
curl -fsSL https://raw.githubusercontent.com/lpatros/assistant-cli/main/install.sh | bash
```

**No Linux e macOS, o instalador interativo irá:**
1. Clonar o repositório para `~/.config/assistant-cli` (ou outro diretório de sua escolha).
2. Adicionar automaticamente a configuração ao seu perfil do shell (`~/.zshrc`, `~/.bashrc` ou `config.fish`).
3. Fornecer instruções de como recarregar o seu terminal para começar a usar o assistente.

### Windows

Para usuários do **Windows**, você pode instalar utilizando o PowerShell. Abra o seu PowerShell e execute:


> [!IMPORTANT] 
> Certifique-se de que a política de execução de scripts esteja ativada antes de executar o instalador. Você pode ativá-la rodando:
> ```powershell
> Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
> ```

```powershell
irm https://raw.githubusercontent.com/lpatros/assistant-cli/main/install.ps1 | iex
```

> [!NOTE]
> Certifique-se também de que o Git Bash está adicionado às variáveis de ambiente do seu sistema (geralmente em `C:\Program Files\Git\bin`).

**No Windows, o instalador interativo irá:**
1. Clonar o repositório para `%LOCALAPPDATA%\assistant-cli` (ou outro diretório de sua escolha).
2. Verificar se o sistema possui o `bash` instalado (via Git Bash ou WSL), que é necessário para rodar os scripts `.sh`.
3. Adicionar uma função wrapper ao seu perfil do PowerShell (`$PROFILE`) que chamará o `bash` silenciosamente. **Isso significa que você não precisa abrir o Git Bash para usar o assistente; ele funcionará perfeitamente direto no seu PowerShell!**
4. Fornecer instruções de como recarregar o seu terminal.

## Atualização

Você pode atualizar facilmente o seu Assistant CLI para a versão mais recente executando o comando de atualização. Isso fará o download das últimas alterações do repositório, garantindo que sua instalação local esteja em dia.

```bash
assistant update
```

## Uso

Ao rodar `assistant`, você tem acesso aos seguintes comandos:

| Comando | Descrição |
| :--- | :--- |
| `assistant` | Inicia o chat interativo com o modelo atual |
| `assistant "<mensagem>"` | Envia uma mensagem direta para o modelo atual |
| `assistant status` | Mostra a engine ativa, modelos ativos, modo think e idioma |
| `assistant commit` | Analisa a área de staging do git e sugere commits estruturados |
| `assistant resume [caminhos...]` | Escaneia diretórios e gera resumos de projeto em arquivos markdown |
| `assistant readme --lang <lang> --name <name>` | Escaneia a estrutura do projeto e gera um arquivo README |
| `assistant create skill <nome> <caminho.md>` | Cria uma nova skill personalizada a partir de um template Markdown |
| `assistant <skill-customizada> [args]` | Executa uma skill personalizada |
| `assistant model --list` | Lista de forma interativa os modelos disponíveis na engine ativa para seleção |
| `assistant model status` | Mostra os modelos configurados para todas as engines |
| `assistant engine [ollama\|opencode]` | Altera a engine de orquestração de modelo ativa |
| `assistant think [on\|off\|hide\|clear]` | Gerencia as opções de pensamento/raciocínio nos modelos Ollama |
| `assistant lang [en\|pt-br]` | Altera a configuração de idioma da interface CLI |

### Exemplos

```bash
# Fazer uma pergunta sobre programação
assistant "Como eu implemento um debouncer em JS puro?"

# Gerar mensagens de commit a partir das alterações no git staging
assistant commit

# Criar resumos de projeto em paralelo para duas pastas
assistant resume ./backend-service ./frontend-app

# Alterar o modelo de forma interativa
assistant model --list
```

## Estrutura do Projeto

```
assistant/
├── data/                    # Armazena configurações e metadados do sistema.
├── lib/                     # Caminhos constantes, traduções e rotas de comandos.
├── locales/                 # Traduções usadas pelo CLI
├── skills/                  # Habilidades do Assistant
├── utils/                   # Funções utilitárias auxiliares
├── init.sh                  # Ponto de entrada principal para carregar no shell
├── README-PTBR.md           # Documentação em português
└── README.md                # Documentação em inglês
```
