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

A instalação rejeita destino existente, identidades declaradas duplicadas no diretório de skills de destino e links simbólicos em caminhos gerenciados. Não mescla nem sobrescreve. A remoção valida os registros e hashes e recusa arquivos editados, registros editados, links simbólicos ou arquivos adicionais. Apaga somente os três arquivos próprios e a pasta vazia de cada instalação ou backup gerenciado; preserva o diretório compartilhado de skills. Uma falha de operação de arquivo é informada e pode exigir inspeção de um destino parcialmente criado.

`verify` valida metadados, conteúdo, registro de origem e localização no caminho documentado de descoberta. Não comprova que uma sessão aberta do Codex já carregou a skill; reinicie o Codex se ela não aparecer. Consulte as documentações oficiais de [descoberta de skills](https://learn.chatgpt.com/docs/build-skills#where-codex-loads-local-skills) e [saída final do Codex](https://developers.openai.com/codex/noninteractive).

### Atualização gerenciada e diagnóstico

```bash
assistant skills installed --harness codex
assistant skills status commit --harness codex
assistant skills diff commit --harness codex --scope project
assistant skills update commit --harness codex --scope project --dry-run
assistant skills update commit --harness codex --scope project
assistant skills restore commit --harness codex --scope project --dry-run
assistant skills restore commit --harness codex --scope project
```

O gerenciamento nativo compara o conteúdo da origem sem exigir um campo de versão no SKILL.md. A revisão Git registrada identifica a origem; uma revisão diferente do repositório, por si só, não indica atualização da skill. Os comandos não invocam o Codex nem fazem inferência.

Use `installed` para listar os pacotes nativos e `status` para inspecionar um nome específico. Esses comandos mostram origem, revisão instalada, alterações locais, atualização disponível, estado do backup e destino. O `status` de um nome também compara as revisões e os SHA-256 da origem registrada e atual. Exigem `--harness codex`; `--scope` usa all por padrão e também aceita project ou user. `assistant skills list` continua listando o registro de origens do Assistant.

As tabelas abreviam caminhos no meio e exibem revisões Git com 12 caracteres, preservando o sufixo de modificação. Em terminais com menos de 160 colunas, resumo e caminhos aparecem em tabelas separadas. Os detalhes de `status` para um nome mantêm os caminhos, revisões e hashes completos.

`update` acompanha o caminho absoluto da origem registrada na instalação. Uma substituição customizada efetiva gera aviso e não troca essa origem. Se a origem registrada estiver ausente, inválida, ligada por link simbólico ou mudar durante a preparação, a atualização falha sem substituir a instalação. Uma mudança de conteúdo indica atualização disponível. `diff` e `update --dry-run` exibem diferenças unificadas; a atualização efetiva também exibe o `diff`. `diff` permite inspecionar instruções editadas localmente quando o registro de origem é válido. Comandos de leitura não aceitam `--dry-run`.

`update` recusa conteúdo editado localmente, registros editados, arquivos adicionais, links simbólicos, registros não suportados e duplicidades no mesmo diretório de skills. O `diff` do conteúdo é exibido antes de informar as edições locais. Não há substituição forçada nem mesclagem automática. As prévias não alteram o destino ou o backup. Todos os comandos de escrita exigem escopo explícito project ou user.

Cada atualização bem-sucedida guarda uma instalação gerenciada anterior, incluindo seu registro de origem, em `.agents/.assistant-skill-backups/codex/<nome>/` ao lado do diretório skills. Backups não são skills nativas nem entram na descoberta de instalações. Uma atualização seguinte substitui esse espaço somente quando o backup existente é válido. `restore` troca a instalação atual pela versão anterior, permitindo também desfazer a restauração com o mesmo espaço. Não depende da origem original. Edições na instalação atual ou no backup bloqueiam a restauração. `remove` apaga o backup próprio válido junto com a instalação; backups editados são preservados e bloqueiam a remoção.

A descoberta inspeciona o diretório de trabalho selecionado, seus ancestrais até a raiz do repositório Git e o diretório de skills do usuário. Fora de Git, somente o diretório selecionado e o diretório do usuário são inspecionados. `--project` escolhe o ponto inicial da descoberta em `installed/status`. Nomes repetidos entre diretórios de usuário/projeto/ancestrais geram avisos e não bloqueiam alterações. Duas pastas que declaram o mesmo nome dentro de um diretório de skills bloqueiam instalação, atualização, restauração e `verify`; a listagem mostra ambas e retorna erro. Pacotes não gerenciados ou danificados permanecem visíveis. O diagnóstico não cobre pacotes administrativos/de sistema, ativação em sessão nem configurações de skills desabilitadas.

Escritas usam um bloqueio por skill em `.agents/.assistant-skill-locks/`. Uma operação concorrente falha com mensagem clara. A substituição prepara e valida os arquivos no mesmo sistema de arquivos e move diretórios, tentando reverter uma falha de movimentação detectada. Não é uma transação atômica entre instalação e backup. Uma interrupção pode deixar um bloqueio ou diretório `.assistant-skill-transaction.*`; inspecione esses caminhos antes da recuperação manual. Se a reversão automática falhar, o caminho de recuperação é informado e preservado.

### Testar sem inferência

```bash
bash tests/smoke.sh
bash tests/harness.sh
zsh tests/harness.sh
bash tests/skill-update.sh
zsh tests/skill-update.sh
shellcheck -S error init.sh lib/*.sh lib/adapters/*/init.sh utils/*.sh skills/*/init.sh locales/*.sh install.sh tests/*.sh
```

A suíte de harnesses copia o código para uma pasta temporária, simula os executores e redireciona as escritas do escopo de usuário apenas dentro do teste. Não altera `HOME` nem instala skills na conta real. A validação de Fish depende de sua instalação. Inferência real e compatibilidade com versões específicas de todas as CLIs externas não são cobertas pelos testes simulados.
