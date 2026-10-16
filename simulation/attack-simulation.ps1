<#
 attack-simulation.ps1  -  the eight simulated stages, as a runnable sequence

 !! RECONSTRUCTED. During the lab these steps were typed by hand as hvac_vendor in one
 !! PowerShell window (process id 0xb38), with ground-truth times noted separately in
 !! ground_truth.csv. This file lays the same steps out in order so a reader can follow them.
 !! Compare with the VM's PSReadLine history (see README) before calling it the original.
 !! Delete this banner before publishing.

 Run ONLY inside the lab VM, as the standard user hvac_vendor, with the network cable
 disconnected. Everything it touches is under C:\TargetSim and is fake.
#>

$base = 'C:\TargetSim'
function Stamp($label) { Write-Host ("{0}  {1}" -f (Get-Date).ToUniversalTime().ToString('HH:mm:ss.fff'), $label) }

# Stage 1 - initial access: logging in as hvac_vendor IS the stage (event 4624). Nothing to run.

# Stage 2 - tool staging: write the collector script to disk with Set-Content (event 4104, USN create, 4663 write)
Stamp 'tool staging'
$scriptPath = "$base\Tools\pos_collector_sim.ps1"
Set-Content -Path $scriptPath -Value (Get-Content "$PSScriptRoot\pos_collector_sim.ps1" -Raw)

# Stage 3 - execution: run it with a bypassed execution policy (event 4688 with command line, Prefetch)
Stamp 'execution'
powershell.exe -ExecutionPolicy Bypass -File $scriptPath

# Stage 4 - collection: pos_records.csv now exists in POS_Data
Stamp 'collection done'

# Stage 5 - staging: copy the CSV into the Staging folder
Stamp 'staging'
Copy-Item "$base\POS_Data\pos_records.csv" "$base\Staging\staged_batch_001.csv"

# Stage 6 - archive: compress the staged CSV
Stamp 'archive'
Compress-Archive -Path "$base\Staging\staged_batch_001.csv" -DestinationPath "$base\Staging\staged_batch_001.zip"

# Stage 7 - simulated exfiltration: copy the ZIP to the ExfilDrop folder (a folder, not a server)
Stamp 'exfiltration (file copy only)'
Copy-Item "$base\Staging\staged_batch_001.zip" "$base\ExfilDrop\"

# Stage 8 - cleanup: delete the script, the staged CSV and the staging ZIP (USN deletes, 4663 delete)
Stamp 'cleanup'
Remove-Item $scriptPath, "$base\Staging\staged_batch_001.csv", "$base\Staging\staged_batch_001.zip"
Stamp 'cleanup done'
