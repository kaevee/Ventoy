$ErrorActionPreference = "Stop"

$OutDir = "$PSScriptRoot\..\build"
if (!(Test-Path $OutDir)) {
    New-Item -ItemType Directory -Path $OutDir | Out-Null
}

$Variants = @("base", "docker")

foreach ($Variant in $Variants) {
    Write-Host "Building $Variant variant..."
    $VariantDir = "$PSScriptRoot\..\configs\ubuntu-$Variant"
    $ImgName = "$Variant.img"
    $ImgPath = "$OutDir\$ImgName"

    Push-Location $VariantDir
    
    # Check if WSL is available
    try {
        wsl --status | Out-Null
    } catch {
        Write-Error "WSL is not installed or not running. Please install WSL (wsl --install) to build the .img files on Windows."
        Pop-Location
        exit 1
    }

    # Remove old image if it exists
    if (Test-Path $ImgName) { Remove-Item $ImgName }

    Write-Host "  -> Creating VFAT filesystem..."
    wsl truncate -s 2M $ImgName
    wsl /sbin/mkfs.vfat -n cidata $ImgName
    
    Write-Host "  -> Injecting cloud-init data..."
    wsl mcopy -i $ImgName user-data meta-data ::
    
    Move-Item $ImgName $ImgPath -Force
    Pop-Location

    Write-Host "Successfully built $ImgPath`n"
}

Write-Host "Done! You can now copy configs\ventoy.json and the .img files in the build\ directory to your Ventoy USB."
