<div align="center">

# Assistant CLI

[English](README.md) | **Português** | [Español](README-ES.md)

  <p>Um wrapper de terminal leve, modular e localizado para Antigravity (agy), Codex, Copilot, Ollama, OpenCode e Custom Engines, com suporte a chat interativo, análise de repositórios, geração de README, resumos de projetos e muito mais.</p>
    <div style="margin-bottom: 10px">
    <img src="https://img.shields.io/badge/Language-Shell-orange.svg"/>
    </div>
    <br>
</div>

# Links Rápidos

- [Descrição](#descrição)
- [Instalação e Configuração](#instalação-e-configuração)
- [Atualização e Versão](#atualização-e-versão)
- [Funcionalidades](#funcionalidades)
- [Uso](#uso)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Licença](#licença)

## Descrição

O **Assistant CLI** (`assistant`) é uma interface de linha de comando (CLI) poderosa e leve escrita em Bash. Ela permite que os usuários interajam com Modelos de Linguagem de Grande Porte (LLMs) locais ou em nuvem orquestrados via **Antigravity**, **Codex**, **Copilot**, **Ollama**, **OpenCode** ou **Engines Customizadas** (`custom/engines/`) diretamente a partir do terminal.

Todas as escolhas de configuração (como engine ativa, modelos salvos por engine, idioma e modo de pensamento) são salvas localmente e persistem entre as sessões do terminal.

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

#### PowerShell

Para usuários do **Windows** utilizando o PowerShell, você pode instalar executando:

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

<details>
<summary> <b>Como adicionar ou corrigir o Git Bash nas Variáveis de Ambiente (PATH) do Windows</b></summary>

### Passo a Passo:

1. **Verificar se já está configurado:**
   - Abra o **PowerShell** ou **Prompt de Comando (CMD)**.
   - Digite `bash --version` ou `where bash` e aperte Enter.
   - Se o comando retornar a versão do Bash ou o caminho do executável, já está configurado! Caso contrário, siga os passos abaixo.

2. **Localizar o caminho de instalação do Git Bash:**
   - Por padrão, o Git Bash é instalado em: `C:\Program Files\Git\bin` (ou `C:\Program Files (x86)\Git\bin`).
   - Abra o Explorador de Arquivos do Windows, navegue até essa pasta e certifique-se de que o arquivo `bash.exe` está lá. Copie o caminho da pasta (`C:\Program Files\Git\bin`).

3. **Abrir as Variáveis de Ambiente:**
   - Pressione a tecla `Windows`, digite **"variáveis de ambiente"** e selecione a opção **"Editar as variáveis de ambiente do sistema"**.
   - Na janela que abrir, clique no botão **"Variáveis de Ambiente..."** (localizado no canto inferior direito).

4. **Editar a variável PATH:**
   - Em **"Variáveis do usuário"** (para aplicar apenas ao seu usuário) ou **"Variáveis do sistema"** (para aplicar a todos os usuários), localize a variável chamada **`Path`** e selecione-a.
   - Clique no botão **"Editar..."**.

5. **Adicionar o caminho:**
   - Clique no botão **"Novo"** no lado direito.
   - Cole o caminho copiado no Passo 2 (ex: `C:\Program Files\Git\bin`).
   - Clique em **"OK"** em todas as janelas abertas para salvar e aplicar a alteração.

6. **Validar a configuração:**
   - **Importante:** Feche todas as janelas abertas do PowerShell ou do CMD e abra um novo terminal para carregar as novas variáveis de ambiente.
   - Digite `bash --version` no novo terminal. Se a versão do Bash for exibida com sucesso, a configuração foi concluída!
</details>

**No Windows via PowerShell, o instalador interativo irá:**
1. Clonar o repositório para `%LOCALAPPDATA%\assistant-cli` (ou outro diretório de sua escolha).
2. Verificar se o sistema possui o `bash` instalado (via Git Bash ou WSL), que é necessário para rodar os scripts `.sh`.
3. Adicionar uma função wrapper ao seu perfil do PowerShell (`$PROFILE`) que chamará o `bash` silenciosamente. **Isso significa que você não precisa abrir o Git Bash para usar o assistente; ele funcionará perfeitamente direto no seu PowerShell!**
4. Fornecer instruções de como recarregar o seu terminal.

#### Bash (Git Bash / WSL)

Se você utiliza o **Bash** como seu terminal no Windows, pode instalar o Assistant CLI diretamente usando o `curl`:

```bash
curl -fsSL https://raw.githubusercontent.com/lpatros/assistant-cli/main/install.sh | bash
```

**No Bash, o instalador interativo irá:**
1. Clonar o repositório para a pasta de instalação (`%LOCALAPPDATA%\assistant-cli` ou `~/.config/assistant-cli`).
2. Adicionar automaticamente a configuração ao seu perfil do shell (`~/.bashrc`, `~/.zshrc` ou `config.fish`).
3. Fornecer instruções de como recarregar o seu terminal para começar a usar o assistente.

## Atualização e Versão

Você pode verificar a versão atual do assistente com:

```bash
assistant --version
```

Você pode atualizar facilmente o seu Assistant CLI para a versão mais recente ou alternar para uma versão específica:

```bash
assistant update                     # Atualiza para a versão mais recente do canal ativo
assistant update --list              # Lista as versões disponíveis (ou -l)
assistant update @1.2.0              # Atualiza/alterna para a versão 1.2.0
assistant update --version 1.2.0     # Forma alternativa para definir a versão
```

Você também pode alternar entre canais de release (estável e beta):

```bash
assistant channel status  # Mostra o canal de release atual
assistant channel beta    # Alterna para o canal beta (branch dev) e atualiza
assistant channel stable  # Alterna para o canal estável (branch main) e atualiza
```

## Funcionalidades

### Chat Interativo e Direto
- Execute `assistant` para iniciar uma sessão de chat interativo com o seu modelo selecionado.
- Execute `assistant "sua pergunta aqui"` para enviar uma pergunta rápida e obter a resposta diretamente no terminal.

### Suporte a Engines Modulares e Customizadas
- Suporte nativo para **Antigravity**, **Codex**, **Copilot**, **Ollama** e **OpenCode**.
- Crie suas próprias **Custom Engines** salvando scripts `.sh` em `custom/engines/` (ex: `custom/engines/minha_engine.sh`).
- O assistente salva os modelos de preferência por engine. Desta forma, você não perde as configurações de modelo ao alternar de engine.
- Alterne entre as engines de forma interativa com `assistant engine --list` ou diretamente com `assistant engine <nome>`.

### Habilidades Padrão (Built-in Skills)
O assistente vem com várias habilidades prontas para acelerar o seu fluxo de trabalho:
- **Assistente de Commit (`assistant commit`)**: Analisa o status do seu repositório Git, diffs da staging e estatísticas de alterações para gerar sugestões de mensagens de commit claras e estruturadas, seguindo as diretrizes recomendadas.
- **Gerador de Resumos de Projeto (`assistant resume [caminhos...]`)**: Coleta informações estruturais do diretório (árvore estrutural e arquivos de manifesto como `package.json`, `pom.xml`, `Cargo.toml`, etc.) e formata um resumo completo em markdown descrevendo a arquitetura e dependências do projeto.
- **Gerador de README (`assistant readme --lang [idioma] --name [nome_do_arquivo]`)**: Analisa automaticamente a estrutura do seu projeto e arquivos de configuração para gerar um README profissional e contextualizado.

### Habilidades Personalizadas (Custom Skills)
Você pode criar suas próprias habilidades personalizadas usando arquivos Markdown que definem as instruções e diretrizes para o LLM.

#### Criando uma Skill Customizada
```bash
assistant create skill <nome> <caminho-do-arquivo-md>
```
Isso salvará as regras da sua skill personalizada em `custom/skills/<nome>-assistant.md`.

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

#### Comandos Dinâmicos Customizados (Shell)
Você também pode definir funções Shell customizadas para executar lógicas dinâmicas.

Para isso, crie ou edite o arquivo `custom/init.sh` e defina funções seguindo a convenção de nome `_cmd_<nome>`:

```bash
# custom/init.sh
_cmd_hello() {
  echo "Olá a partir de uma função customizada em Shell!"
  echo "Argumentos recebidos: $*"
}
```

Qualquer função declarada como `_cmd_<nome>` no `custom/init.sh` será despachada automaticamente ao executar:
```bash
assistant hello "mundo"
```

#### Locales Customizados (Idiomas Personalizados)
Você pode adicionar sua própria tradução de idioma criando um arquivo `.sh` em `custom/locales/<lang>.sh` (por exemplo, `custom/locales/fr.sh`).

No arquivo customizado, defina as funções de tradução desejadas (ex: `t_lang_changed`, `t_lang_status`). Qualquer função não definida no seu arquivo customizado utilizará automaticamente o fallback em inglês (`locales/en.sh`).

```bash
# custom/locales/fr.sh
t_lang_changed() {
  _success "Langue modifiée en: ${BOLD}$1${RESET}"
}
t_lang_status() {
  _info "Langue actuelle: ${CYAN}${BOLD}$1${RESET}"
}
```

Alterne para o idioma personalizado ou liste os idiomas disponíveis:
```bash
# Definir idioma customizado
assistant lang fr

# Listar todos os idiomas disponíveis (padrão e customizados)
assistant lang --list
```

#### Guia Completo de Customização e Templates
Para documentação detalhada, especificações de contrato de funções e exemplos avançados sobre como criar motores de IA, idiomas, habilidades (skills) e comandos dinâmicos, consulte o **[Guia de Customização e Extensões (docs/CUSTOMIZATION-PTBR.md)](docs/CUSTOMIZATION-PTBR.md)**.

Você também pode utilizar os modelos de referência disponíveis em [`docs/templates/`](docs/templates/)
## Uso

| Comando | Descrição |
| :--- | :--- |
| `assistant` | Inicia o chat interativo com o modelo atual |
| `assistant "<mensagem>"` | Envia uma mensagem direta para o modelo atual |
| `assistant status` | Mostra engine ativa, modelos ativos, modo think e idioma |
| `assistant commit` | Analisa a staging do git e sugere commits estruturados |
| `assistant resume [caminhos...]` | Escaneia diretórios e gera arquivos markdown de resumo de projeto |
| `assistant readme --lang <idioma> --name <nome>` | Escaneia a estrutura do projeto e gera um arquivo README |
| `assistant create skill <nome> <caminho.md>` | Cria uma nova skill personalizada a partir de um modelo Markdown |
| `assistant <skill-customizada> [args]` | Executa uma skill personalizada |
| `assistant lang [<idioma>\|--list\|status]` | Altera o idioma ativo, lista idiomas disponíveis ou mostra o idioma atual |
| `assistant model --list` | Lista de forma interativa os modelos disponíveis na engine ativa para seleção |
| `assistant model status` | Mostra os modelos configurados para todas as engines |
| `assistant engine [<nome>\|--list\|status]` | Altera a engine ativa |
| `assistant think [on\|off\|hide\|clear]` | Gerencia as opções de pensamento/raciocínio nos modelos Ollama |

### Exemplos

```bash
# Fazer uma pergunta sobre programação
assistant "Como eu implemento um debouncer em JS puro?"

# Gerar mensagens de commit a partir das alterações no git staging
assistant commit

# Trocar a engine ativa para Antigravity (agy), Codex, Copilot, Ollama ou OpenCode
assistant engine agy
assistant engine codex
assistant engine copilot
assistant engine ollama
assistant engine opencode

# Alterar a engine de forma interativa
assistant engine --list

# Alterar o modelo da engine atual de forma interativa
assistant model --list
```

## Estrutura do Projeto

```
assistant/
├── custom/                  # Engines, habilidades e idiomas personalizados do usuário
│   ├── engines/             # Engines customizadas (scripts .sh)
│   ├── locales/             # Idiomas customizados (.sh)
│   └── skills/              # Habilidades customizadas (.md)
├── data/                    # Armazena configurações e metadados do sistema
├── docs/                    # Guias de customização e templates de extensão
│   ├── templates/           # Modelos de referência (engine, locales, skills)
│   └── CUSTOMIZATION.md     # Guia de customização
├── lib/                     # Motores (lib/engines/), rotas e utilitários do sistema
├── locales/                 # Traduções usadas pelo CLI
├── skills/                  # Habilidades do Assistant
├── utils/                   # Funções utilitárias auxiliares
├── init.sh                  # Ponto de entrada principal para carregar no shell
├── LICENSE.txt              # Licença
└── README.md                # Documentação
```

## Licença

Este projeto está licenciado sob a Licença MIT - consulte o arquivo [LICENSE](LICENSE.txt) para mais detalhes.

