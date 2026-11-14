<div align="center">

# Assistant CLI

[English](README.md) | [Português](README-PTBR.md) | **Español**

  <p>Una envoltura (wrapper) de terminal ligera, modular y localizada para Antigravity (agy), Codex, Copilot, Ollama, OpenCode y Custom Adapters, con soporte para chat interactivo, análisis de repositorios, generación de README, resúmenes de proyectos y más.</p>
    <div style="margin-bottom: 10px">
    <img src="https://img.shields.io/badge/Language-Shell-orange.svg"/>
    </div>
    <br>
</div>

# Enlaces Rápidos

- [Descripción](#descripción)
- [Instalación y Configuración](#instalación-y-configuración)
- [Actualización y Versión](#actualización-y-versión)
- [Características](#características)
- [Uso](#uso)
- [Estructura del Proyecto](#estructura-del-proyecto)
- [Licencia](#licencia)

## Descripción

El **Assistant CLI** (`assistant`) es una interfaz de línea de comandos (CLI) potente y ligera escrita en Bash. Permite a los usuarios interactuar con Modelos de Lenguaje Grande (LLMs) locales o en la nube organizados a través de **Antigravity**, **Codex**, **Copilot**, **Ollama**, **OpenCode** o **Adaptadores Personalizados** (`custom/adapters/`) directamente desde la terminal.

Todas las opciones de configuración (como el motor activo, los modelos guardados por motor, el idioma y el modo de pensamiento) se guardan localmente y persisten entre sesiones de terminal.

## Instalación y Configuración

El Assistant CLI proporciona scripts de instalación adaptados a diferentes sistemas operativos.

### Linux y macOS

Puedes instalar Assistant CLI directamente usando `curl`:

```bash
curl -fsSL https://raw.githubusercontent.com/lpatros/assistant-cli/main/install.sh | bash
```

**En Linux y macOS, el instalador interactivo:**
1. Clonará el repositorio en `~/.config/assistant-cli` (or un directorio personalizado de tu elección).
2. Agregará automáticamente la configuración a tu perfil de shell (`~/.zshrc`, `~/.bashrc` o `config.fish`).
3. Te guiará sobre cómo recargar tu terminal para comenzar a usar el asistente.

### Windows

#### PowerShell

Para usuarios de **Windows** usando PowerShell, puedes instalarlo ejecutando:

> [!IMPORTANT]
> Asegúrate de que la política de ejecución de scripts esté habilitada antes de ejecutar el instalador. Puedes configurarla ejecutando:
> ```powershell
> Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
> ```

```powershell
irm https://raw.githubusercontent.com/lpatros/assistant-cli/main/install.ps1 | iex
```

> [!NOTE]
> Asegúrate también de que Git Bash esté agregado a las variables de entorno de tu sistema (generalmente en `C:\Program Files\Git\bin`).

<details>
<summary> <b>Cómo agregar o corregir Git Bash en las Variables de Entorno (PATH) de Windows</b></summary>

### Paso a paso:

1. **Verificar si ya está configurado:**
   - Abre **PowerShell** o el **Símbolo del sistema (CMD)**.
   - Escribe `bash --version` o `where bash` y presiona Enter.
   - Si el comando devuelve la versión de Bash o la ruta del ejecutable, ¡ya está configurado! De lo contrario, sigue los pasos a continuación.

2. **Localizar la ruta de instalación de Git Bash:**
   - Por defecto, Git Bash se instala en: `C:\Program Files\Git\bin` (o `C:\Program Files (x86)\Git\bin`).
   - Abre el Explorador de archivos de Windows, navega hasta esa carpeta y asegúrate de que el archivo `bash.exe` esté allí. Copia la ruta de la carpeta (`C:\Program Files\Git\bin`).

3. **Abrir las Variables de entorno:**
   - Presiona la tecla `Windows`, escribe **"variables de entorno"** y selecciona la opción **"Editar las variables de entorno del sistema"**.
   - En la ventana que se abra, haz clic en el botón **"Variables de entorno..."** (ubicado en la esquina inferior derecha).

4. **Editar la variable PATH:**
   - En **"Variables de usuario"** (para aplicar solo a tu usuario) o **"Variables del sistema"** (para aplicar a todos os usuarios), localiza la variable llamada **`Path`** y selecciónala.
   - Haz clic en el botón **"Editar..."**.

5. **Agregar la ruta:**
   - Haz clic en el botón **"Nuevo"** en el lado derecho.
   - Pega la ruta copiada en el Paso 2 (ej: `C:\Program Files\Git\bin`).
   - Haz clic en **"Aceptar"** en todas las ventanas abiertas para guardar y aplicar el cambio.

6. **Validar la configuración:**
   - **Importante:** Cierra todas las ventanas abiertas de PowerShell o CMD y abre una nueva terminal para cargar las nuevas variables de entorno.
   - Escribe `bash --version` en la nueva terminal. Si la versión de Bash se muestra con éxito, ¡la configuración se ha completado!
</details>

**En Windows vía PowerShell, el instalador interactivo:**
1. Clonará el repositorio en `%LOCALAPPDATA%\assistant-cli` (o un directorio personalizado de tu elección).
2. Verificará si `bash` está disponible en tu sistema (por ejemplo, Git Bash o WSL), ya que el núcleo del proyecto utiliza scripts `.sh`.
3. Agregará una función contenedora (wrapper) directamente en tu perfil de PowerShell (`$PROFILE`) que llama a `bash` de manera transparente. **¡Esto significa que no necesitas abrir Git Bash manualmente; el asistente funcionará perfectamente dentro de tu PowerShell estándar!**
4. Te guiará sobre cómo recargar tu terminal.

#### Bash (Git Bash / WSL)

Si usas **Bash** como tu terminal en Windows, puedes instalar Assistant CLI directamente usando `curl`:

```bash
curl -fsSL https://raw.githubusercontent.com/lpatros/assistant-cli/main/install.sh | bash
```

**En Bash, el instalador interactivo:**
1. Clonará el repositorio en el directorio de instalación (`%LOCALAPPDATA%\assistant-cli` o `~/.config/assistant-cli`).
2. Agregará automáticamente la configuración a tu perfil de shell (`~/.bashrc`, `~/.zshrc` o `config.fish`).
3. Te guiará sobre cómo recargar tu terminal para comenzar a usar el asistente.

## Actualización y Versión

Puedes verificar la versión actual del asistente con:

```bash
assistant --version
```

Puedes actualizar fácilmente tu Assistant CLI a la versión más reciente o cambiar a una versión específica:

```bash
assistant update                     # Actualiza a la última versión del canal activo
assistant update --list              # Lista las versiones disponibles (o -l)
assistant update @1.2.0              # Actualiza/cambia a la versión 1.2.0
assistant update --version 1.2.0     # Sintaxis alternativa para definir la versión
```

También puedes cambiar entre canales de lanzamiento (estable y beta):

```bash
assistant channel status  # Muestra el canal de lanzamiento actual
assistant channel beta    # Cambia al canal beta (rama dev) y actualiza
assistant channel stable  # Cambia al canal estable (rama main) y actualiza
```

## Características

### Chat Interactivo y Directo
- Ejecuta `assistant` para iniciar una sesión de chat interactiva con el modelo seleccionado actualmente.
- Ejecuta `assistant "tu consulta aquí"` para enviar rápidamente una sola pregunta al modelo y recibir el resultado.

### Harnesses y skills nativas en Codex

Consulta los recursos con `assistant adapters capabilities`. `engine` y `harness` son alias de `adapters`. La instalación nativa en Codex ofrece alcances explícitos de proyecto/usuario, vista previa, verificación y eliminación que conserva ediciones locales. Consulta la [guía de harnesses e instalación](docs/harnesses/README-ES.md).

### Soporte Modular y Adaptadores Personalizados
- Soporte nativo para **Antigravity**, **Codex**, **Copilot**, **Ollama** y **OpenCode**.
- Crea tus **Adaptadores Personalizados** con un punto de entrada en `custom/adapters/<nombre>/init.sh`. El nombre de la carpeta identifica el adaptador; los archivos auxiliares quedan junto al punto de entrada.
- El asistente almacena los modelos de preferencia por motor. De esta forma, no perderás las configuraciones del modelo seleccionado al cambiar de motor.
- Cambia entre adaptadores de forma interactiva con `assistant adapters select` o directamente con `assistant adapters <nombre>`.

### Habilidades Integradas (Habilidades Predeterminadas)
El asistente viene con varias habilidades integradas para potenciar tu flujo de trabajo:
- **Asistente de Commits (`assistant commit`)**: Analiza el estado de tu repositorio Git, los diffs en el área de preparación (staged) y las estadísticas de cambios no preparados, y los ejecuta bajo pautas estándar para generar sugerencias de mensajes de commit limpios y legibles.
- **Asistente de Separación de Ramas (`assistant branch`)**: Analiza el estado, los diffs y el historial de tu repositorio Git para dividir trabajo mezclado en ramas separadas y con un propósito propio (p. ej. `fix/...`, `test/...`, `feature/...`), cada una con commits atómicos, mensajes Conventional Commits y comandos Git seguros para ejecutar manualmente.
- **Generador de Resúmenes de Proyecto (`assistant resume [rutas...]`)**: Reúne automáticamente el contexto del directorio de tu proyecto (árbol estructural y archivos de manifiesto como `package.json`, `pom.xml`, `Cargo.toml`, etc.) y genera un resumen completo en formato markdown que describe la arquitectura y las dependencias del proyecto.
- **Generador de README (`assistant readme --lang [idioma] --name [nombre_archivo]`)**: Analiza automáticamente la estructura del proyecto y los archivos de configuración para generar un archivo README profesional y contextualizado.

### Habilidades Personalizadas

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

Los comandos administrativos y sus alias están reservados: `create`, `skills`, `model`, `adapters`, `engine`, `harness`, `think`, `lang`, `custom`, `status`, `update`, `channel`, `changelog`, `version`, `--version`, `-v`, `help`, `--help`, `-h`, `--think`, `--no-think`, `--hide-think`. Las skills no pueden interceptarlos. El orden es: comandos administrativos, skills validadas (instrucciones personalizadas antes que nativas), comandos dinámicos personalizados y prompts directos.

Para migrar una skill antigua, mueve sus instrucciones a `custom/skills/<nombre>/SKILL.md` y agrega el frontmatter obligatorio. Se ignora el nombre antiguo. Usa [SKILL.md.template](docs/templates/skills/SKILL.md.template) como referencia.

#### Comandos Dinámicos Personalizados (Shell)
También puedes definir funciones Shell personalizadas para ejecutar lógica dinámica.

Para ello, crea o edita el archivo `custom/init.sh` y define funciones siguiendo la convención de nombres `_cmd_<nombre>`:

```bash
# custom/init.sh
_cmd_hello() {
  echo "¡Hola desde una función personalizada en Shell!"
  echo "Argumentos recibidos: $*"
}
```

Cualquier función declarada como `_cmd_<nombre>` en `custom/init.sh` se despachará automáticamente al ejecutar:
```bash
assistant hello "mundo"
```

#### Locales Personalizados (Idiomas Personalizados)
Puedes agregar tu propia traducción de idioma creando un archivo `.sh` en `custom/locales/<idioma>.sh` (por ejemplo, `custom/locales/fr.sh`).

En el archivo personalizado, define las funciones de traducción deseadas (ej: `t_lang_changed`, `t_lang_status`). Cualquier función no definida en tu archivo personalizado utilizará automáticamente el respaldo en inglés (`locales/en.sh`).

```bash
# custom/locales/fr.sh
t_lang_changed() {
  _success "Langue modifiée en: ${BOLD}$1${RESET}"
}
t_lang_status() {
  _info "Langue actuelle: ${CYAN}${BOLD}$1${RESET}"
}
```

Cambia a tu idioma personalizado o lista los idiomas disponibles:
```bash
# Definir idioma personalizado
assistant lang fr

# Listar todos los idiomas disponibles (predeterminados y personalizados)
assistant lang --list
```

#### Guía Completa de Personalización y Plantillas
Para documentación detallada, especificaciones del contrato de funciones y ejemplos avanzados sobre cómo crear motores de IA, idiomas, habilidades (skills) y comandos dinámicos de shell, consulte la **[Guía de Personalización y Extensiones (docs/customization/README-ES.md)](docs/customization/README-ES.md)**.

También puede utilizar las plantillas de referencia disponibles en el directorio [`docs/templates/`](docs/templates)

## Uso

Al ejecutar `assistant`, tienes acceso a los siguientes comandos:

| Comando | Descripción |
| :--- | :--- |
| `assistant` | Inicia un chat interactivo con el modelo actual |
| `assistant "<mensaje>"` | Envía un mensaje directo al modelo actual |
| `assistant status` | Muestra el motor activo, los modelos activos, el modo pensamiento y el idioma |
| `assistant commit` | Analiza el área de preparación de git (staging) y sugiere commits estructurados |
| `assistant branch` | Analiza los cambios de git y sugiere ramas separadas por propósito |
| `assistant resume [rutas...]` | Escanea directorios y genera archivos markdown de resumen del proyecto |
| `assistant readme --lang <idioma> --name <nombre>` | Escanea la estructura del proyecto y genera un archivo README |
| `assistant adapters [<nombre>\|status]` | Selecciona un adaptador por nombre o muestra su estado |
| `assistant adapters --list` | Lista adaptadores integrados y personalizados sin interacción |
| `assistant adapters select` | Abre el menú interactivo de selección |
| `assistant custom adapters --list` | Lista solo adaptadores personalizados |
| `assistant engine …` / `assistant harness …` | Alias de `assistant adapters`, con comportamiento idéntico |
| `assistant adapters capabilities [nombre]` | Muestra capacidades de los adaptadores |
| `assistant skills install <name> --harness codex --scope <project\|user> [--project <dir>] [--dry-run]` | Muestra vista previa o instala una skill nativa en Codex |
| `assistant skills verify <name> --harness codex --scope <project\|user> [--project <dir>]` | Valida la instalación administrada |
| `assistant skills remove <name> --harness codex --scope <project\|user> [--project <dir>] [--dry-run]` | Elimina una instalación administrada sin ediciones locales |
| `assistant skills list` | Lista skills, orígenes y conflictos |
| `assistant create skill <nombre> <ruta.md>` | Crea una nueva habilidad personalizada a partir de una plantilla Markdown |
| `assistant <habilidad-personalizada> [args]` | Ejecuta una habilidad personalizada |
| `assistant lang [<idioma>\|--list\|status]` | Cambia el idioma activo, lista idiomas disponibles o muestra el idioma actual |
| `assistant model --list` | Muestra de forma interactiva los modelos disponibles para el motor actual para cambiarlos |
| `assistant model status` | Muestra los modelos configurados actualmente para todos los motores |
| `assistant think [on\|off\|hide\|clear]` | Alterna los modos de pensamiento/razonamiento en modelos de Ollama |

`--list` (y `list`) imprime una tabla sin interacción, también mediante los alias `engine` y `harness`. Usa `select` para el menú interactivo. La tabla muestra el origen, la disponibilidad del ejecutable y el estado activo de cada adaptador. La selección rechaza nombres que no se han descubierto. Cuando un adaptador personalizado tiene el mismo nombre que uno integrado, el personalizado tiene prioridad y aparece una sola vez.

Las mismas operaciones están disponibles en `assistant custom adapters`: `--list`, `select`, `status`, `capabilities [name]` y `<nombre>`. Las listas, capacidades y selección se limitan a los adaptadores personalizados. `status` indica si el adaptador activo es personalizado; seleccionar aquí también cambia el único adaptador activo global.

### Ejemplos

```bash
# Hacer una pregunta general de programación
assistant "¿Cómo implemento un debouncer en JS vainilla?"

# Generar commits de git a partir de los cambios preparados
assistant commit

# Separar cambios mezclados en ramas dedicadas por propósito
assistant branch

# Cambiar el motor activo a Antigravity (agy), Codex, Copilot, Ollama u OpenCode
assistant adapters agy
assistant adapters codex
assistant adapters copilot
assistant adapters ollama
assistant adapters opencode

# Listar adaptadores sin abrir un menú
assistant adapters --list

# Cambiar de motor de forma interactiva
assistant adapters select

# Cambiar el modelo del motor actual de forma interactiva
assistant model --list
```

## Estructura del Proyecto

```
assistant/
├── custom/                  # Motores, habilidades e idiomas personalizados del usuario
│   ├── adapters/            # Adaptadores personalizados (scripts .sh)
│   ├── locales/             # Idiomas personalizados (.sh)
│   └── skills/              # Habilidades personalizadas (<nombre>/SKILL.md)
├── data/                    # Almacenamiento persistente de la configuración (motor, modelo, idioma)
├── docs/                    # Guía de personalización y plantillas de extensión
│   ├── customization/       # Guías de personalización (README*.md)
│   ├── harnesses/           # Guías de harnesses y skills nativas (README*.md)
│   └── templates/           # Plantillas de referencia (adapters, locales, skills)
├── lib/                     # Motores (lib/adapters/), rutas y utilidades del sistema
├── locales/                 # Traducciones de texto
├── skills/                  # Herramientas del asistente
├── utils/                   # Scripts de utilidad y ayudantes
├── init.sh                  # Punto de entrada principal para cargar en los archivos de configuración del shell
├── LICENSE.txt              # Licencia
└── README.md                # Documentación
```

## Licencia

Este proyecto está bajo la Licencia MIT - consulte el archivo [LICENSE](LICENSE.txt) para más detalles.

