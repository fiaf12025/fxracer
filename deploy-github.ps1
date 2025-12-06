# Script para publicar el proyecto en GitHub Pages

param(
    [string]$RepoURL = ""
)

function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-ErrorMsg { Write-Host $args -ForegroundColor Red }
function Write-Info { Write-Host $args -ForegroundColor Cyan }

Write-Info "=== Iniciando deploy a GitHub Pages ==="
Write-Info ""

Write-Info "1. Verificando Git..."
try {
    $gitVersion = git --version
    Write-Success "Git instalado: $gitVersion"
} catch {
    Write-ErrorMsg "Git no esta instalado"
    exit 1
}

Write-Info ""

if ([string]::IsNullOrWhiteSpace($RepoURL)) {
    Write-Info "2. Ingresa la URL de tu repositorio GitHub"
    Write-Info "   (ej: https://github.com/tu_usuario/fxracer.git)"
    $RepoURL = Read-Host "   URL"
    
    if ([string]::IsNullOrWhiteSpace($RepoURL)) {
        Write-ErrorMsg "Error: URL vacia"
        exit 1
    }
}

Write-Success "URL configurada: $RepoURL"
Write-Info ""

Write-Info "3. Inicializando repositorio Git..."
if (Test-Path .git) {
    Write-Info "   (repositorio ya existe)"
} else {
    git init
    Write-Success "Repositorio inicializado"
}

Write-Info ""

Write-Info "4. Anadiendo archivos..."
git add .
Write-Success "Archivos anadidos"

Write-Info ""

Write-Info "5. Creando commit..."
$commitMsg = "Deploy: Campeonato Mundial de fxracer"
git commit -m $commitMsg

Write-Info ""

Write-Info "6. Configurando rama main..."
git branch -M main
Write-Success "Rama main configurada"

Write-Info ""

Write-Info "7. Conectando con GitHub..."
$remoteExists = git config --get remote.origin.url
if ([string]::IsNullOrWhiteSpace($remoteExists)) {
    git remote add origin $RepoURL
    Write-Success "Remote origin anadido"
} else {
    git remote set-url origin $RepoURL
    Write-Success "Remote origin actualizado"
}

Write-Info ""

Write-Info "8. Subiendo a GitHub..."
git push -u origin main

if ($LASTEXITCODE -eq 0) {
    Write-Success "Push completado"
} else {
    Write-ErrorMsg "Error en push"
    exit 1
}

Write-Info ""
Write-Success "=== Publicacion completada ==="
Write-Info ""
Write-Info "Proximos pasos:"
Write-Info "1. Ve a https://github.com/TU_USUARIO/fxracer/settings/pages"
Write-Info "2. Selecciona Deploy from a branch -> main"
Write-Info "3. Guarda los cambios"
Write-Info ""
Write-Info "Tu sitio estara en: https://TU_USUARIO.github.io/fxracer"
