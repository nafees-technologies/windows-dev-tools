# install-or-update-terraform.ps1
# Installs or updates Terraform for Windows (64-bit)

Write-Host "Checking latest Terraform release..." -ForegroundColor Cyan
$Latest = Invoke-RestMethod https://api.github.com/repos/hashicorp/terraform/releases/latest
$LatestVersion = $Latest.tag_name.TrimStart("v")
$Dest = "C:\terraform"
$TerraformExe = Join-Path $Dest "terraform.exe"

# Check installed version
$InstalledVersion = $null
if (Test-Path $TerraformExe) {
    $InstalledVersion = (& $TerraformExe -v) -split "`n" | Select-String -Pattern "^Terraform v" | ForEach-Object { $_.ToString().Split(" ")[1] }
}

if ($InstalledVersion -and ($InstalledVersion -eq $LatestVersion)) {
    Write-Host "Terraform v$InstalledVersion is already up to date." -ForegroundColor Green
    exit
}

Write-Host "Downloading Terraform v$LatestVersion..." -ForegroundColor Yellow
$Url = "https://releases.hashicorp.com/terraform/$LatestVersion/terraform_${LatestVersion}_windows_amd64.zip"
Invoke-WebRequest $Url -OutFile "$env:TEMP\terraform.zip"

Write-Host "Extracting to $Dest..." -ForegroundColor Yellow
if (-Not (Test-Path $Dest)) { New-Item -ItemType Directory -Path $Dest | Out-Null }
Expand-Archive "$env:TEMP\terraform.zip" -DestinationPath $Dest -Force

# Add to PATH if not already there
$CurrentPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
if ($CurrentPath -notlike "*$Dest*") {
    setx PATH "$CurrentPath;$Dest" /M | Out-Null
    Write-Host "Added $Dest to PATH." -ForegroundColor Yellow
}

Write-Host "Terraform v$LatestVersion installed successfully in $Dest." -ForegroundColor Green
Write-Host "Please restart your terminal to use the 'terraform' command."
