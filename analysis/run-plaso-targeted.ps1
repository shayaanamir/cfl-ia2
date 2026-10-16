<#
 run-plaso-targeted.ps1  -  targeted Plaso run, pinfo summary and psort export (Docker)

 The artifact-filter list is the one used for the project's targeted run.
 The wrapper layout is reconstructed; compare with your PowerShell history.
 Delete this note before publishing.

 The evidence folder is mounted READ-ONLY (:ro). Output goes to a separate folder, and the
 script stops if the output file already exists, so earlier runs are never overwritten.
#>
param(
    [string]$Evidence = 'C:\ForensicLab\Evidence',
    [string]$OutDir   = 'C:\ForensicLab\Plaso_targeted',
    [string]$Image    = 'TGT-LAB01.img',
    [string]$Base     = 'TGT-LAB01_targeted'
)

$filters = 'NTFSMFTFiles,NTFSUSNJournal,WindowsEventLogs,WindowsEventLogSecurity,WindowsEventLogSystem,WindowsEventLogApplication,WindowsXMLEventLogPowerShell,WindowsPrefetchFiles,WindowsUserRegistryFiles,WindowsSystemRegistryFiles,WindowsAMCacheHveFile,WindowsRecycleBin,WindowsUserJumpLists'

New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
if (Test-Path (Join-Path $OutDir "$Base.plaso")) { throw "$Base.plaso already exists in $OutDir. Pass a different -Base or -OutDir." }

$mounts = @('-v', "${Evidence}:/data:ro", '-v', "${OutDir}:/out")
$plasoImage = 'log2timeline/plaso'

# 1. Extract events (about 5 minutes for the targeted filter set)
docker run --rm @mounts $plasoImage log2timeline --partitions all --artifact_filters $filters --storage_file "/out/$Base.plaso" "/data/$Image"

# 2. Summarise. --sections avoids a crash in pinfo's warnings table.
docker run --rm -v "${OutDir}:/out" $plasoImage pinfo --sections sessions,events "/out/$Base.plaso" | Tee-Object -FilePath (Join-Path $OutDir "$Base.pinfo.txt")

# 3. Sorted, de-duplicated export (one JSON object per line)
docker run --rm -v "${OutDir}:/out" $plasoImage psort -o json_line -w "/out/$Base.jsonl" "/out/$Base.plaso"
