# Harnesses y skills nativas en Codex

[English](README.md) | [Português](README-PTBR.md) | **Español**

Assistant CLI coordina skills y contexto. Un adaptador traduce las llamadas a la CLI de la herramienta; un harness de agente usa herramientas del proyecto y un modelo/proveedor para ejecutar tareas. El adaptador Ollama ejecuta prompts de texto sin activar su bucle experimental de herramientas. `assistant adapters` es el comando principal; `assistant engine` y `assistant harness` son alias compatibles. Se conservan `ASSISTANT_ENGINE`, `ASSISTANT_MODEL_*`, `custom/adapters/` y las funciones `_engine_*`.

Los adaptadores personalizados se cargan solo desde `custom/adapters/*/init.sh`. `assistant custom adapters --list` lista solo extensiones personalizadas; `assistant custom engine`, `assistant custom harness` y `assistant custom engines` son alias. Las funciones `_engine_*` y las configuraciones `ASSISTANT_ENGINE`/`ASSISTANT_MODEL_*` permanecen iguales.

```bash
assistant adapters --list
assistant adapters select
assistant adapters status
assistant adapters capabilities
assistant adapters capabilities codex
assistant adapters codex
assistant custom adapters --list
```

`--list` (y `list`) imprime una tabla sin interacción, también mediante los alias `engine` y `harness`. Usa `select` para el menú interactivo. La tabla muestra el origen, la disponibilidad del ejecutable y el estado activo de cada adaptador. La selección rechaza nombres que no se han descubierto. Cuando un adaptador personalizado tiene el mismo nombre que uno integrado, el personalizado tiene prioridad y aparece una sola vez.

Las mismas operaciones están disponibles en `assistant custom adapters`: `--list`, `select`, `status`, `capabilities [name]` y `<nombre>`. Las listas, capacidades y selección se limitan a los adaptadores personalizados. `status` indica si el adaptador activo es personalizado; seleccionar aquí también cambia el único adaptador activo global.

Las capacidades describen el soporte del adaptador de Assistant, no todas las funciones de la herramienta externa ni la presencia del ejecutable. `desconocido` significa que un adaptador personalizado no declara esa capacidad.

| Adaptador | Prompt | Interactivo | Herramientas de proyecto | Lista de modelos | Respuesta final | Instalación nativa |
| --- | --- | --- | --- | --- | --- | --- |
| agy | sí | sí | sí | sí | sí | no |
| codex | sí | sí | sí | no | sí | sí |
| copilot | sí | sí | sí | no | sí | no |
| ollama | sí | sí | no | sí | sí | no |
| opencode | sí | sí | sí | sí | sí | no |

La ejecución de prompts entrega solo la respuesta final en stdout o en el archivo solicitado. Los diagnósticos y el progreso usan stderr. Se conservan los códigos de error del ejecutor; las respuestas finales vacías o malformadas fallan. El destino no se trunca cuando falla el ejecutor. La publicación no es una transacción atómica del sistema de archivos. Los adaptadores personalizados siguen siendo responsables de separar sus logs de la respuesta.

Codex usa `exec --output-last-message`; Copilot usa `-p --silent`; AGY usa modo print/text; Ollama oculta el razonamiento al generar documentos. OpenCode usa eventos JSON internamente y requiere `jq` para extraer la última etapa de respuesta. Si falta `jq`, falla antes de la inferencia; la salida pública es texto. Se conserva el fallback de los adaptadores personalizados existentes. Los mensajes explícitos usan modo prompt; `assistant` sin mensaje abre la CLI interactiva.

El filtro de respuesta de OpenCode está junto a su adaptador en `lib/adapters/opencode/result.jq`.

### Instalar en Codex

Elige explícitamente destino y alcance. La gestión de la instalación nativa no invoca Codex ni llama a modelos:

```bash
assistant skills install commit --harness codex --scope project --dry-run
assistant skills install commit --harness codex --scope project
assistant skills verify commit --harness codex --scope project
assistant skills remove commit --harness codex --scope project --dry-run
assistant skills remove commit --harness codex --scope project

assistant skills install readme --harness codex --scope user --dry-run
assistant skills install readme --harness codex --scope user
```

El alcance de proyecto escribe en `<proyecto>/.agents/skills/<nombre>/`. Por defecto se usa la raíz Git o el directorio actual fuera de Git; `--project <directorio-existente>` selecciona otro proyecto. El alcance de usuario escribe en `~/.agents/skills/<nombre>/` y no acepta `--project`. `CODEX_HOME` no redirige esta ubicación documentada. Las vistas previas pueden usar archivos temporales, pero no cambian el destino.

El `SKILL.md` efectivo se exporta sin cambios. Las instrucciones nativas son autónomas: reutilizan el contexto suministrado y recopilan los datos Git o del proyecto que falten cuando el harness ofrece herramientas. Las skills de README y resúmenes distinguen respuestas puras capturadas por el programa que las invoca de la creación directa de archivos. No se instala ni ejecuta ningún complemento de contexto, handler de Assistant o script del paquete. Las sustituciones personalizadas también se exportan sin cambios y deben incluir sus propias instrucciones completas; los handlers locales siguen recopilando contexto para ellas. No se copian assets arbitrarios ni referencias relativas de paquetes en este piloto.

Cada instalación contiene `SKILL.md`, `.assistant-install.tsv` y `.assistant-install.sha256`. El registro guarda ruta de origen, revisión Git cuando está rastreada (o `unversioned`), SHA-256 del origen, SHA-256 del contenido adaptado y versión del renderizador. Un origen rastreado modificado recibe `:modified`. SHA-256 usa `sha256sum` o `shasum`; si faltan ambos, la operación devuelve un error claro. El registro se lee como datos y nunca como código shell.

La instalación rechaza destinos existentes, identidades declaradas duplicadas dentro del directorio de destino y enlaces simbólicos en rutas administradas. No mezcla ni sobrescribe. La eliminación valida registros y hashes y rechaza archivos editados, registros editados, enlaces simbólicos o archivos adicionales. Solo elimina sus tres archivos y la carpeta vacía de la skill; conserva el directorio compartido de skills. Los errores de archivo se informan y pueden requerir inspeccionar un destino parcialmente creado.

`verify` valida metadatos, contenido, registro y ubicación en la ruta documentada de descubrimiento. No demuestra que una sesión abierta de Codex ya haya cargado la skill; reinicia Codex si no aparece. Los conflictos en otros alcances, directorios de proyectos antecesores, skills de sistema o sesiones activas quedan fuera de la comprobación local. Se verificaron las fuentes oficiales de [descubrimiento de skills](https://developers.openai.com/codex/skills) y [salida final de Codex](https://developers.openai.com/codex/noninteractive).

### Probar sin inferencia

```bash
bash tests/smoke.sh
bash tests/harness.sh
zsh tests/harness.sh
shellcheck -S error init.sh lib/*.sh lib/adapters/*/init.sh utils/*.sh skills/*/init.sh locales/*.sh install.sh tests/*.sh
```

La suite copia el código a una carpeta temporal, simula ejecutores y redirige las escrituras de usuario solo dentro de la prueba. No cambia `HOME` ni instala skills en la cuenta real. La validación de Fish requiere Fish instalado. La inferencia real y la compatibilidad con versiones específicas de todas las CLIs externas no están cubiertas por las pruebas simuladas.
