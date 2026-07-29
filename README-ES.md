<div align="center">

# Assistant CLI

[English](README.md) | [Português](README-PTBR.md) | **Español**

  <p>Una envoltura (wrapper) de terminal ligera, modular y localizada para Ollama, OpenCode, Antigravity (agy) y Custom Engines, con soporte para chat interactivo, análisis de repositorios, generación de README, resúmenes de proyectos y más.</p>
    <div style="margin-bottom: 10px">
    <img src="https://img.shields.io/badge/Language-Shell-orange.svg"/>
    </div>
    <br>
</div>

# Enlaces Rápidos

- [Descripción](#descripción)
- [Instalación y Configuración](#instalación-y-configuración)
- [Actualización](#actualización)
- [Características](#características)
- [Uso](#uso)
- [Estructura del Proyecto](#estructura-del-proyecto)
- [Licencia](#licencia)

## Descripción

El **Assistant CLI** (`assistant`) es una interfaz de línea de comandos (CLI) potente y ligera escrita en Bash. Permite a los usuarios interactuar con Modelos de Lenguaje Grande (LLMs) locales o en la nube organizados a través de **Ollama**, **OpenCode**, **Antigravity** o **Motores Personalizados** (`custom/engines/`) directamente desde la terminal.

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

**En Windows, el instalador interactivo:**
1. Clonará el repositorio en `%LOCALAPPDATA%\assistant-cli` (o un directorio personalizado de tu elección).
2. Verificará si `bash` está disponible en tu sistema (por ejemplo, Git Bash o WSL), ya que el núcleo del proyecto utiliza scripts `.sh`.
3. Agregará una función contenedora (wrapper) directamente en tu perfil de PowerShell (`$PROFILE`) que llama a `bash` de manera transparente. **¡Esto significa que no necesitas abrir Git Bash manualmente; el asistente funcionará perfectamente dentro de tu PowerShell estándar!**
4. Te guiará sobre cómo recargar tu terminal.

## Actualización y Versión

Puedes verificar la versión actual del asistente con:

```bash
assistant --version
```

Puedes actualizar fácilmente tu Assistant CLI a la versión más reciente ejecutando:

```bash
assistant update
```

## Características

### Chat Interactivo y Directo
- Ejecuta `assistant` para iniciar una sesión de chat interactiva con el modelo seleccionado actualmente.
- Ejecuta `assistant "tu consulta aquí"` para enviar rápidamente una sola pregunta al modelo y recibir el resultado.

### Soporte Modular y Motores Personalizados
- Soporte nativo para **Ollama**, **OpenCode** y **Antigravity**.
- Crea tus propios **Motores Personalizados** guardando scripts `.sh` en `custom/engines/` (ej: `custom/engines/mi_motor.sh`).
- El asistente almacena los modelos de preferencia por motor. De esta forma, no perderás las configuraciones del modelo seleccionado al cambiar de motor.
- Cambia entre motores de forma interactiva con `assistant engine --list` o directamente con `assistant engine <nombre>`.

### Habilidades Integradas (Habilidades Predeterminadas)
El asistente viene con varias habilidades integradas para potenciar tu flujo de trabajo:
- **Asistente de Commits (`assistant commit`)**: Analiza el estado de tu repositorio Git, los diffs en el área de preparación (staged) y las estadísticas de cambios no preparados, y los ejecuta bajo pautas estándar para generar sugerencias de mensajes de commit limpios y legibles.
- **Generador de Resúmenes de Proyecto (`assistant resume [rutas...]`)**: Reúne automáticamente el contexto del directorio de tu proyecto (árbol estructural y archivos de manifiesto como `package.json`, `pom.xml`, `Cargo.toml`, etc.) y genera un resumen completo en formato markdown que describe la arquitectura y las dependencias del proyecto.
- **Generador de README (`assistant readme --lang [idioma] --name [nombre_archivo]`)**: Analiza automáticamente la estructura del proyecto y los archivos de configuración para generar un archivo README profesional y contextualizado.

### Habilidades Personalizadas
Puedes crear tus propias habilidades personalizadas utilizando archivos Markdown que definan pautas para el LLM.

#### Creación de una Habilidad Personalizada
```bash
assistant create skill <nombre> <ruta-al-archivo-markdown>
```
Esto guardará las reglas de tu habilidad personalizada en `custom/skills/<nombre>-assistant.md`.

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
| `assistant lang [<idioma>\|--list\|status]` | Cambia el idioma activo, lista idiomas disponibles o muestra el idioma actual |
| `assistant model --list` | Muestra de forma interactiva los modelos disponibles para el motor actual para cambiarlos |
| `assistant model status` | Muestra los modelos configurados actualmente para todos los motores |
| `assistant engine [<nombre>\|--list\|status]` | Cambia el motor activo |
| `assistant think [on\|off\|hide\|clear]` | Alterna los modos de pensamiento/razonamiento en modelos de Ollama |

### Ejemplos

```bash
# Hacer una pregunta general de programación
assistant "¿Cómo implemento un debouncer en JS vainilla?"

# Generar commits de git a partir de los cambios preparados
assistant commit

# Cambiar el motor activo a Antigravity (agy), Ollama u OpenCode
assistant engine agy
assistant engine ollama
assistant engine opencode

# Cambiar de motor de forma interactiva
assistant engine --list

# Cambiar el modelo del motor actual de forma interactiva
assistant model --list
```

## Estructura del Proyecto

```
assistant/
├── custom/                  # Motores, habilidades e idiomas personalizados del usuario
│   ├── engines/             # Motores personalizados (scripts .sh)
│   ├── skills/              # Habilidades personalizadas (.md)
│   └── locales/             # Idiomas personalizados (.sh)
├── data/                    # Almacenamiento persistente de la configuración (motor, modelo, idioma)
├── lib/                     # Motores (lib/engines/), rutas y utilidades del sistema
├── locales/                 # Traducciones de texto (pt-br, en, es)
├── skills/                  # Herramientas del asistente (commit, resume, readme)
├── utils/                   # Scripts de utilidad y ayudantes
├── init.sh                  # Punto de entrada principal para cargar en los archivos de configuración del shell
├── LICENSE.txt              # Licencia
└── README.md                # Documentación
```

## Licencia

Este proyecto está bajo la Licencia MIT - consulte el archivo [LICENSE](LICENSE.txt) para más detalles.

