<#
 acquire-and-hash.ps1  -  turn the post-simulation snapshot into a raw image and fingerprint it

 !! RECONSTRUCTED from the acquisition notes (study guide, section 5). Check it against your
 !! PowerShell history and acquisition_log.txt. Delete this banner before publishing.

 Run on the HOST (not in the VM), after the VM has been shut down cleanly and snapshot
 03-Post-Simulation has been taken.

 This writes a NEW file only; VBoxManage refuses to overwrite an existing target.
#>

param(
    [string]$Vbox     = 'C:\Program Files\Oracle\VirtualBox\VBoxManage.exe',
    [string]$DiskUuid = '{d687123f-39a6-4d9b-ba69-a430860b2b87}',   # disk that represents the snapshot
    [string]$OutDir   = 'C:\ForensicLab\Evidence',
    [string]$Name     = 'TGT-LAB01.img'
)

$img = Join-Path $OutDir $Name
$log = Join-Path $OutDir 'acquisition_log.txt'
New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
if (Test-Path $img) { throw "$img already exists. Choose another -Name; this script never overwrites evidence." }

function Log($m) { ('{0}  {1}' -f (Get-Date).ToUniversalTime().ToString('yyyy-MM-dd HH:mm:ss'), $m) | Tee-Object -FilePath $log -Append }

Log "Cloning $DiskUuid to RAW image $img"
& $Vbox clonemedium disk $DiskUuid $img --format RAW

$item = Get-Item $img
Log ("Image size: {0} bytes" -f $item.Length)

$hash = Get-FileHash -Algorithm SHA256 $img
Log "SHA-256 (acquisition): $($hash.Hash)"
"$($hash.Hash)  $Name" | Set-Content -Path "$img.sha256" -Encoding ASCII

# Verify a second time, then set the read-only attribute (a guard against accidents, not real protection)
$again = Get-FileHash -Algorithm SHA256 $img
if ($again.Hash -eq $hash.Hash) { Log 'Re-verification: MATCH' } else { Log 'Re-verification: MISMATCH'; throw 'Hash mismatch' }
Set-ItemProperty -Path $img -Name IsReadOnly -Value $true
Log 'Read-only attribute set'
