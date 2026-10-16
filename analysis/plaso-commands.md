# Plaso: what was run and why

Plaso 20260720 runs in Docker (`log2timeline/plaso`). Three tools are used:

| Tool | Job |
|---|---|
| `log2timeline` | Reads the disk image and extracts one event per timestamp into a `.plaso` file |
| `pinfo` | Summarises what is inside a `.plaso` file |
| `psort` | Sorts, de-duplicates and exports events |

## Runs
| Run | Duration | Events | Note |
|---|---|---|---|
| Full (default preset) | about 6 h 46 min | 1,611,685 | Parses everything. Too slow; not imported into Timesketch |
| **Targeted (artifact filters)** | about 5 min | **345,829** | Event logs, USN journal, Prefetch and a few others. **All analysis uses this run** |

## Targeted run
The command is in `run-plaso-targeted.ps1`. In short:

```
docker run --rm -v <evidence>:/data:ro -v <out>:/out log2timeline/plaso `
  log2timeline --partitions all --artifact_filters "<list>" `
  --storage_file /out/<name>.plaso /data/TGT-LAB01.img
```

| Part | Meaning |
|---|---|
| `--rm` | Delete the temporary container afterwards; your files are untouched |
| `-v ...:/data:ro` | Evidence folder, mounted read-only |
| `-v ...:/out` | The only writable place |
| `--partitions all` | Look at every partition (EFI, recovery, Windows) |
| `--artifact_filters` | Collect only the named artifact groups, which is why this took minutes |
| `--storage_file` | Output database of events |

## Contents of the targeted run
| Event type | Count |
|---|---|
| `windows:evtx:record` | 64,312 |
| `fs:ntfs:usn_change` | 279,354 |
| `windows:prefetch:execution` | 555 |
| `fs:stat` | 1,440 |
| `windows:volume:creation` | 168 |
| **Total** | **345,829** |

`psort` wrote 345,057 events (772 duplicates removed). About 345,100 were indexed in Timesketch.

## Notes
- `pinfo` crashes on its warnings table, so use `--sections sessions,events`.
- Most event-log events appear as two rows (creation and modification time of the log record), so 6 rows can be 3 events.
