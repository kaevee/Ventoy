param(
    [Parameter(Mandatory=$true)]
    [string]$Drive
)

$ErrorActionPreference = "Stop"

$Drive = $Drive.TrimEnd("\")
if (!(Test-Path $Drive)) {
    Write-Error "Drive '$Drive' not found."
    exit 1
}

$Repo = "kaevee/Ventoy"
$ApiUrl = "https://api.github.com/repos/$Repo/releases/latest"

Write-Host "Fetching latest release from $Repo..."
$Release = Invoke-RestMethod -Uri $ApiUrl
$Tag = $Release.tag_name
Write-Host "Found release: $Tag"

$VentoyDir = "$Drive\ventoy"
$AutoinstallDir = "$VentoyDir\autoinstall"
New-Item -ItemType Directory -Force -Path $AutoinstallDir | Out-Null

foreach ($Asset in $Release.assets) {
    $Name = $Asset.name
    $Url = $Asset.browser_download_url

    if ($Name -eq "ventoy.json") {
        $Dest = "$VentoyDir\ventoy.json"
    } else {
        $Dest = "$AutoinstallDir\$Name"
    }

    Write-Host "  -> Downloading $Name..."
    Invoke-WebRequest -Uri $Url -OutFile $Dest
}

Write-Host "`nInstalled Ventoy autoinstall ($Tag) to $Drive"
Write-Host "  $VentoyDir\ventoy.json"
Write-Host "  $AutoinstallDir\base.img"
Write-Host "  $AutoinstallDir\docker.img"

# Check for the expected ISO
$IsoName = "ubuntu-26.04-live-server-amd64.iso"
$IsoPath = "$Drive\$IsoName"
if (Test-Path $IsoPath) {
    Write-Host "`nISO found: $IsoPath"
} else {
    Write-Warning "ISO not found: $IsoPath"
    Write-Host "Download it from: https://ubuntu.com/download/server"
    Write-Host "Then copy it to: $Drive\$IsoName"
}
