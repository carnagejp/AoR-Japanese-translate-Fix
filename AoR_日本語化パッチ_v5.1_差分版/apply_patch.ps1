# AoR Japanese retranslation patch applier (Windows PowerShell 5.1 compatible)
# Rebuilds the patched resources.assets from the user's own original file.
# Exit codes: 0=ok, 2=bad source (version mismatch), 3=patch data broken, 4=io error
param(
    [Parameter(Mandatory=$true)][string]$Source,
    [Parameter(Mandatory=$true)][string]$Output,
    [Parameter(Mandatory=$true)][string]$PatchDir
)
$ErrorActionPreference = 'Stop'
$opsPath  = Join-Path $PatchDir 'patch_ops.txt'
$dataPath = Join-Path $PatchDir 'patch_data.bin.gz'
try {
    $lines = [System.IO.File]::ReadAllLines($opsPath)
    if ($lines[0] -ne 'AORPATCH 1') { Write-Host '[ERROR] patch_ops.txt format'; exit 3 }
    $srcInfo = $lines[1].Split(' ')
    $tgtInfo = $lines[2].Split(' ')

    Write-Host 'Checking original file (SHA-256)...'
    $srcLen = (Get-Item -LiteralPath $Source).Length
    if ($srcLen -ne [int64]$srcInfo[1]) { Write-Host ("[ERROR] source size {0} <> expected {1}" -f $srcLen, $srcInfo[1]); exit 2 }
    $srcHash = (Get-FileHash -LiteralPath $Source -Algorithm SHA256).Hash
    if ($srcHash -ne $srcInfo[2]) { Write-Host '[ERROR] source hash mismatch'; exit 2 }

    Write-Host 'Building patched file...'
    $src = [System.IO.File]::OpenRead($Source)
    $out = New-Object System.IO.FileStream($Output, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write, [System.IO.FileShare]::None, 1048576)
    $gzFile = [System.IO.File]::OpenRead($dataPath)
    $gz = New-Object System.IO.Compression.GZipStream($gzFile, [System.IO.Compression.CompressionMode]::Decompress)
    $buf = New-Object byte[] 1048576
    try {
        for ($i = 3; $i -lt $lines.Length; $i++) {
            $p = $lines[$i].Split(' ')
            if ($p[0] -eq 'C') {
                $src.Position = [int64]$p[1]
                $rem = [int64]$p[2]
                while ($rem -gt 0) {
                    $want = [int][Math]::Min([int64]$buf.Length, $rem)
                    $n = $src.Read($buf, 0, $want)
                    if ($n -le 0) { throw 'unexpected end of source' }
                    $out.Write($buf, 0, $n); $rem -= $n
                }
            } elseif ($p[0] -eq 'A') {
                $rem = [int64]$p[1]
                while ($rem -gt 0) {
                    $want = [int][Math]::Min([int64]$buf.Length, $rem)
                    $n = $gz.Read($buf, 0, $want)
                    if ($n -le 0) { throw 'unexpected end of patch data' }
                    $out.Write($buf, 0, $n); $rem -= $n
                }
            }
        }
    } finally {
        $out.Close(); $src.Close(); $gz.Close(); $gzFile.Close()
    }

    Write-Host 'Verifying patched file (SHA-256)...'
    $outLen = (Get-Item -LiteralPath $Output).Length
    $outHash = (Get-FileHash -LiteralPath $Output -Algorithm SHA256).Hash
    if (($outLen -ne [int64]$tgtInfo[1]) -or ($outHash -ne $tgtInfo[2])) {
        Remove-Item -LiteralPath $Output -ErrorAction SilentlyContinue
        Write-Host '[ERROR] result hash mismatch (patch data may be broken)'; exit 3
    }
    Write-Host 'OK'
    exit 0
} catch {
    Write-Host ('[ERROR] ' + $_.Exception.Message)
    if (Test-Path -LiteralPath $Output) { Remove-Item -LiteralPath $Output -ErrorAction SilentlyContinue }
    exit 4
}
