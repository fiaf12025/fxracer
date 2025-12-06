<#
verify-environment.ps1
Comprueba los requisitos y el entorno para ejecutar la app Electron/PWA "fxracer".
Genera un resumen en pantalla y un archivo `verify-report.txt` en la misma carpeta.

Uso:
  .\verify-environment.ps1           # Ejecuta comprobaciones básicas
  .\verify-environment.ps1 -RunSetup  # Ejecuta comprobaciones y pregunta para lanzar setup-and-run.ps1

Este script debe ejecutarse en la carpeta del proyecto (donde están index.html, package.json, setup-and-run.ps1).
#>

param(
    [switch]$RunSetup
)

function Info($m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Ok($m){ Write-Host "[OK]   $m" -ForegroundColor Green }
function Warn($m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Err($m){ Write-Host "[ERR]  $m" -ForegroundColor Red }

$report = @()
function RAdd($level, $text){ $report += "[$level] $text" }

# Helper para comprobar comandos
function Check-Command($cmd, $args='--version'){
    try{
        $c = Get-Command $cmd -ErrorAction Stop
        # intentar ejecutar version
        $out = & $cmd $args 2>&1
        $ver = ($out | Select-Object -First 1).ToString()
        Ok("$cmd -> $ver")
        RAdd('OK', "$cmd -> $ver")
        return @{ ok=$true; info=$ver }
    }catch{
        Warn("$cmd no encontrado o no devuelve versión: $_")
        RAdd('WARN', "$cmd no encontrado o no devuelve versión: $_")
        return @{ ok=$false; info=$null }
    }
}

# Inicio
$cwd = Get-Location
Info "Verificando entorno en: $cwd"
RAdd('INFO', "Carpeta: $cwd")

# Comprobar espacio en disco (unidad actual)
$drive = $cwd.Path.Substring(0,1)
try{
    $fs = Get-PSDrive $drive
    $freeGB = [math]::Round($fs.Free/1GB,2)
    Ok("Espacio libre en $drive: ${freeGB} GB")
    RAdd('OK', "Espacio libre en $drive: ${freeGB} GB")
}catch{
    Warn("No se pudo determinar espacio en disco: $_")
    RAdd('WARN', "No se pudo determinar espacio en disco: $_")
}

# Comprobar Node y npm
$node = Check-Command 'node' '-v'
$npm = Check-Command 'npm' '-v'

# Comprobar Python (para servidor local test)
$py = $null
try{
    $out = python --version 2>&1
    Ok("python -> $out")
    RAdd('OK', "python -> $out")
    $py = @{ ok=$true; info=$out }
}catch{
    try{
        $out = py -3 --version 2>&1
        Ok("py -> $out")
        RAdd('OK', "py -> $out")
        $py = @{ ok=$true; info=$out }
    }catch{
        Warn("python/py no encontrado")
        RAdd('WARN', "python/py no encontrado")
        $py = @{ ok=$false; info=$null }
    }
}

# Comprobar git
$git = Check-Command 'git' '--version'

# Comprobar presencia de archivos importantes
$needed = @('index.html','package.json','setup-and-run.ps1','sw.js','manifest.webmanifest')
foreach($f in $needed){
    if(Test-Path $f){ Ok("$f presente") ; RAdd('OK', "$f presente") }
    else { Warn("$f NO existe en la carpeta") ; RAdd('WARN', "$f NO existe en la carpeta") }
}

# Revisar si setup-and-run.ps1 está bloqueado por zona (Zone.Identifier)
$blocked = $false
try{
    $streams = Get-Item -Path '.\setup-and-run.ps1' -Stream * -ErrorAction Stop
    $zone = $streams | Where-Object { $_.Stream -like 'Zone.Identifier' }
    if($zone){
        Warn('setup-and-run.ps1 tiene Zone.Identifier -> archivo marcado como descargado de internet (bloqueado)')
        RAdd('WARN', 'setup-and-run.ps1 tiene Zone.Identifier -> bloqueado')
        $blocked = $true
    } else {
        Ok('setup-and-run.ps1 no parece estar bloqueado por Zone.Identifier')
        RAdd('OK','setup-and-run.ps1 no bloqueado')
    }
}catch{
    Warn('No se pudieron leer los streams del archivo (PowerShell puede no soportar -Stream).')
    RAdd('WARN','No se pudieron leer streams del archivo')
}

# Comprobar fxracer-app.zip
if(Test-Path '.\fxracer-app.zip'){ Ok('fxracer-app.zip presente') ; RAdd('OK','fxracer-app.zip presente') } else { Warn('fxracer-app.zip NO presente') ; RAdd('WARN','fxracer-app.zip NO presente') }

# Recomendar acción para npm si falta
if(-not $npm.ok){
    Err('npm no encontrado. Para continuar instala Node.js desde https://nodejs.org/ y vuelve a ejecutar este script.')
    RAdd('ERR','npm no encontrado. Instala Node.js y vuelve a ejecutar.')
}

# Resumen y archivo de reporte
$reportFile = Join-Path $cwd 'verify-report.txt'
$report | Out-File -FilePath $reportFile -Encoding UTF8
Info "Reporte generado: $reportFile"

# Si se pidió ejecutar setup-and-run, preguntar al usuario
if($RunSetup){
    if(-not $npm.ok){
        Err('No se puede ejecutar setup: npm no está disponible.')
        exit 2
    }
    $ans = Read-Host '¿Deseas ejecutar ahora .\setup-and-run.ps1 para instalar dependencias y arrancar la app? (s/N)'
    if($ans -match '^(s|S|y|Y)$'){
        Info 'Ejecutando setup-and-run.ps1...'
        & .\setup-and-run.ps1
    } else {
        Info 'Operación cancelada por el usuario.'
    }
}

Info 'Comprobaciones finalizadas.'

# Estado de salida: 0 si npm existe, 1 si no
if($npm.ok){ exit 0 } else { exit 1 }
