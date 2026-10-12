<#
.SYNOPSIS
    Instalador/compilador CrystalServer (Canary) - versao endurecida (PT-BR).
.DESCRIPTION
    Execute como ADMINISTRADOR, de preferencia em VM ou maquina de testes.
    Mudancas de seguranca: ExecutionPolicy so no processo, pasta dedicada,
    so HTTPS, repositorios em lista permitida, revisao do codigo antes de compilar,
    vcpkg/crystalserver fixaveis por commit, log completo.
#>
param(
    [string]$Branch = "main",
    [string]$CrystalCommit = "",
    [string]$VcpkgCommit = "",
    [switch]$WithMySQL
)
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$DevRoot     = "C:\Exodus-Online-main"
$VcpkgRoot   = Join-Path $DevRoot "vcpkg"
$ProjectRoot = Join-Path $DevRoot "crystalserver"
$Toolchain   = Join-Path $VcpkgRoot "scripts\buildsystems\vcpkg.cmake"
$VcpkgUrl    = "https://github.com/microsoft/vcpkg.git"
$CrystalUrl  = "https://github.com/zimbadev/crystalserver.git"
$AllowedUrls = @($VcpkgUrl, $CrystalUrl)

New-Item -Path $DevRoot -ItemType Directory -Force | Out-Null
Start-Transcript -Path (Join-Path $DevRoot "installer.log") -Append | Out-Null

function Confirm-Step($msg) {
    $r = Read-Host "$msg [s/N]"
    if ($r -notmatch '^(s|S|y|Y)$') { Write-Host "Cancelado."; Stop-Transcript | Out-Null; exit 1 }
}
function Get-VsGenerator {
    $vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
    if (-not (Test-Path $vswhere)) { return $null }
    $ver = & $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationVersion 2>$null
    if (-not $ver) { return $null }
    $major = 0
    if (-not [int]::TryParse(($ver -split '\.')[0], [ref]$major)) { return $null }
    switch ($major) {
        18 { return "Visual Studio 18 2026" }
        17 { return "Visual Studio 17 2022" }
        16 { return "Visual Studio 16 2019" }
        default { return $null }
    }
}
function Safe-Clone($url, $dest, $branch, $commit) {
    if ($AllowedUrls -notcontains $url -or $url -notmatch '^https://') { throw "URL nao permitida: $url" }
    git clone $url $dest
    if ($LASTEXITCODE -ne 0) { throw "git clone falhou: $url" }
    Push-Location $dest
    try {
        if ($branch) { git checkout $branch 2>$null | Out-Null }
        if ($commit) { git checkout $commit; if ($LASTEXITCODE -ne 0) { throw "commit invalido: $commit" } }
        Write-Host "Commit em uso:" -ForegroundColor Yellow
        git log -1 --format="%H | %an | %ad | %s"
    } finally { Pop-Location }
}

Clear-Host
Write-Host "=== CrystalServer Windows Installer (seguro) ===" -ForegroundColor Cyan

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Execute como Administrador."; Read-Host "Enter para sair"; exit 1
}

# Politica apenas para ESTE processo (nao persiste)
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned -Force

Write-Host "`nEste script vai:" -ForegroundColor Yellow
Write-Host " - clonar $VcpkgUrl em $VcpkgRoot"
Write-Host " - clonar $CrystalUrl ($Branch) em $ProjectRoot"
Write-Host " - instalar openssl/boost via vcpkg e compilar"
Confirm-Step "Recomendado rodar em VM/maquina de testes. Continuar?"

# Pre-requisitos (instalacao manual a partir dos sites oficiais)
$pre = @(
    @{ Name="git";   Url="https://git-scm.com/download/win" },
    @{ Name="cmake"; Url="https://cmake.org/download/" }
)
foreach ($p in $pre) {
    if (-not (Get-Command $p.Name -ErrorAction SilentlyContinue)) {
        Write-Host "$($p.Name) nao encontrado. Instale pelo site oficial: $($p.Url)" -ForegroundColor Yellow
        Start-Process $p.Url
        Read-Host "Pressione Enter apos instalar $($p.Name)"
    }
}
$vsInst = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vs_installer.exe"
$VsGenerator = Get-VsGenerator
if (-not $VsGenerator) {
    Write-Host "Visual Studio com a carga 'Desktop development with C++' nao encontrado. Instale o VS 2022/2026 Community." -ForegroundColor Yellow
    Start-Process "https://visualstudio.microsoft.com/vs/community/"
    Read-Host "Pressione Enter apos instalar"
    $VsGenerator = Get-VsGenerator
    if (-not $VsGenerator) { throw "Nenhuma instalacao do Visual Studio com ferramentas C++ encontrada." }
} else {
    Write-Host "Visual Studio detectado. Gerador CMake: $VsGenerator" -ForegroundColor Green
}

