# Reconstructing the 2013 Target Breach: a single-VM forensic timeline lab

A digital forensics project. I rebuilt the *shape* of the 2013 Target breach on one Windows 11 virtual machine,
imaged the disk, and reconstructed the attack from the evidence alone using **Plaso** and **Timesketch**.

> **This is a simulation.** Nothing here is Target's evidence. Target's disk images, memory dumps and logs were never
> published. Every file, account and "card number" in this repository was created in my own isolated lab. All card
> numbers are obviously fake (`TEST-0000-0001`), and the simulation script contains no network code.

## What is real, what was simulated, what was recovered, what is inferred

| Category | What it covers |
|---|---|
| **Real breach (public reporting)** | Stolen credentials of an HVAC vendor (Fazio Mechanical), POS memory-scraping malware (Kaptoxa) on about 40,000 of 60,000 registers, data staged internally and sent out, about 40M cards and 70M customer records, Nov 27 to Dec 15, 2013. Source: Columbia SIPA case study SIPA-21-0021.1 (2021), U.S. Senate Commerce Committee staff report (2014). |
| **Simulated here** | One standard user (`hvac_vendor`) logs in, writes and runs a harmless script that creates a CSV of fake card rows, copies and zips it, copies the ZIP to a folder named `ExfilDrop`, then deletes its tools. Eight stages, ground-truth times logged by hand. |
| **Recovered from the VM** | Logon event, process creation with command line, PowerShell script-block log, file-access events, NTFS USN journal records and Prefetch, all from the disk image only. |
| **Inferred (not directly observed)** | That one operator performed every stage (from the shared logon ID and PowerShell window). That the "exfiltration" was a file copy (there is no network evidence). |

## Result

All times are 2026-10-09, UTC. Ground truth is my own action log.

| Stage | Ground truth | Recovered | Main evidence |
|---|---|---|---|
| Initial access | 09:34:33 (upper bound) | 09:31:44.387 | Event 4624, logon `0x3d3e7` |
| Tool staging | 09:36:24 | 09:36:24.151 to .507 | 4104 `Set-Content`; USN create; 4663 write by `powershell.exe` |
| Execution | 09:40:02 to 09:40:16 | 09:40:12.388 | 4688 `-ExecutionPolicy Bypass -File ...pos_collector_sim.ps1`; Prefetch 09:40:12.401 |
| Collection | 09:40:16 / 09:40:17 | 09:40:16.940 | USN create of `pos_records.csv` |
| Staging | 09:42:10 | 09:42:10.028 | USN create of `staged_batch_001.csv` |
| Archive | 09:44:43 | 09:44:43.910 | USN create of the ZIP in `Staging` |
| Exfiltration | 09:46:26 | 09:46:26.038 | USN create of the ZIP in `ExfilDrop`. **No network evidence** |
| Cleanup | 09:46:36 to 09:47:31 | 09:47:26.518 | USN deletes; 4663 delete by `hvac_vendor` |

All 8 stages were found. Five land within 1 second of my log; the other three fall inside their logged windows.
The same logon ID (`0x3d3e7`) and the same PowerShell window (`0xb38`) wrote, launched and deleted the script.

**Read [LIMITATIONS.md](LIMITATIONS.md) before relying on any of this.**

## Repository layout

```
simulation/   ground-truth.md, setup-audit.ps1, pos_collector_sim.ps1, attack-simulation.ps1
evidence/     acquisition.md, acquire-and-hash.ps1, verify-hash.ps1   (hash only; the image is not in the repo)
analysis/     plaso-commands.md, run-plaso-targeted.ps1, start-timesketch.ps1, timesketch-queries.md
```

The disk image (about 60 GB), the `.plaso` files and the large exports are **not** in this repository. The image's
SHA-256 is published in `evidence/acquisition.md` so anyone holding a copy can verify it.

## Lab and tool versions

| Item | Value |
|---|---|
| Host hypervisor | VirtualBox 7.2.6 |
| Guest | Windows 11 Pro (build 26300), hostname `TGT-LAB01`, UTC, EFI, TPM 2.0, 6 GB RAM, 4 CPUs, 60 GB disk |
| Network | Virtual cable disconnected for the whole simulation |
| Plaso | 20260720 (Docker image `log2timeline/plaso`) |
| Timesketch | Development Docker setup |

## How to reproduce

1. Build a throwaway Windows 11 VM. Create `labadmin` (administrator), then run `simulation/setup-audit.ps1` and snapshot it.
2. Disconnect the network. As `hvac_vendor`, follow `simulation/attack-simulation.ps1`, noting the time of each step.
3. Shut down cleanly, snapshot, and run `evidence/acquire-and-hash.ps1` on the host.
4. Run `analysis/run-plaso-targeted.ps1`, then upload the `.plaso` file to Timesketch and use `analysis/timesketch-queries.md`.

Run the scripts only in a disposable lab VM that you own.

## Sources

- Columbia SIPA (2021). *Target Cyber Attack: A Columbia University Case Study.* SIPA-21-0021.1.
- U.S. Senate Committee on Commerce, Science and Transportation (26 Mar 2014). *A "Kill Chain" Analysis of the 2013 Target Data Breach.*
- Plaso documentation: plaso.readthedocs.io. Timesketch documentation: timesketch.org.
