# Limitations

Read these before quoting a result from this project.

## About the simulation
- **One VM plays every role.** The real breach had a vendor portal, an internal server, thousands of registers and an
  outside server. Here there is one Windows 11 machine and two accounts, so there is **no lateral movement**,
  **no privilege escalation** and **no real malware** (no memory scraping, no exploit).
- **The "exfiltration" is a file copy** into a folder named `ExfilDrop`. The network cable was disconnected the whole time, so
  there is **no network evidence** and none could exist.
- **Ground-truth times were written by hand.** Initial access (09:34:33) is only an upper bound; the execution and cleanup entries are ranges.

## About the evidence
- **The image is a logical copy of a virtual disk** made with VirtualBox's own tool. It is not a write-blocked acquisition of physical media.
  The read-only attribute only guards against accidents. The SHA-256 match is the real integrity evidence.
- **Two unclean restarts and an extra logon.** Two `hvac_vendor` logons ended in black screens and VM resets before the working session. They are not attack activity.
- **Our own checks left traces.** The `labadmin` verification session and the final shutdown appear after the 09:49:57 boundary.

## About the analysis
- **Only one of eight PowerShell Prefetch run times corroborates the script run.** Plaso emits one event per stored run time and every one repeats the same text.
- **One Kernel-Power 41 event is stamped about 5 h 30 min late**, and a single event 41 covers two unclean shutdowns. The cause is unexplained.
- **The `winevtx` parser reported 287 recovery warnings** that were not examined.
- **The targeted run and the full run differ by 82 events** for the shared artifact types; I did not establish why.
- **Access-mask meanings** (read, write, delete) follow standard conventions and were not separately verified on this VM.
- **The full Plaso run was not imported into Timesketch.** All analysis is based on the targeted run.
