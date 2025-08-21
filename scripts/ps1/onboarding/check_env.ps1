param(
[string]$MinPython = "3.11"
)
function Compare-Version($a,$b){
$A = [version]$a; $B = [version]$b; return $A.CompareTo($B)
}
$ok = $true
Write-Host "== Verification pre-requis ==" -ForegroundColor Cyan

# Python

try { $pyV = (python -c "import sys; print('.'.join(map(str, sys.version_info[:3])))") } catch { $pyV = $null }
if (-not $pyV) { Write-Host "Python introuvable" -ForegroundColor Red; $ok=$false } else {
if ((Compare-Version $pyV $MinPython) -lt 0) { Write-Host "Python $pyV < $MinPython" -ForegroundColor Red; $ok=$false } else { Write-Host "Python $pyV OK" -ForegroundColor Green }
}

# pip

try { pip --version | Out-Null; Write-Host "pip OK" -ForegroundColor Green } catch { Write-Host "pip introuvable" -ForegroundColor Yellow }

# git

try { git --version | Out-Null; Write-Host "git OK" -ForegroundColor Green } catch { Write-Host "git introuvable" -ForegroundColor Yellow }

# Optionnels

try { docker --version | Out-Null; Write-Host "docker present (optionnel)" -ForegroundColor DarkGreen } catch {}
try { node --version | Out-Null; Write-Host "node present (optionnel)" -ForegroundColor DarkGreen } catch {}
try { mkdocs --version | Out-Null; Write-Host "mkdocs present (optionnel)" -ForegroundColor DarkGreen } catch {}
if (-not $ok) { exit 2 } else { exit 0 }
