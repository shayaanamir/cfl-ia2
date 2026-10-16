<#
 verify-hash.ps1  -  check the image against its saved SHA-256 value (read-only, safe to re-run)
 Usage: .\verify-hash.ps1 -Image C:\ForensicLab\Evidence\TGT-LAB01.img
#>
param([Parameter(Mandatory)][string]$Image)

$expected = ((Get-Content "$Image.sha256" -TotalCount 1) -split '\s+')[0].ToUpper()
$actual   = (Get-FileHash -Algorithm SHA256 $Image).Hash.ToUpper()

"Expected : $expected"
"Actual   : $actual"
if ($expected -eq $actual) { 'RESULT   : MATCH' } else { 'RESULT   : MISMATCH'; exit 1 }
Get-Item $Image | Format-List Name, Length, IsReadOnly, LastWriteTime
