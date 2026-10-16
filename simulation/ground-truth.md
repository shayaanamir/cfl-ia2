# Ground truth

Times are UTC, 2026-10-09. They were noted by hand from the clock inside the VM while the simulation was run.

| ID | Stage | Action | Time |
|---|---|---|---|
| G1 | Initial access | Log in as `hvac_vendor` (stand-in for the stolen vendor login) | 09:34:33 (upper bound) |
| G2 | Tool staging | Write `pos_collector_sim.ps1` to `C:\TargetSim\Tools` with `Set-Content` | 09:36:24 |
| G3 | Execution | `powershell.exe -ExecutionPolicy Bypass -File ...pos_collector_sim.ps1` | 09:40:02 to 09:40:16 |
| G4 | Collection | Script writes `pos_records.csv` (50 fake rows) | 09:40:16 / 09:40:17 |
| G5 | Staging | Copy the CSV to `Staging\staged_batch_001.csv` | 09:42:10 |
| G6 | Archive | `Compress-Archive` the staged CSV into a ZIP | 09:44:43 |
| G7 | Exfiltration | Copy the ZIP to `ExfilDrop` (a folder, no network) | 09:46:26 |
| G8 | Cleanup | Delete the script, the staged CSV and the staging ZIP | 09:46:36 to 09:47:31 |

## Not part of the attack
| Time | What |
|---|---|
| 09:21:19 | `hvac_vendor` account created (event 4720): lab setup |
| 09:24:31 and 09:28:05 | Two logons that ended in black screens and VM resets |
| 09:49:57 | `labadmin` logs in to verify logs: **post-simulation boundary** |
| 10:00:33 | `Stop-Computer`: final shutdown |

## Why some times are ranges
The initial-access time is when I confirmed the session was active, so it is an upper bound. The execution range runs from when
"run start" was printed to the end of the script. The cleanup range is the gap between the previous command and "cleanup done".
The evidence supplies the exact moments, which is a result in itself.

`ground_truth.csv`, kept on the lab machine, holds the same entries in machine-readable form.
