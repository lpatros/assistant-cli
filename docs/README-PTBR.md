<div align="center">

# Guia de Customização e Extensões

[English](README.md) | **Português** | [Español](README-ES.md)

<p>Aprenda a estender o <b>Assistant CLI</b> configurando as engines de IA que você utiliza, idiomas customizados, habilidades (skills) e comandos dinâmicos.</p>

</div>

## Sumário

- [Visão Geral](#visão-geral)
- [Engines Customizadas](#engines-customizadas-customengines)
  - [Contrato de Funções da Engine](#contrato-de-funções-da-engine)
  - [Passo a Passo de Criação](#passo-a-passo-de-criação)
  - [Como Ativar e Testar](#como-ativar-e-testar)
- [Idiomas Customizados](#idiomas-customizados-customlocales)
  - [Estrutura das Mensagens](#estrutura-das-mensagens)
  - [Passo a Passo de Criação](#passo-a-passo-de-criação-1)
  - [Como Ativar e Testar](#como-ativar-e-testar-1)
- [Skills Customizadas](#skills-customizadas-customskills)
  - [Convenção de Nomenclatura](#convenção-de-nomenclatura)
  - [Método 1: Criação Manual](#método-1-criação-manual)
  - [Método 2: Criação via CLI](#método-2-criação-via-cli)
  - [Como Usar uma Skill](#como-usar-uma-skill)
- [Comandos Customizados Dinâmicos](#comandos-customizados-dinâmicos-custominitsh)
  - [Como Funciona](#como-funciona)
  - [Exemplo Prático](#exemplo-prático)
- [Templates de Referência](#templates-de-referência)

## Visão Geral

O **Assistant CLI** foi projetado com uma arquitetura totalmente modular baseada no diretório `custom/`. Todos os arquivos de script shell ou diretrizes em Markdown colocados nas pastas correspondentes são recarregados e disponibilizados automaticamente sem a necessidade de recompilação ou reinstalação do assistente.

A estrutura de pastas para extensões é a seguinte:

```text
custom/
├── engines/     # Scripts shell com drivers para novos executáveis/serviços de LLM
├── locales/     # Scripts shell sobrescrevendo ou adicionando novas traduções de interface
├── skills/      # Arquivos Markdown (*-assistant.md) definindo personas e prompts do sistema
└── init.sh      # Script shell para comandos customizados dinâmicos (_cmd_<nome>)
```

## Engines Customizadas (`custom/engines/`)

Você pode integrar qualquer novo modelo, CLI ou API (ex: Kimi, APIs customizadas) criando um driver em script shell no diretório `custom/engines/`.

### Contrato de Funções da Engine

Para que o `assistant-cli` reconheça e gerencie sua engine, seu arquivo `.sh` deve implementar o prefixo `_engine_<nome_da_engine>_` nas seguintes funções:

| Função | Descrição | Requerida? |
| :--- | :--- | :---: |
| `_engine_<nome>_binary()` | Retorna o nome do executável da CLI no sistema. | **Sim** |
| `_engine_<nome>_is_installed()` | Retorna status `0` (sucesso) se a ferramenta estiver instalada no sistema. | **Sim** |
| `_engine_<nome>_list_models()` | Imprime a lista de modelos suportados (um por linha). | **Sim** |
| `_engine_<nome>_run_prompt()` | Executa um prompt em lote (uma única resposta). | **Sim** |
| `_engine_<nome>_run_interactive()` | Inicia uma sessão de chat interativa com o modelo. | **Sim** |
| `_engine_<nome>_default_model()` | Retorna o modelo padrão da engine (opcional). | *Não* |

### Passo a Passo de Criação

1. Crie um arquivo `.sh` em `custom/engines/`.
2. Utilize como base o modelo oficial disponível em [`docs/templates/engine/example.sh.template`](templates/engine/example.sh.template).
3. Substitua `<nome>` pelo identificador da sua engine (use apenas letras minúsculas, números e sublinhados).
4. Implemente cada uma das funções de acordo com a sintaxe da ferramenta CLI desejada.

### Como Ativar e Testar

Após salvar o arquivo em `custom/engines/minha_engine.sh`:

1. Verifique se a engine aparece na lista de disponíveis:
   ```bash
   assistant engine --list
   ```
2. Alterne para a nova engine:
   ```bash
   assistant engine minha_engine
   ```
3. Defina um modelo para a engine se necessário:
   ```bash
   assistant model model-a
   ```

## Idiomas Customizados (`custom/locales/`)

Você pode traduzir a interface do assistente para novos idiomas ou personalizar as mensagens existentes criando arquivos shell no diretório `custom/locales/`.

### Estrutura das Mensagens

Os arquivos de idioma sobrescrevem as funções de tradução com prefixo `t_` usadas no sistema de renderização do assistente.

| Função | Descrição |
| :--- | :--- |
| `t_lang_changed()` | Mensagem exibida ao alterar o idioma ativo. |
| `t_lang_status()` | Exibição do status e idioma atual. |
| `t_lang_not_found()` | Mensagem de erro quando um idioma não existe. |
| `t_engine_changed()` | Mensagem exibida ao trocar a engine ativa. |
| `t_engine_status()` | Exibição do status da engine e modelo ativo. |
| `t_model_changed()` | Mensagem exibida ao alterar o modelo. |
| `t_think_enabled()` | Mensagem ao ativar o modo de pensamento/raciocínio. |
| `t_think_disabled()` | Mensagem ao desativar o modo de pensamento/raciocínio. |

### Passo a Passo de Criação

1. Crie um arquivo `.sh` em `custom/locales/`.
2. Como referência, consulte o template oficial em [`docs/templates/locales/example.sh.template`](templates/locales/example.sh.template).
3. Defina apenas as funções `t_*` que você deseja traduzir ou personalizar.

### Como Ativar e Testar

1. Liste os idiomas registrados:
   ```bash
   assistant lang --list
   ```
2. Alterne para o seu idioma customizado:
   ```bash
   assistant lang fr
   ```

## Skills Customizadas (`custom/skills/`)

Skills são diretrizes em Markdown que definem comportamentos específicos, personas ou instruções pré-formatadas para o assistente executar tarefas automatizadas.

### Convenção de Nomenclatura

Os arquivos de skill no diretório `custom/skills/` devem obrigatoriamente seguir a convenção de nome:
```text
<nome_da_skill>-assistant.md
```

Por exemplo: `tradutor-assistant.md`, `revisor-assistant.md` ou `test-assistant.md`.

---

### Método 1: Criação Manual

1. Crie um arquivo `.md` em `custom/skills/` seguindo a convenção de nome:
   ```bash
   touch custom/skills/meu_tradutor-assistant.md
   ```
2. Escreva o prompt de sistema e as instruções no arquivo. Você pode usar como base o template em [`docs/templates/skills/example-assistant.md.template`](templates/skills/example-assistant.md.template).

---

### Método 2: Criação via CLI

Você pode importar um arquivo Markdown de qualquer diretório do seu sistema usando o comando `assistant create skill`:

```bash
assistant create skill tradutor /caminho/para/meu_arquivo.md
```

O assistente copiará automaticamente o arquivo para `custom/skills/tradutor-assistant.md`.

---

### Como Usar uma Skill

Assim que o arquivo da skill estiver salvo em `custom/skills/`, a skill pode ser chamada diretamente pela CLI informando o nome da skill como subcomando:

```bash
assistant tradutor "Translate this sentence into Spanish and preserve technical context"
```

---

## Comandos Customizados Dinâmicos (`custom/init.sh`)

Você pode criar comandos Bash customizados executados diretamente pela CLI definindo funções com o prefixo `_cmd_<nome>` no arquivo `custom/init.sh`.

### Como Funciona

Quando você executa `assistant <nome> [argumentos...]`, o Assistant CLI verifica se existe uma função correspondente nomeada `_cmd_<nome>` carregada a partir de `custom/init.sh`. Se a função existir, ela é invocada automaticamente repassando todos os argumentos fornecidos.

### Exemplo Prático

Edite ou adicione ao arquivo `custom/init.sh`:

```bash
# custom/init.sh

_cmd_hello() {
  echo "👋 Olá! Esta é uma função customizada e dinâmica carregada de custom/init.sh."
  if [[ -n "$1" ]]; then
    echo "Argumentos recebidos: $*"
  fi
}
```

Para executar seu comando customizado:

```bash
assistant hello "mundo"
```

---

## Templates de Referência

O repositório fornece templates para facilitar a criação de extensões no diretório `docs/templates/`:

| Categoria | Caminho do Template | Descrição |
| :--- | :--- | :--- |
| **Engine** | [`docs/templates/engine/example.sh.template`](templates/engine/example.sh.template) | Modelo base de script de engine customizada |
| **Locale** | [`docs/templates/locales/example.sh.template`](templates/locales/example.sh.template) | Modelo base de script de idioma customizado |
| **Skill** | [`docs/templates/skills/example-assistant.md.template`](templates/skills/example-assistant.md.template) | Modelo base de arquivo Markdown para skills |
