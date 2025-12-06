<#
setup-and-run.ps1
Script de conveniencia para instalar dependencias y ejecutar la app Electron.
Uso:
  .\setup-and-run.ps1         # instala dependencias y ejecuta npm start
  .\setup-and-run.ps1 -Pack   # instala dependencias y ejecuta npm run pack
#>

param(
    [switch]$Pack
)

function Write-Info([string]$m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Write-Err([string]$m){ Write-Host "[ERROR] $m" -ForegroundColor Red }

Write-Info "Comprobando Node.js y npm..."
$node = Get-Command node -ErrorAction SilentlyContinue
$npm = Get-Command npm -ErrorAction SilentlyContinue

if(-not $node -or -not $npm){
    Write-Err "Node.js y/o npm no están instalados o no están en PATH."
    Write-Host ""
    Write-Host "Instala Node.js (incluye npm): https://nodejs.org/"
    Write-Host "Después, vuelve a ejecutar este script en PowerShell."
    exit 1
}

Write-Info "Instalando dependencias (npm install)..."
npm install
if($LASTEXITCODE -ne 0){
    Write-Err "npm install falló (exit code $LASTEXITCODE). Revisa la salida anterior."
    exit $LASTEXITCODE
}

if($Pack){
    Write-Info "Empaquetando la app (npm run pack)..."
    npm run pack
    if($LASTEXITCODE -ne 0){
        Write-Err "npm run pack falló (exit code $LASTEXITCODE)."
        exit $LASTEXITCODE
    }
    Write-Info "Empaquetado completado. Revisa la carpeta 'dist'."
} else {
    Write-Info "Iniciando la app (npm start)..."
    npm start
}
