$ErrorActionPreference = "Stop"

$RepoUrl = "https://github.com/lpatros/assistant-cli.git"
$DefaultInstallDir = "$env:LOCALAPPDATA\assistant-cli"

function Write-Color {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Text,
        [ConsoleColor]$Color = "White",
        [switch]$NoNewline
    )
    if ($NoNewline) {
        Write-Host $Text -ForegroundColor $Color -NoNewline
    } else {
        Write-Host $Text -ForegroundColor $Color
    }
}

Write-Host ""
Write-Color "  ┌──────────────────────────────────────┐" -Color Cyan
Write-Color "  │       @ Assistant CLI Installer      │" -Color Cyan
Write-Color "  └──────────────────────────────────────┘" -Color Cyan
Write-Host ""

Write-Color "  Use default installation path (" -NoNewline
Write-Color $DefaultInstallDir -Color White -NoNewline
Write-Color ")? [Y/n]: " -NoNewline
$UseDefaultDir = Read-Host

if ([string]::IsNullOrWhiteSpace($UseDefaultDir) -or $UseDefaultDir -match "^[yY]([eE][sS])?$") {
    $InstallDir = $DefaultInstallDir
} else {
    Write-Color "  Enter custom installation path: " -NoNewline
    $CustomDir = Read-Host
    if ([string]::IsNullOrWhiteSpace($CustomDir)) {
        $InstallDir = $DefaultInstallDir
    } else {
        $InstallDir = $CustomDir
    }
}
$InstallDir = [System.Environment]::ExpandEnvironmentVariables($InstallDir)

Write-Host ""
Write-Color "  -> Installing to: " -NoNewline
Write-Color $InstallDir -Color White
Write-Host "`n"

if (!(Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Color "  git is not installed. Please install git first." -Color Red
    exit 1
}

if (!(Get-Command bash -ErrorAction SilentlyContinue)) {
    Write-Color "  bash is not installed or not in PATH. A bash environment (like Git Bash) is required." -Color Red
    exit 1
}

if (Test-Path "$InstallDir\.git") {
    Write-Color "  Installation directory already exists: $InstallDir" -Color Cyan
    Write-Color "  Do you want to update it? [y/N]: " -NoNewline
    $UpdateChoice = Read-Host
    if ($UpdateChoice -match "^[yY]([eE][sS])?$") {
        Write-Color "  Updating existing installation..." -Color Cyan
        git -C $InstallDir pull --ff-only
        Write-Color "  Updated successfully." -Color Green
    } else {
        Write-Color "  Skipping clone — using existing installation." -Color Cyan
    }
} elseif (Test-Path $InstallDir) {
    Write-Color "  Directory $InstallDir exists but is not a git repository." -Color Yellow
    Write-Color "  Do you want to remove it and reinstall? [y/N]: " -NoNewline
    $ReinstallChoice = Read-Host
    if ($ReinstallChoice -match "^[yY]([eE][sS])?$") {
        Remove-Item -Path $InstallDir -Recurse -Force
        Write-Color "  Cloning repository..." -Color Cyan
        git clone $RepoUrl $InstallDir
        Write-Color "  Cloned to $InstallDir" -Color Green
    } else {
        Write-Color "  Keeping existing directory. Proceeding with configuration..." -Color Cyan
    }
} else {
    Write-Color "  Cloning repository..." -Color Cyan
    $null = New-Item -Path (Split-Path $InstallDir) -ItemType Directory -Force -ErrorAction SilentlyContinue
    git clone $RepoUrl $InstallDir
    Write-Color "  Cloned to $InstallDir" -Color Green
}

Write-Host "`n  Which profile should be modified?`n"
Write-Color "    1) " -Color White -NoNewline
Write-Host "Current User, Current Host (`$PROFILE)"
Write-Color "    2) " -Color White -NoNewline
Write-Host "None (I'll configure manually)`n"

Write-Color "  Choice [1-2, default: 1]: " -NoNewline
$ProfileChoice = Read-Host

$InstallDirPosix = $InstallDir -replace '\\', '/'

if ([string]::IsNullOrWhiteSpace($ProfileChoice) -or $ProfileChoice -eq "1") {
    if (!(Test-Path $PROFILE)) {
        $null = New-Item -Path (Split-Path $PROFILE) -ItemType Directory -Force -ErrorAction SilentlyContinue
        $null = New-Item -Path $PROFILE -ItemType File -Force
    }
    
    $ProfileContent = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
    
    $WrapperCode = @'

# Assistant CLI
function assistant {
    bash -c "source '{{DIR}}/init.sh'; assistant `"`$@`"" -- $args
}
'@ -replace '\{\{DIR\}\}', $InstallDirPosix

    if ($ProfileContent -match "# Assistant CLI") {
        Write-Color "`n  Already configured in $PROFILE" -Color Cyan
    } else {
        Add-Content -Path $PROFILE -Value $WrapperCode
        Write-Color "`n  Added to $PROFILE" -Color Green
    }
} else {
    Write-Color "`n  Skipping profile configuration." -Color Cyan
    Write-Host "`n  To configure manually, add a wrapper to your PowerShell profile:`n"
    
    $ManualConfig = @'
    function assistant {
        bash -c "source '{{DIR}}/init.sh'; assistant `"`$@`"" -- $args
    }
'@ -replace '\{\{DIR\}\}', $InstallDirPosix

    Write-Host $ManualConfig -ForegroundColor White
    Write-Host ""
}

Write-Host ""
Write-Color "  ┌──────────────────────────────────────┐" -Color Green
Write-Color "  │    @ Installation complete!          │" -Color Green
Write-Color "  └──────────────────────────────────────┘" -Color Green
Write-Host ""

if ([string]::IsNullOrWhiteSpace($ProfileChoice) -or $ProfileChoice -eq "1") {
    Write-Host "  Restart your PowerShell session or run:`n"
    Write-Color "    . `"$PROFILE`"`n" -Color White
}

Write-Host "  Then try: " -NoNewline
Write-Color "assistant --help`n" -Color White
