# Lister
powershell -File .\PS1\ccadmin.ps1 -Command list

# Creer user
powershell -File .\PS1\ccadmin.ps1 -Command create -Username alice -Password pw

# Promouvoir
powershell -File .\PS1\ccadmin.ps1 -Command promote -Username alice

# Reset password
powershell -File .\PS1\ccadmin.ps1 -Command reset-password -Username alice -NewPassword newpw
