<#
 pos_collector_sim.ps1  -  harmless stand-in for POS memory-scraping malware

 !! RECONSTRUCTED from the project notes: it writes a CSV of 50 rows such as
 !! TXN00001,<time>,TEST-0000-0001,137 into C:\TargetSim\POS_Data\pos_records.csv.
 !! The original column names and exact text may differ. The script content that
 !! actually ran is recorded in PowerShell event 4104 on the evidence image; replace
 !! this file with that text if you want an exact copy. Delete this banner before publishing.

 What it does NOT do: no memory access, no scraping, no network code, no real card data.
 Every "card number" is an obviously fake TEST- value.
#>

$outDir = 'C:\TargetSim\POS_Data'
$out    = Join-Path $outDir 'pos_records.csv'

New-Item -ItemType Directory -Path $outDir -Force | Out-Null

$rows = foreach ($i in 1..50) {
    $txn  = 'TXN{0:D5}' -f $i
    $time = (Get-Date).ToUniversalTime().ToString('yyyy-MM-dd HH:mm:ss')
    $card = 'TEST-0000-{0:D4}' -f $i
    $amt  = Get-Random -Minimum 5 -Maximum 500
    '{0},{1},{2},{3}' -f $txn, $time, $card, $amt
}

# Header column names are illustrative.
@('transaction_id,timestamp_utc,test_card,amount') + $rows | Set-Content -Path $out -Encoding ASCII
