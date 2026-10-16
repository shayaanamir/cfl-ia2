# Evidence acquisition and integrity

## Steps
1. The VM was shut down cleanly (hibernate off) and snapshot `03-Post-Simulation` was taken. This is the evidence state.
2. VirtualBox showed which disk file represented that snapshot (`{d687123f-39a6-4d9b-ba69-a430860b2b87}.vdi`).
3. `VBoxManage clonemedium` merged the snapshot chain into one **raw** image, `TGT-LAB01.img`.
4. SHA-256 was computed and saved. It was recomputed and matched, the file was set read-only and unregistered from VirtualBox (the file was kept).
5. After the host PC restarted, the hash was recomputed again and matched again.

## Fingerprint
| Item | Value |
|---|---|
| File | `TGT-LAB01.img` (raw) |
| Size | 64,424,509,440 bytes (61,440 MiB) |
| SHA-256 | `C0CE65AEC356B5FE9764034F95FAB69A0A92AB79503EBA01100402575FB15CFA` |

Verify a copy with `evidence/verify-hash.ps1`.

## Honest limits
- This is a **logical copy of a virtual disk**, not a write-blocked acquisition of physical media.
- The read-only attribute is a guard against accidents, not cryptographic protection. The hash is the real proof.
- Plaso read the image through a Docker mount marked read-only (`:ro`).

## Scripts
`acquire-and-hash.ps1` performs steps 3 and 4 and refuses to overwrite an existing image.
