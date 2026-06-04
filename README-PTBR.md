[EN](README.md)

<div align="center">
  <h1 style="font-size: 32px; border: none; line-height: 0; font-weight: bold">Assistant CLI</h1>
  <p>Um wrapper de terminal leve, modular e localizado para Ollama e OpenCode, com suporte a chat interativo, análise de repositórios e resumos de projetos.</p>
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
- [Uso](#uso)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Licença](#licença)

## Descrição

O **Zsh AI Assistant** (`@assistant`) é uma interface de linha de comando (CLI) poderosa e leve escrita em Zsh/Bash. Ela permite que os usuários interajam com Modelos de Linguagem de Grande Porte (LLMs) locais orquestrados via **Ollama** ou **OpenCode** diretamente a partir do terminal.

Todas as escolhas de configuração (como engine ativa, modelo selecionado, idioma e modo de pensamento) são salvas localmente e persistem entre as sessões do terminal.

## Tecnologias

- **Zsh / Bash** - Ambiente de script e wrapper da função principal
- **Ollama** - Engine de orquestração para modelos locais (ex: DeepSeek, Llama, Gemma)
- **OpenCode** - Engine de orquestração e registro para modelos voltados a código

## Funcionalidades

### Chat Interativo e Direto
- Execute `@assistant` para iniciar uma sessão de chat interativo com o seu modelo selecionado.
- Execute `@assistant "sua pergunta aqui"` para enviar uma pergunta rápida e obter a resposta diretamente no terminal.

### Suporte a Múltiplas Engines
- Alternância rápida entre **Ollama** e **OpenCode**.
- O assistente salva os modelos de preferência por engine. Desta forma, você não perde as configurações de modelo ao alternar de engine.

### Habilidades (*Skills*) Personalizadas
- **Assistente de Commit (`@assistant commit`)**: Analisa o status do seu repositório Git, diffs da staging e estatísticas de alterações para gerar sugestões de mensagens de commit claras e estruturadas, seguindo as diretrizes recomendadas.
- **Gerador de Resumos de Projeto (`@assistant resume [caminhos...]`)**: Coleta informações estruturais do diretório (árvore estrutural e arquivos de manifesto como `package.json`, `pom.xml`, `Cargo.toml`, etc.) e formata um resumo completo em markdown descrevendo a arquitetura e dependências do projeto.

### Gerenciamento do Modo Think (Ollama)
- Ativa, desativa ou oculta as etapas de raciocínio do modelo (para modelos com suporte a pensamento/reasoning que utilizam tags `<think>...</think>`). Pode ser configurado por sessão ou salvo globalmente.

### Tradução e Suporte Multilíngue
- Suporte nativo para mensagens, status e menus de ajuda em inglês (`en`) e português (`pt-br`).

## Instalação e Configuração

1. Clone ou copie a pasta do assistente para o seu diretório de configuração do Zsh:
   ```bash
   git clone https://github.com/lpatros/assistant-cli.git ~/.config/zsh/assistant
   ```

2. Adicione a seguinte linha ao seu arquivo `~/.zshrc` (ou `~/.bashrc`):
   ```bash
   source "$HOME/.config/zsh/assistant/init.sh"
   ```

3. Recarregue a configuração do terminal:
   ```bash
   source ~/.zshrc
   ```

## Uso

Ao rodar `@assistant`, você tem acesso aos seguintes comandos:

| Comando | Descrição |
| :--- | :--- |
| `@assistant` | Inicia o chat interativo com o modelo atual |
| `@assistant "<mensagem>"` | Envia uma mensagem direta para o modelo atual |
| `@assistant status` | Mostra a engine ativa, modelos ativos, modo think e idioma |
| `@assistant commit` | Analisa a área de staging do git e sugere commits estruturados |
| `@assistant resume [caminhos...]` | Escaneia diretórios e gera resumos de projeto em arquivos markdown |
| `@assistant model --list` | Lista de forma interativa os modelos disponíveis na engine ativa para seleção |
| `@assistant model status` | Mostra os modelos configurados para todas as engines |
| `@assistant engine [ollama\|opencode]` | Altera a engine de orquestração de modelo ativa |
| `@assistant think [on\|off\|hide\|clear]` | Gerencia as opções de pensamento/raciocínio nos modelos Ollama |
| `@assistant lang [en\|pt-br]` | Altera a configuração de idioma da interface CLI |

### Exemplos

```bash
# Fazer uma pergunta sobre programação
@assistant "Como eu implemento um debouncer em JS puro?"

# Gerar mensagens de commit a partir das alterações no git staging
@assistant commit

# Criar resumos de projeto em paralelo para duas pastas
@assistant resume ./backend-service ./frontend-app

# Alterar o modelo de forma interativa
@assistant model --list
```

## Estrutura do Projeto

```
assistant/
├── data/                    # Armazena configurações e metadados do sistema.
├── lib/                     # Caminhos constantes, traduções e rotas de comandos.
├── locales/                 # Traduções usadas pelo CLI
├── skills/
│   ├── commit/              # Habilidade de sugestão de commits de Git
│   └── resume/              # Habilidade de geração de resumos de projeto
│
├── utils/                   # Funções utilitárias auxiliares
├── init.sh                  # Ponto de entrada principal para carregar no shell
├── README-PTBR.md           # Documentação em português
└── README.md                # Documentação em inglês
```
