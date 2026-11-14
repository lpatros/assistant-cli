# Harnesses e skills nativas no Codex

[English](README.md) | **Português** | [Español](README-ES.md)

O Assistant CLI coordena skills e contexto. Um adaptador traduz as chamadas para a CLI da ferramenta; um harness de agente usa ferramentas do projeto e um modelo/provedor para executar tarefas. O adaptador Ollama executa prompts de texto sem ativar seu loop experimental de ferramentas. `assistant adapters` é o comando principal; `assistant engine` e `assistant harness` são aliases compatíveis. As configurações `ASSISTANT_ENGINE`, `ASSISTANT_MODEL_*`, a pasta `custom/adapters/` e as funções `_engine_*` são preservadas.

Adaptadores customizados são carregados apenas de `custom/adapters/*/init.sh`. `assistant custom adapters --list` lista apenas extensões customizadas; `assistant custom engine`, `assistant custom harness` e `assistant custom engines` são aliases. As funções `_engine_*` e as configurações `ASSISTANT_ENGINE`/`ASSISTANT_MODEL_*` continuam iguais.

```bash
assistant adapters --list
assistant adapters select
assistant adapters status
assistant adapters capabilities
assistant adapters capabilities codex
assistant adapters codex
assistant custom adapters --list
```

`--list` (e `list`) imprime uma tabela sem interação, inclusive pelos aliases `engine` e `harness`. Use `select` para o menu interativo. A tabela mostra a origem, a disponibilidade do executável e o estado ativo de cada adaptador. A seleção rejeita nomes que não foram descobertos. Quando um adaptador customizado tem o mesmo nome de um nativo, o customizado prevalece e aparece uma única vez.

As mesmas operações estão disponíveis em `assistant custom adapters`: `--list`, `select`, `status`, `capabilities [name]` e `<nome>`. Listas, capacidades e seleção ficam restritas aos adaptadores customizados. `status` informa se o adaptador ativo é customizado; a seleção nesse ramo também altera o único adaptador ativo global.

As capacidades descrevem o suporte do adaptador do Assistant, não todos os recursos da ferramenta externa nem a presença do executável. `desconhecido` significa que um adaptador customizado não declara aquela capacidade.

| Adaptador | Prompt | Interativo | Ferramentas de projeto | Lista de modelos | Resposta final | Instalação nativa |
| --- | --- | --- | --- | --- | --- | --- |
| agy | sim | sim | sim | sim | sim | não |
| codex | sim | sim | sim | não | sim | sim |
| copilot | sim | sim | sim | não | sim | não |
| ollama | sim | sim | não | sim | sim | não |
| opencode | sim | sim | sim | sim | sim | não |

A execução de prompts entrega apenas a resposta final em stdout ou no arquivo solicitado. Diagnósticos e progresso usam stderr. Códigos de falha do executor são preservados; respostas finais vazias ou malformadas falham. O destino não é truncado quando o executor falha. A publicação em si não é uma transação atômica de sistema de arquivos. Adaptadores customizados continuam responsáveis por separar seus próprios logs da resposta.

Codex usa `exec --output-last-message`; Copilot usa `-p --silent`; AGY usa modo print/text; Ollama oculta o raciocínio ao gerar documentos. OpenCode usa eventos JSON internamente e requer `jq` para extrair a última etapa de resposta. A ausência de `jq` causa erro antes da inferência; a saída pública é texto. Adaptadores customizados existentes preservam o fallback de prompt e interação. Mensagens explícitas usam modo prompt; `assistant` sem mensagem abre a CLI interativa.

O filtro de resposta do OpenCode fica junto de seu adaptador em `lib/adapters/opencode/result.jq`.

### Instalar no Codex

Escolha explicitamente o destino e o escopo. O gerenciamento da instalação nativa não invoca o Codex nem faz chamadas a modelos:

```bash
assistant skills install commit --harness codex --scope project --dry-run
assistant skills install commit --harness codex --scope project
assistant skills verify commit --harness codex --scope project
assistant skills remove commit --harness codex --scope project --dry-run
assistant skills remove commit --harness codex --scope project

assistant skills install readme --harness codex --scope user --dry-run
assistant skills install readme --harness codex --scope user
```

O escopo de projeto grava em `<projeto>/.agents/skills/<nome>/`. Por padrão, o projeto é a raiz Git ou o diretório atual fora de um repositório; `--project <diretório-existente>` escolhe outro projeto. O escopo de usuário grava em `~/.agents/skills/<nome>/` e não aceita `--project`. `CODEX_HOME` não redireciona essa localização documentada de skills do usuário. As prévias podem usar arquivos temporários, mas não alteram o destino.

O `SKILL.md` efetivo é exportado sem alterações. As instruções nativas são autocontidas: reutilizam o contexto fornecido e coletam dados Git ou do projeto que faltarem quando o harness oferecer ferramentas. As skills de README e resumos distinguem respostas puras capturadas pelo chamador da criação direta de arquivos. Nenhum complemento de contexto, handler do Assistant ou script do pacote é instalado ou executado. Substituições customizadas também são exportadas sem alterações e devem conter suas próprias instruções completas; os handlers locais do Assistant continuam coletando contexto para essas substituições. Assets arbitrários e referências relativas dos pacotes não são copiados neste piloto.

Cada instalação contém `SKILL.md`, `.assistant-install.tsv` e `.assistant-install.sha256`. O registro guarda caminho da origem, revisão Git quando rastreada (ou `unversioned`), SHA-256 da origem, SHA-256 do conteúdo adaptado e versão do renderizador. Uma origem rastreada modificada recebe `:modified`. O SHA-256 usa `sha256sum` ou `shasum`; se ambos faltarem, a operação retorna erro claro. O registro é lido como dados, nunca como código shell.

A instalação rejeita destino existente, identidades declaradas duplicadas no diretório de skills de destino e links simbólicos em caminhos gerenciados. Não mescla nem sobrescreve. A remoção valida os registros e hashes e recusa arquivos editados, registros editados, links simbólicos ou arquivos adicionais. Apaga apenas os três arquivos próprios e a pasta vazia da skill; preserva o diretório compartilhado de skills. Uma falha de operação de arquivo é informada e pode exigir inspeção de um destino parcialmente criado.

`verify` valida metadados, conteúdo, registro de origem e localização no caminho documentado de descoberta. Não comprova que uma sessão aberta do Codex já carregou a skill; reinicie o Codex se ela não aparecer. Conflitos em outros escopos, diretórios de projetos ancestrais, skills de sistema ou sessão em execução ficam fora da checagem local do destino. Foram verificadas as documentações oficiais de [descoberta de skills](https://developers.openai.com/codex/skills) e [saída final do Codex](https://developers.openai.com/codex/noninteractive).

### Testar sem inferência

```bash
bash tests/smoke.sh
bash tests/harness.sh
zsh tests/harness.sh
shellcheck -S error init.sh lib/*.sh lib/adapters/*/init.sh utils/*.sh skills/*/init.sh locales/*.sh install.sh tests/*.sh
```

A suíte de harnesses copia o código para uma pasta temporária, simula os executores e redireciona as escritas do escopo de usuário apenas dentro do teste. Não altera `HOME` nem instala skills na conta real. A validação de Fish depende de sua instalação. Inferência real e compatibilidade com versões específicas de todas as CLIs externas não são cobertas pelos testes simulados.
