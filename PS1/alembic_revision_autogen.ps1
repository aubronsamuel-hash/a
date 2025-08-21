param([Parameter(Mandatory=$true)][string]$Message)
$ErrorActionPreference = "Stop"
alembic revision --autogenerate -m $Message
