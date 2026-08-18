<div align="center">

# Guía de Personalización y Extensiones

[English](CUSTOMIZATION.md) | [Português](CUSTOMIZATION-PTBR.md) | **Español**

<p>Aprende a extender el <b>Assistant CLI</b> configurando los motores de IA que utilizas, idiomas personalizados, habilidades (skills) y comandos dinámicos.</p>

</div>

## Índice

- [Visión General](#visión-general)
- [Motores Personalizados](#motores-personalizados-customengines)
  - [Contrato de Funciones del Motor](#contrato-de-funciones-del-motor)
  - [Paso a Paso de Creación](#paso-a-paso-de-creación)
  - [Cómo Activar y Probar](#cómo-activar-y-probar)
- [Idiomas Personalizados](#idiomas-personalizados-customlocales)
  - [Estructura de las Mensajes](#estructura-de-las-mensajes)
  - [Paso a Paso de Creación](#paso-a-paso-de-creación-1)
  - [Cómo Activar y Probar](#cómo-activar-y-probar-1)
- [Skills Personalizadas](#skills-personalizadas-customskills)
  - [Convención de Nombres](#convención-de-nombres)
  - [Método 1: Creación Manual](#método-1-creación-manual)
  - [Método 2: Creación mediante CLI](#método-2-creación-mediante-cli)
  - [Cómo Usar una Skill](#cómo-usar-una-skill)
- [Comandos Personalizados Dinámicos](#comandos-personalizados-dinámicos-custominitsh)
  - [Cómo Funciona](#cómo-funciona)
  - [Ejemplo Práctico](#ejemplo-práctico)
- [Plantillas de Referencia](#plantillas-de-referencia)

## Visión General

El **Assistant CLI** está diseñado con una arquitectura completamente modular basada en el directorio `custom/`. Todos los archivos de script de shell o directivas en Markdown ubicados en las carpetas correspondientes se recargan y quedan disponibles automáticamente sin necesidad de recompilar o reinstalar el asistente.

La estructura de carpetas para extensiones es la siguiente:

```text
custom/
├── engines/     # Scripts de shell con controladores para nuevos ejecutables/servicios de LLM
├── locales/     # Scripts de shell que sobrescriben o agregan traducciones de interfaz
├── skills/      # Archivos Markdown (*-assistant.md) que definen personas y prompts del sistema
└── init.sh      # Script de shell para comandos personalizados dinámicos (_cmd_<nombre>)
```

## Motores Personalizados (`custom/engines/`)

Puedes integrar cualquier nuevo modelo, CLI o API (ej: Kimi, APIs personalizadas) creando un controlador en script de shell en el directorio `custom/engines/`.

### Contrato de Funciones del Motor

Para que `assistant-cli` reconozca y gestione tu motor, tu archivo `.sh` debe implementar el prefijo `_engine_<nombre_del_motor>_` en las siguientes funciones:

| Función | Descripción | ¿Requerida? |
| :--- | :--- | :---: |
| `_engine_<nombre>_binary()` | Devuelve el nombre del ejecutable de la CLI en el sistema. | **Sí** |
| `_engine_<nombre>_is_installed()` | Devuelve el código de estado `0` (éxito) si la herramienta está instalada. | **Sí** |
| `_engine_<nombre>_list_models()` | Imprime la lista de modelos soportados (uno por línea). | *No* |
| `_engine_<nombre>_run_prompt()` | Ejecuta un prompt en lote (una sola respuesta). | **Sí** |
| `_engine_<nombre>_run_interactive()` | Inicia una sesión de chat interactiva con el modelo. | **Sí** |
| `_engine_<nombre>_default_model()` | Devuelve el modelo por defecto del motor (opcional). | *No* |

### Paso a Paso de Creación

1. Crea un archivo `.sh` en `custom/engines/`.
2. Utiliza como base la plantilla oficial disponible en [`docs/templates/engine/example.sh.template`](templates/engine/example.sh.template).
3. Reemplaza `<nombre>` por el identificador de tu motor (usa solo letras minúsculas, números y guiones bajos).
4. Implementa cada una de las funciones según la sintaxis de la CLI deseada.

### Cómo Activar y Probar

Después de guardar el archivo en `custom/engines/mi_motor.sh`:

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
2. Como referencia, consulta la plantilla oficial en [`docs/templates/locales/example.sh.template`](templates/locales/example.sh.template).
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

Las skills son directivas en Markdown que definen comportamientos específicos, personas o instrucciones preformateadas para que el asistente ejecute tareas automatizadas.

### Convención de Nombres

Los archivos de skill en el directorio `custom/skills/` deben seguir estrictamente la convención de nombres:
```text
<nombre_de_la_skill>-assistant.md
```

Por ejemplo: `traductor-assistant.md`, `revisor-assistant.md` o `test-assistant.md`.

---

### Método 1: Creación Manual

1. Crea un archivo `.md` en `custom/skills/` siguiendo la convención de nombres:
   ```bash
   touch custom/skills/mi_traductor-assistant.md
   ```
2. Escribe las instrucciones y el prompt del sistema. Puedes usar como base la plantilla en [`docs/templates/skills/example-assistant.md.template`](templates/skills/example-assistant.md.template).

---

### Método 2: Creación mediante CLI

Puedes importar un archivo Markdown desde cualquier directorio de tu sistema usando `assistant create skill`:

```bash
assistant create skill traductor /ruta/a/mi_archivo.md
```

El asistente copiará automáticamente el archivo a `custom/skills/traductor-assistant.md`.

---

### Cómo Usar una Skill

Una vez guardada en `custom/skills/`, puedes invocar la skill directamente pasando su nombre como subcomando:

```bash
assistant traductor "Translate this sentence into Spanish and preserve technical context"
```

---

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
| **Motor** | [`docs/templates/engine/example.sh.template`](templates/engine/example.sh.template) | Plantilla base para controladores de motores personalizados |
| **Idioma** | [`docs/templates/locales/example.sh.template`](templates/locales/example.sh.template) | Plantilla base para archivos de idioma personalizados |
| **Skill** | [`docs/templates/skills/example-assistant.md.template`](templates/skills/example-assistant.md.template) | Plantilla base para archivos Markdown de skills |
