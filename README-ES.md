<div align="center">

# Assistant CLI

[English](README.md) | [Português](README-PTBR.md) | **Español**

  <p>Una envoltura (wrapper) de terminal ligera, modular y localizada para Ollama y OpenCode, con soporte para chat interactivo, generación de commits, generación de README, resúmenes de proyectos y más.</p>
    <div style="margin-bottom: 10px">
    <img src="https://img.shields.io/badge/Language-Shell-orange.svg" alt="Lenguaje: Zsh/Bash"/>
    <img src="https://img.shields.io/badge/Engines-Ollama%20%7C%20OpenCode-blue.svg" alt="Motores: Ollama & OpenCode"/>
    <img src="https://img.shields.io/badge/Think_Mode-Supported-yellow.svg" alt="Modo Pensamiento"/>
    </div>
    <br>
</div>

# Enlaces Rápidos

- [Descripción](#descripción)
- [Tecnologías](#tecnologías)
- [Características](#características)
- [Instalación y Configuración](#instalación-y-configuración)
- [Actualización](#actualización)
- [Uso](#uso)
- [Estructura del Proyecto](#estructura-del-proyecto)

## Descripción

El **Assistant CLI** (`assistant`) es una interfaz de línea de comandos (CLI) potente y ligera escrita en Zsh/Bash. Permite a los usuarios interactuar con Modelos de Lenguaje Grande (LLMs) locales organizados a través de **Ollama** o **OpenCode** directamente desde la terminal.

Todas las opciones de configuración (como el motor activo, el modelo seleccionado, el idioma y el modo de pensamiento) se guardan localmente y persisten entre sesiones de terminal.

## Tecnologías

- **Zsh / Bash** - Entorno de scripting y envoltura de la función principal
- **Ollama** - Motor de orquestación para modelos locales (por ejemplo, DeepSeek, Llama, Gemma)
- **OpenCode** - Motor de orquestación y registro para modelos de programación

## Características

### Chat Interactivo y Directo
- Ejecuta `assistant` para iniciar una sesión de chat interactiva con el modelo seleccionado actualmente.
- Ejecuta `assistant "tu consulta aquí"` para enviar rápidamente una sola pregunta al modelo y recibir el resultado.

### Soporte Multi-Motor
- Transición fluida entre **Ollama** y **OpenCode**.
- El asistente almacena los modelos preferidos por motor, lo que significa que no perderás las configuraciones del modelo seleccionado al cambiar de motor.

### Habilidades Integradas (Habilidades Predeterminadas)
El asistente viene con varias habilidades integradas para potenciar tu flujo de trabajo:
- **Asistente de Commits (`assistant commit`)**: Analiza el estado de tu repositorio Git, los diffs en el área de preparación (staged) y las estadísticas de cambios no preparados, y los ejecuta bajo pautas estándar para generar sugerencias de mensajes de commit limpios y legibles.
- **Generador de Resúmenes de Proyecto (`assistant resume [rutas...]`)**: Reúne automáticamente el contexto del directorio de tu proyecto (árbol estructural y archivos de manifiesto como `package.json`, `pom.xml`, `Cargo.toml`, etc.) y genera un resumen completo en formato markdown que describe la arquitectura y las dependencias del proyecto.
- **Generador de README (`assistant readme --lang [en|pt-br] --name [nombre_archivo]`)**: Analiza automáticamente la estructura del proyecto y los archivos de configuración para generar un archivo README profesional y contextualizado.

### Habilidades Personalizadas
Puedes crear tus propias habilidades personalizadas utilizando archivos Markdown que definan pautas para el LLM.

#### Creación de una Habilidad Personalizada
```bash
assistant create skill <nombre> <ruta-al-archivo-markdown>
```
Esto guardará las reglas de tu habilidad personalizada en `custom/<nombre>-assistant.md`.

#### Sobrescribir Habilidades Predeterminadas
Si intentas crear una habilidad personalizada con el mismo nombre que una habilidad integrada/predeterminada (por ejemplo, `commit`), la CLI te pedirá confirmación:
```
⚠ La habilidad 'commit' es una habilidad predeterminada del asistente.
¿Realmente deseas sobrescribirla? [y/N]:
```
Si eliges sobrescribir (`y`/`yes`), tu habilidad personalizada tendrá prioridad sobre la habilidad integrada al ejecutar `assistant commit`.

#### Ejecutar Habilidades Personalizadas
Ejecuta tu habilidad personalizada directamente como un comando:
```bash
assistant <nombre> "tu consulta o tarea"
```

### Gestión del Modo Pensamiento (Ollama)
- Activa, desactiva u oculta los pasos de razonamiento/pensamiento del modelo (por ejemplo, para modelos que muestran pensamientos como `<think>...</think>`). Puede cambiarse por sesión o guardarse globalmente.

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

Para usuarios de **Windows**, se puede instalar usando PowerShell. Abre tu PowerShell y ejecuta:

> [!IMPORTANT]
> Asegúrate de que la política de ejecución de scripts esté habilitada antes de ejecutar el instalador. Puedes configurarla ejecutando:
> ```powershell
> Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
> ```

```powershell
irm https://raw.githubusercontent.com/lpatros/assistant-cli/main/install.ps1 | iex
```

> [!NOTE]
> También asegúrate de que Git Bash esté incluido en las Variables de Entorno del sistema (generalmente ubicado en `C:\Program Files\Git\bin`).

**En Windows, el instalador interactivo:**
1. Clonará el repositorio en `%LOCALAPPDATA%\assistant-cli` (o un directorio personalizado de tu elección).
2. Verificará si `bash` está disponible en tu sistema (por ejemplo, Git Bash o WSL), ya que el núcleo del proyecto utiliza scripts `.sh`.
3. Agregará una función contenedora (wrapper) directamente en tu perfil de PowerShell (`$PROFILE`) que llama a `bash` de manera transparente. **¡Esto significa que no necesitas abrir Git Bash manualmente; el asistente funcionará perfectamente dentro de tu PowerShell estándar!**
4. Te guiará sobre cómo recargar tu terminal.

## Actualización

Puedes actualizar fácilmente tu Assistant CLI a la versión más reciente ejecutando el comando de actualización. Esto descargará los últimos cambios del repositorio y garantizará que tu instalación local esté actualizada.

```bash
assistant update
```

## Uso

Al ejecutar `assistant`, tienes acceso a los siguientes comandos:

| Comando | Descripción |
| :--- | :--- |
| `assistant` | Inicia un chat interactivo con el modelo actual |
| `assistant "<mensaje>"` | Envía un mensaje directo al modelo actual |
| `assistant status` | Muestra el motor activo, los modelos activos, el modo pensamiento y el idioma |
| `assistant commit` | Analiza el área de preparación de git (staging) y sugiere commits estructurados |
| `assistant resume [rutas...]` | Escanea directorios y genera archivos markdown de resumen del proyecto |
| `assistant readme --lang <idioma> --name <nombre>` | Escanea la estructura del proyecto y genera un archivo README |
| `assistant create skill <nombre> <ruta.md>` | Crea una nueva habilidad personalizada a partir de una plantilla Markdown |
| `assistant <habilidad-personalizada> [args]` | Ejecuta una habilidad personalizada |
| `assistant model --list` | Muestra de forma interactiva los modelos disponibles para el motor actual para cambiarlos |
| `assistant model status` | Muestra los modelos configurados actualmente para todos los motores |
| `assistant engine [ollama\|opencode]` | Cambia el motor de orquestación de modelos activo |
| `assistant think [on\|off\|hide\|clear]` | Alterna los modos de pensamiento/razonamiento en modelos de Ollama |
| `assistant lang [en\|pt-br]` | Cambia la configuración del idioma de la CLI |

### Ejemplos

```bash
# Hacer una pregunta general de programación
assistant "¿Cómo implemento un debouncer en JS vainilla?"

# Generar commits de git a partir de los cambios preparados
assistant commit

# Crear documentos de resumen del proyecto en paralelo para dos carpetas
assistant resume ./backend-service ./frontend-app

# Cambiar el modelo de forma interactiva
assistant model --list
```

## Estructura del Proyecto

```
assistant/
├── custom/                  # Habilidades personalizadas del asistente
├── data/                    # Almacenamiento persistente de la configuración (motor, modelo, idioma)
├── lib/                     # Constantes de rutas, traducciones y enrutamiento de comandos
├── locales/                 # Traducciones de texto
├── skills/                  # Herramientas del asistente
├── utils/                   # Scripts de utilidad y ayudantes
├── init.sh                  # Punto de entrada principal para cargar en los archivos de configuración del shell
└── README.md                # Documentación
```
