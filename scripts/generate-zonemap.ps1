param(
    [Parameter(Mandatory = $true)]
    [string]$InputPath,

    [Parameter(Mandatory = $false)]
    [string]$OutputPath,

    [Parameter(Mandatory = $false)]
    [int]$LineThreshold = 210,

    [Parameter(Mandatory = $false)]
    [int]$MinZonePixels = 40
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Drawing

function Get-ZoneColor {
    param([int]$Index)

    $value = $Index + 1
    $r = $value -band 0xFF
    $g = ($value -shr 8) -band 0xFF
    $b = ($value -shr 16) -band 0xFF

    if ($r -eq 0 -and $g -eq 0 -and $b -eq 0) {
        $r = 1
    }

    return [System.Drawing.Color]::FromArgb(255, $r, $g, $b)
}

if (-not (Test-Path -LiteralPath $InputPath)) {
    throw "No existe el archivo de entrada: $InputPath"
}

if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    $directory = Split-Path -Parent $InputPath
    $name = [System.IO.Path]::GetFileNameWithoutExtension($InputPath)
    $OutputPath = Join-Path $directory "${name}_zonemap.png"
}

$inputBitmap = New-Object System.Drawing.Bitmap($InputPath)
$width = $inputBitmap.Width
$height = $inputBitmap.Height

$zoneBitmap = New-Object System.Drawing.Bitmap($width, $height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$visited = New-Object 'bool[,]' $width, $height
$lineMask = New-Object 'bool[,]' $width, $height

for ($y = 0; $y -lt $height; $y++) {
    for ($x = 0; $x -lt $width; $x++) {
        $pixel = $inputBitmap.GetPixel($x, $y)
        $brightness = ($pixel.R + $pixel.G + $pixel.B) / 3
        if ($pixel.A -gt 0 -and $brightness -lt $LineThreshold) {
            $lineMask[$x, $y] = $true
            $zoneBitmap.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(0, 0, 0, 0))
            $visited[$x, $y] = $true
        } else {
            $lineMask[$x, $y] = $false
            $zoneBitmap.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(0, 0, 0, 0))
        }
    }
}

$neighbors = @(
    @(1, 0),
    @(-1, 0),
    @(0, 1),
    @(0, -1)
)

$zoneIndex = 0
$buffer = New-Object System.Collections.Generic.List[System.Drawing.Point]

for ($y = 0; $y -lt $height; $y++) {
    for ($x = 0; $x -lt $width; $x++) {
        if ($visited[$x, $y]) {
            continue
        }

        $queue = New-Object System.Collections.Generic.Queue[System.Drawing.Point]
        $queue.Enqueue((New-Object System.Drawing.Point($x, $y)))
        $visited[$x, $y] = $true
        $buffer.Clear()

        while ($queue.Count -gt 0) {
            $point = $queue.Dequeue()
            $buffer.Add($point)

            foreach ($delta in $neighbors) {
                $nx = $point.X + $delta[0]
                $ny = $point.Y + $delta[1]

                if ($nx -lt 0 -or $ny -lt 0 -or $nx -ge $width -or $ny -ge $height) {
                    continue
                }

                if ($visited[$nx, $ny] -or $lineMask[$nx, $ny]) {
                    continue
                }

                $visited[$nx, $ny] = $true
                $queue.Enqueue((New-Object System.Drawing.Point($nx, $ny)))
            }
        }

        if ($buffer.Count -lt $MinZonePixels) {
            continue
        }

        $zoneColor = Get-ZoneColor -Index $zoneIndex
        foreach ($point in $buffer) {
            $zoneBitmap.SetPixel($point.X, $point.Y, $zoneColor)
        }
        $zoneIndex++
    }
}

$outputDirectory = Split-Path -Parent $OutputPath
if (-not [string]::IsNullOrWhiteSpace($outputDirectory)) {
    New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null
}

$zoneBitmap.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)

$inputBitmap.Dispose()
$zoneBitmap.Dispose()

Write-Output "Zone map generado: $OutputPath"
Write-Output "Zonas detectadas: $zoneIndex"