$env:Path = [Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [Environment]::GetEnvironmentVariable("Path","User")
foreach ($c in "git","cmake") {
    if (-not (Get-Command $c -ErrorAction SilentlyContinue)) { throw "$c nao encontrado. Reinicie o script." }
}

try {
    Set-Location $DevRoot

    # vcpkg
    if (-not (Test-Path $VcpkgRoot)) {
        Safe-Clone $VcpkgUrl $VcpkgRoot "" $VcpkgCommit
        Set-Location $VcpkgRoot
        .\bootstrap-vcpkg.bat -disableMetrics
        if ($LASTEXITCODE -ne 0) { throw "bootstrap do vcpkg falhou" }
    }
    Set-Location $VcpkgRoot
    $env:VCPKG_DISABLE_METRICS = "1"
    .\vcpkg install openssl:x64-windows boost:x64-windows
    if ($LASTEXITCODE -ne 0) { throw "vcpkg install falhou" }

    # CrystalServer
    Set-Location $DevRoot
    if (-not (Test-Path $ProjectRoot)) { Safe-Clone $CrystalUrl $ProjectRoot $Branch $CrystalCommit }

    Write-Host "`nREVISE o codigo antes de compilar (CMakeLists.txt, scripts, cmake/)." -ForegroundColor Yellow
    Write-Host "Pasta: $ProjectRoot"
    Write-Host "Procure por: Invoke-WebRequest, curl, wget, powershell, certutil, base64, URLs desconhecidas."
    Select-String -Path "$ProjectRoot\CMakeLists.txt","$ProjectRoot\cmake\*" -Pattern "http|execute_process|file\(DOWNLOAD" -ErrorAction SilentlyContinue | Select-Object -First 40
    Confirm-Step "Revisou e deseja compilar?"

    # CMake
    $mysql = if ($WithMySQL) { "ON" } else { "OFF" }
    $BuildDir = Join-Path $ProjectRoot "build"
    New-Item -Path $BuildDir -ItemType Directory -Force | Out-Null
    # Remove cache de gerador anterior (ex.: VS 2022 -> VS 2026)
    $cacheFile = Join-Path $BuildDir "CMakeCache.txt"
    if (Test-Path $cacheFile) {
        $cachedGen = (Select-String -Path $cacheFile -Pattern '^CMAKE_GENERATOR:INTERNAL=' | Select-Object -First 1)
        if ($cachedGen -and $cachedGen.Line -notmatch [regex]::Escape($VsGenerator)) {
            Write-Host "Cache do CMake usa outro gerador ($($cachedGen.Line.Split('=')[1])). Limpando..." -ForegroundColor Yellow
            Remove-Item -Path $cacheFile, (Join-Path $BuildDir "CMakeFiles") -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
    Set-Location $BuildDir
    cmake .. -G "$VsGenerator" -A x64 "-DCMAKE_TOOLCHAIN_FILE=$Toolchain" "-DWITH_MYSQL=$mysql"
    if ($LASTEXITCODE -ne 0) { throw "configuracao do CMake falhou" }
    cmake --build . --config Release
    if ($LASTEXITCODE -ne 0) { throw "compilacao falhou" }

    Write-Host "`nCONCLUIDO. Binarios em: $BuildDir\bin\Release" -ForegroundColor Green
    Write-Host "Nao exponha portas (7171/7172/MySQL) sem firewall configurado." -ForegroundColor Yellow
} catch {
    Write-Error "FALHA: $($_.Exception.Message)"
    Stop-Transcript | Out-Null
    Read-Host "Enter para sair"; exit 1
}
Stop-Transcript | Out-Null
Read-Host "Enter para fechar"
