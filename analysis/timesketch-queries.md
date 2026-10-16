# Timesketch: queries, tags and the story

One timeline was loaded: `targeted-evtx-usn-prefetch` (the `.plaso` file, about 198 MB). Start the container's workers first with
`start-timesketch.ps1`.

## Queries
Queries marked **checked** returned the stated counts in this project. The others use standard field names and are
starting points; confirm the exact wording against the Explore view's field list.

| Purpose | Query | Status |
|---|---|---|
| Find the script by name | `message:"pos_collector_sim.ps1"` | **checked**: 48 events. A bare word search failed with "query too complex", so use `message:"..."` |
| Logons | `event_identifier:4624` | starting point |
| Process creation | `event_identifier:4688` | starting point |
| Script-block log | `event_identifier:4104` | starting point |
| File access | `event_identifier:4663` | starting point |
| Prefetch | `data_type:"windows:prefetch:execution"` | starting point |
| USN journal | `data_type:"fs:ntfs:usn_change"` | starting point |
| Staging stage only | `tag:staging AND NOT tag:tool-staging` | **checked**: `tag:staging` also matches `tool-staging` |

## Tags applied
| Tag | Events |
|---|---|
| initial-access | 2 |
| black-screen-restart | 4 |
| tool-staging | 5 |
| execution | 5 |
| collection | 1 |
| staging | 1 |
| archive | 1 |
| exfiltration | 1 |
| cleanup | 7 |

## Story
The saved Story has eight stage sections plus a "Limits" section, in kill-chain order, each embedding its tagged events.
Export it from the Timesketch UI and add it here as `story.md`.
