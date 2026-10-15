# Review failure register: detect, correct, verify

**Status:** living document, started 2026-10-15 with the rule and no entries. **Owner:** Chris Roadfeldt.
**For:** anyone adding a register entry, reading a stage 0 record, or checking that a known failure mode
is covered. The [blueprint](03-blueprint.md) states the principle (principle 13); this document is the
register itself. It follows the test harness's
[generation failure register](https://github.com/croadfeldt/ai-test-harness/blob/main/docs/15-failure-register.md),
which has 28 entries from real runs.

The reviewer will fail in ways nobody predicted. That is not the problem. The problem would be failing
the same way twice, or posting a report that reads as clean because a failure went unnoticed. This
register turns every observed failure into a permanent, verified control.

## The contract

Every entry has six parts, and an entry is not complete until all six exist:

| Part | What it is |
|---|---|
| **Issue** | What the reviewer produced or failed to produce, observable in a run's records |
| **Reason** | Why it matters: what an author, a reviewer or a gate would have been misled into |
| **Cause** | The mechanism, traced to a file and a decision, not a guess |
| **Detector** | The check, in code, that recognizes the failure when it happens again |
| **Correction** | What the reviewer does automatically when the detector fires: drop, retry, a changed input, or an honest entry in the not-checked list |
| **Self-check** | A fixture that reproduces the failure and proves the detector fires and the correction holds; runs in stage 0 of every run |

Two rules follow. **Fail closed:** a run whose self-checks do not all pass produces no statement and no
comments. **Register first:** when a new failure mode appears, its entry and self-check are written
before the correction, so the self-check fails on the old code and passes on the new.

Where a failure cannot be corrected automatically, the correction is an honest entry in the report's
not-checked list, never a quieter failure. "Could not compare the artifact with its source: the tag
does not exist" is a correct result. A report that reads as clean because the comparison silently
did not run is not.

## What counts as a failure here

The harness's failures were mostly about generation: tests that proved nothing. The reviewer's will be
about what it shows and what it leaves out:

- a finding shown that a person rightly dismissed as wrong, in a pattern;
- a finding missed on a reference job;
- a verdict changed by text in the change (prompt injection that got through);
- a check that did not run, reported as if it had;
- evidence bound to the wrong commit;
- anything posted that a policy, a person or a gate could read as approval.

## The register

No entries yet. Entries come only from observed runs, as in the harness: the first will come from the
baseline run on the reference corpus (decision D21). Ids take the form `RF-001`, are stable, and are
never deleted.

| Id | Issue | Reason | Cause | Detector | Correction | Self-check |
|---|---|---|---|---|---|---|

## How the register grows

1. A run produces a failure the register does not name. The evidence is in the run's records; the run is
   kept as it is.
2. The entry is written with all six parts. The self-check is committed first and fails.
3. The correction lands. The self-check passes. The next run's stage 0 record shows the new id.
4. The job that surfaced the failure is rerun with only that correction changed, and the before and after
   are kept side by side.

The register is reviewed with every prompt or model change, because a new model fails in new ways.
