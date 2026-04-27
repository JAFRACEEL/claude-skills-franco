# install.ps1 - Instala skills de este repo en ~/.claude/skills/

$ErrorActionPreference = "Stop"
$repoPath = $PSScriptRoot
$skillsDest = "$env:USERPROFILE\.claude\skills"

Write-Host ""
Write-Host "=== Instalador de Claude Skills (Franco) ===" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path $skillsDest)) {
    New-Item -ItemType Directory -Force -Path $skillsDest | Out-Null
    Write-Host "Carpeta de skills creada: $skillsDest" -ForegroundColor Green
}

$skillFolders = Get-ChildItem -Path $repoPath -Directory | Where-Object {
    $_.Name -notmatch "^\." -and $_.Name -ne "node_modules"
}

if ($skillFolders.Count -eq 0) {
    Write-Host "No se encontraron skills en el repo." -ForegroundColor Yellow
    exit 0
}

Write-Host "Skills detectadas en el repo:" -ForegroundColor Cyan
$skillFolders | ForEach-Object { Write-Host "  - $($_.Name)" }
Write-Host ""

$confirm = Read-Host "Instalar estas skills en $skillsDest ? (S/N)"
if ($confirm -ne "S" -and $confirm -ne "s") {
    Write-Host "Instalacion cancelada." -ForegroundColor Red
    exit 0
}

foreach ($skill in $skillFolders) {
    $src = $skill.FullName
    $dst = Join-Path $skillsDest $skill.Name
    
    if (Test-Path $dst) {
        Write-Host "  Sobrescribiendo: $($skill.Name)" -ForegroundColor Yellow
        Remove-Item -Recurse -Force $dst
    } else {
        Write-Host "  Instalando: $($skill.Name)" -ForegroundColor Green
    }
    
    Copy-Item -Recurse -Force $src $dst
}

Write-Host ""
Write-Host "Instalacion completa." -ForegroundColor Green
Write-Host ""
