<div align="center">

# Guía de Personalización y Extensiones

[English](README.md) | [Português](README-PTBR.md) | **Español**

<p>Aprende a extender el <b>Assistant CLI</b> configurando los motores de IA que utilizas, idiomas personalizados, habilidades (skills) y comandos dinámicos.</p>

</div>

## Índice

- [Visión General](#visión-general)
- [Adaptadores Personalizados](#adaptadores-personalizados-customadapters)
  - [Contrato de Funciones del Adaptador](#contrato-de-funciones-del-adaptador)
  - [Paso a Paso de Creación](#paso-a-paso-de-creación)
  - [Cómo Activar y Probar](#cómo-activar-y-probar)
- [Idiomas Personalizados](#idiomas-personalizados-customlocales)
  - [Estructura de las Mensajes](#estructura-de-las-mensajes)
  - [Paso a Paso de Creación](#paso-a-paso-de-creación-1)
  - [Cómo Activar y Probar](#cómo-activar-y-probar-1)
- [Skills Personalizadas](#skills-personalizadas-customskills)
- [Comandos Personalizados Dinámicos](#comandos-personalizados-dinámicos-custominitsh)
  - [Cómo Funciona](#cómo-funciona)
  - [Ejemplo Práctico](#ejemplo-práctico)
- [Plantillas de Referencia](#plantillas-de-referencia)

## Visión General

El **Assistant CLI** está diseñado con una arquitectura completamente modular basada en el directorio `custom/`. Todos los archivos de script de shell o directivas en Markdown ubicados en las carpetas correspondientes se recargan y quedan disponibles automáticamente sin necesidad de recompilar o reinstalar el asistente.

La estructura de carpetas para extensiones es la siguiente:

```text
custom/
├── adapters/   # Scripts de shell con controladores para nuevos ejecutables/servicios de LLM
├── locales/    # Scripts de shell que sobrescriben o agregan traducciones de interfaz
├── skills/     # Paquetes Markdown (<nombre>/SKILL.md) que definen personas y prompts del sistema
└── init.sh     # Script de shell para comandos personalizados dinámicos (_cmd_<nombre>)
```

## Adaptadores Personalizados (`custom/adapters/`)

Puedes integrar cualquier nuevo modelo, CLI o API (ej: Kimi, APIs personalizadas) creando un controlador en script de shell en el directorio `custom/adapters/`.

Los adaptadores personalizados se cargan solo desde `custom/adapters/*/init.sh`; mueve las extensiones existentes a ese directorio. La ubicación antigua `custom/engines/` ya no se consulta. `assistant custom adapters` lista las extensiones; `assistant custom engines` sigue siendo un alias de comando. Las funciones `_engine_*` y las configuraciones `ASSISTANT_ENGINE`/`ASSISTANT_MODEL_*` permanecen iguales.

Solo se descubre y carga `<nombre>/init.sh`. Guarda helpers, filtros y assets en la misma carpeta y cárgalos explícitamente desde el adaptador cuando sea necesario. Los archivos `.sh` directamente en `lib/adapters/` o `custom/adapters/` se ignoran.

### Contrato de Funciones del Adaptador

Para que `assistant-cli` reconozca y gestione tu motor, tu archivo `.sh` debe implementar el prefijo `_engine_<nombre_del_motor>_` en las siguientes funciones:

| Función | Descripción | ¿Requerida? |
| :--- | :--- | :---: |
| `_engine_<nombre>_binary()` | Devuelve el nombre del ejecutable de la CLI en el sistema. | **Sí** |
| `_engine_<nombre>_is_installed()` | Devuelve el código de estado `0` (éxito) si la herramienta está instalada. | **Sí** |
| `_engine_<nombre>_list_models()` | Imprime la lista de modelos soportados (uno por línea). | *No* |
| `_engine_<nombre>_run_prompt()` | Ejecuta un prompt en lote (una sola respuesta). | **Sí** |
| `_engine_<nombre>_run_interactive()` | Inicia una sesión de chat interactiva con el modelo. | **Sí** |
| `_engine_<nombre>_default_model()` | Devuelve el modelo por defecto del motor (opcional). | *No* |

### Capacidades opcionales del adaptador

El hook `_engine_<nombre>_capabilities()` imprime un token de soporte por línea: `prompt`, `interactive`, `workspace_tools`, `model_list`, `final_output`, `native_skills`. La declaración es completa: los tokens omitidos significan ausencia de soporte. Sin el hook, se conserva la ejecución de prompts e interacción, se deshabilita la instalación nativa y las demás capacidades quedan desconocidas.

Los hooks de prompt deben emitir solo texto final, mantener los diagnósticos en stderr y devolver el código del ejecutor. `_harness_capture_text <nombre> <archivo_salida> <comando> [args...]` almacena temporalmente la salida de un modo de la CLI que ya emite solo la respuesta final; no elimina logs de un flujo arbitrario. Rechaza respuestas vacías y publica solo tras el éxito. Los adaptadores de instalación nativa implementan también `_engine_<nombre>_skill_root <alcance> <proyecto>` (ruta absoluta de descubrimiento) y `_engine_<nombre>_render_skill <nombre> <archivo_origen>` (SKILL.md adaptado válido en stdout). Solo el adaptador Codex ofrece instalación nativa en esta versión.


### Paso a Paso de Creación

1. Crea `custom/adapters/<nombre>/init.sh`; el nombre de la carpeta es el identificador del adaptador.
2. Utiliza como base la plantilla oficial disponible en [`docs/templates/adapters/init.sh.template`](../templates/adapters/init.sh.template).
3. Reemplaza `<nombre>` por el identificador de tu motor (usa solo letras minúsculas, números y guiones bajos).
4. Implementa cada una de las funciones según la sintaxis de la CLI deseada.

### Cómo Activar y Probar

Después de guardar el archivo en `custom/adapters/mi_motor/init.sh`:

1. Comprueba si el motor aparece en la lista de disponibles:
   ```bash
   assistant engine --list
   ```
2. Cambia al nuevo motor:
   ```bash
   assistant engine mi_motor
   ```
3. Configura un modelo para el motor si es necesario:
   ```bash
   assistant model model-a
   ```

## Idiomas Personalizados (`custom/locales/`)

Puedes traducir la interfaz del asistente a nuevos idiomas o personalizar los mensajes existentes creando archivos de shell en el directorio `custom/locales/`.

### Estructura de las Mensajes

Los archivos de idioma sobrescriben las funciones de traducción con el prefijo `t_` utilizadas en el sistema de renderizado del asistente.

| Función | Descripción |
| :--- | :--- |
| `t_lang_changed()` | Mensaje mostrado al cambiar el idioma activo. |
| `t_lang_status()` | Muestra el estado e idioma activo actual. |
| `t_lang_not_found()` | Mensaje de error cuando un idioma no existe. |
| `t_engine_changed()` | Mensaje mostrado al cambiar de motor activo. |
| `t_engine_status()` | Muestra el estado del motor y el modelo activo. |
| `t_model_changed()` | Mensaje mostrado al cambiar de modelo. |
| `t_think_enabled()` | Mensaje al activar el modo de razonamiento/pensamiento. |
| `t_think_disabled()` | Mensaje al desactivar el modo de razonamiento/pensamiento. |

### Paso a Paso de Creación

1. Crea un archivo `.sh` en `custom/locales/`.
2. Como referencia, consulta la plantilla oficial en [`docs/templates/locales/example.sh.template`](../templates/locales/example.sh.template).
3. Define únicamente las funciones `t_*` que desees traducir o personalizar.

### Cómo Activar y Probar

1. Lista los idiomas registrados:
   ```bash
   assistant lang --list
   ```
2. Cambia a tu idioma personalizado:
   ```bash
   assistant lang fr
   ```

## Skills Personalizadas (`custom/skills/`)

Las skills usan `skills/<nombre>/SKILL.md` (nativas) o `custom/skills/<nombre>/SKILL.md` (personalizadas). Solo se descubre este formato; los archivos antiguos `*-assistant.md` no se admiten.

```markdown
---
name: traductor
description: Traduce textos conservando el contexto técnico.
---
Translate the user input into the requested language.
```

`name` y `description` son obligatorios. El nombre debe coincidir con la carpeta y usar minúsculas, números, guiones bajos o guiones, comenzando con letra o número. El frontmatter admite solo estos dos campos escalares de una línea, opcionalmente entre comillas coincidentes. No se admiten escapes, valores multilínea, comentarios al final de línea ni otras construcciones YAML. Usa comillas si la descripción contiene dos puntos seguidos de espacio. Los metadatos se leen como datos y se excluyen del prompt.

```bash
assistant skills list
assistant create skill traductor /ruta/a/SKILL.md
assistant traductor "Traduce este texto al español"
```

La importación valida los metadatos y copia el archivo a `custom/skills/traductor/SKILL.md`. Se rechazan destinos existentes e identidades duplicadas. Importar instrucciones para una skill nativa pide confirmación. Las instrucciones personalizadas tienen prioridad y conservan el handler nativo, la recopilación de contexto, los argumentos y el tratamiento de salida.

El descubrimiento lee solo archivos inmediatos `<nombre>/SKILL.md` y nunca ejecuta scripts de paquetes. Las nuevas skills compuestas solo por Markdown no requieren cambios en `init.sh`. Los handlers nativos existentes siguen siendo código confiable de inicialización; no se ejecutan `init.sh` ni `scripts/` de paquetes personalizados. Los comandos dinámicos en `custom/init.sh` siguen siendo un mecanismo separado de extensión confiable.

`assistant skills list` muestra nombre, origen, formato, estado, ruta y descripción, incluidas definiciones sustituidas y entradas inválidas. Los metadatos inválidos, nombres distintos de la carpeta y nombres duplicados dentro de un origen bloquean la skill afectada y hacen que el listado devuelva error. Una sustitución personalizada inválida nunca recurre silenciosamente a la definición nativa. Los nombres declarados duplicados se detectan incluso en carpetas distintas. Otras skills válidas siguen disponibles.

Los comandos administrativos y sus alias están reservados: `create`, `skills`, `model`, `engine`, `harness`, `think`, `lang`, `custom`, `status`, `update`, `channel`, `changelog`, `version`, `--version`, `-v`, `help`, `--help`, `-h`, `--think`, `--no-think`, `--hide-think`. Las skills no pueden interceptarlos. El orden es: comandos administrativos, skills validadas (instrucciones personalizadas antes que nativas), comandos dinámicos personalizados y prompts directos.

Para migrar una skill antigua, mueve sus instrucciones a `custom/skills/<nombre>/SKILL.md` y agrega el frontmatter obligatorio. Se ignora el nombre antiguo. Usa [SKILL.md.template](../templates/skills/SKILL.md.template) como referencia.


## Comandos Personalizados Dinámicos (`custom/init.sh`)

Puedes crear comandos Bash personalizados ejecutados directamente por la CLI definiendo funciones con el prefijo `_cmd_<nombre>` en el archivo `custom/init.sh`.

### Cómo Funciona

Cuando ejecutas `assistant <nombre> [argumentos...]`, Assistant CLI verifica si existe una función correspondiente llamada `_cmd_<nombre>` cargada desde `custom/init.sh`. Si la función existe, se invoca automáticamente pasando todos los argumentos proporcionados.

### Ejemplo Práctico

Edita o añade al archivo `custom/init.sh`:

```bash
# custom/init.sh

_cmd_hello() {
  echo "👋 ¡Hola! Esta es una función personalizada y dinámica cargada desde custom/init.sh."
  if [[ -n "$1" ]]; then
    echo "Argumentos recibidos: $*"
  fi
}
```

Para ejecutar tu comando personalizado:

```bash
assistant hello "mundo"
```

---

## Plantillas de Referencia

El repositorio incluye plantillas para facilitar la creación de extensiones en el directorio `docs/templates/`:

| Categoría | Ruta de la Plantilla | Descripción |
| :--- | :--- | :--- |
| **Motor** | [`docs/templates/adapters/init.sh.template`](../templates/adapters/init.sh.template) | Plantilla base para controladores de motores personalizados |
| **Idioma** | [`docs/templates/locales/example.sh.template`](../templates/locales/example.sh.template) | Plantilla base para archivos de idioma personalizados |
| **Skill** | [`docs/templates/skills/SKILL.md.template`](../templates/skills/SKILL.md.template) | Plantilla base para archivos Markdown de skills |

## Harnesses y skills nativas en Codex

[Harnesses y skills nativas en Codex](../harnesses/README-ES.md).
