# === Compilador Ninja para projeto local ===
$ErrorActionPreference = "Stop"

$BaseDir  = "C:\Exodus-Online-main"
$VcpkgDir = "C:\dev\vcpkg"
$BuildDir = Join-Path $BaseDir "build"

# Ninja local, caso tenha sido extraido aqui
$env:Path += ";C:\Exodus-Online-main\Tools\Ninja"

Write-Host "=== Compilador Ninja para projeto local ==="
Write-Host "Projeto: $BaseDir"
Write-Host "vcpkg:   $VcpkgDir"
Write-Host "Build:   $BuildDir"

$Confirm = Read-Host "Continuar? [s/N]"
if ($Confirm -ne "s" -and $Confirm -ne "S") {
    Write-Host "Cancelado."
    exit 1
}

if (-not (Get-Command cmake -ErrorAction SilentlyContinue)) {
    Write-Error "CMake nao encontrado. Instale o CMake e abra um novo PowerShell."
}

if (-not (Get-Command ninja -ErrorAction SilentlyContinue)) {
    Write-Error "Ninja nao encontrado. Instale o Ninja ou adicione-o ao PATH."
}

if (-not (Test-Path (Join-Path $BaseDir "CMakeLists.txt"))) {
    Write-Error "CMakeLists.txt nao encontrado em $BaseDir"
}

$VcpkgExe = Join-Path $VcpkgDir "vcpkg.exe"
if (-not (Test-Path $VcpkgExe)) {
    Write-Error "vcpkg.exe nao encontrado em $VcpkgExe"
}

$Toolchain = Join-Path $VcpkgDir "scripts\buildsystems\vcpkg.cmake"
if (-not (Test-Path $Toolchain)) {
    Write-Error "Toolchain do vcpkg nao encontrado em $Toolchain"
}

# Detecta Visual Studio
$VsWhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
if (-not (Test-Path $VsWhere)) {
    Write-Error "Visual Studio nao encontrado. Instale o Visual Studio com 'Desenvolvimento para desktop com C++'."
}

$VsPath = & $VsWhere -latest -products * `
    -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 `
    -property installationPath

if (-not $VsPath) {
    Write-Error "Visual Studio C++ workload nao encontrado."
}

Write-Host "Visual Studio detectado em: $VsPath"

$VcVars = Join-Path $VsPath "VC\Auxiliary\Build\vcvars64.bat"
if (-not (Test-Path $VcVars)) {
    Write-Error "vcvars64.bat nao encontrado em: $VcVars"
}

# Prepara pasta build
if (-not (Test-Path $BuildDir)) {
    New-Item -ItemType Directory -Path $BuildDir | Out-Null
}

Write-Host "Instalando dependencias via vcpkg..."

$Dependencies = @(
    "cryptopp:x64-windows",
    "fmt:x64-windows",
    "libmysql:x64-windows",
    "pugixml:x64-windows",
    "lua:x64-windows",
    "luajit:x64-windows"
)

foreach ($Dep in $Dependencies) {
    Write-Host "Instalando $Dep..."
    & $VcpkgExe install $Dep

    if ($LASTEXITCODE -ne 0) {
        Write-Error "Falha ao instalar $Dep"
    }
}

& $VcpkgExe install fmt:x64-windows
if ($LASTEXITCODE -ne 0) {
    Write-Error "Falha ao instalar fmt:x64-windows"
}

# Script batch: carrega MSVC e compila com Ninja
$BuildScript = Join-Path $env:TEMP "exodus_build_ninja.bat"

@"
@echo off
call "$VcVars"
cd /d "$BuildDir"

cmake .. ^
  -G Ninja ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_TOOLCHAIN_FILE="$Toolchain" ^
  -DVCPKG_TARGET_TRIPLET=x64-windows

if errorlevel 1 exit /b 1

cmake --build . --parallel
if errorlevel 1 exit /b 1
"@ | Set-Content -Path $BuildScript -Encoding ASCII

Write-Host "Configurando e compilando com Ninja..."
& cmd.exe /c $BuildScript

if ($LASTEXITCODE -ne 0) {
    Write-Error "Falha na configuracao ou compilacao com Ninja."
}

Write-Host ""
Write-Host "Compilacao Ninja concluida."
Write-Host "Verifique os executaveis gerados em:"
Write-Host $BuildDir