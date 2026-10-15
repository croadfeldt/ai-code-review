# AI Code Review: the blueprint

**Status:** Draft v0.1, 2026-10-14. **Owner:** Chris Roadfeldt.
**For:** engineers and architects deciding whether to build, run or adopt this. Three pages.
**Behind it:** [the research](research/README.md) with every source, the
[decision record](21-decision-record.md) with the positions settled, and the
[target goals](target-goals.md) it is judged against.

## What it is

A reviewer that reads every change entering the software supply chain and hands the person who reviews it
grounded findings and a signed record. It covers our own pull requests, changes written by coding agents,
the code behind a dependency version bump, and vendored, forked and generated code. For each change it
gives a reproducible answer to four questions, and says what it checked and what it did not.

1. **Does it do what it says?** The description, linked issue and commit messages against the diff.
2. **Is it safe to admit?** Security defects; malicious, obfuscated or invisible content; an artifact that
   does not match its source; secrets; a licence change.
3. **Does it fit?** The repository's own conventions, design and API contracts.
4. **Is it proven?** What the test harness's evidence says about the change.

The reviewer reviews. It never approves, merges, edits code or changes policy. A person owns every merge
(decision D1).

## Scope

| In scope | Trigger | What is reviewed |
|---|---|---|
| First-party changes | Pull request opened or updated, push to its branch | The diff, against the repository's conventions and the harness's evidence |
| Agent-authored changes | The same, with attribution where recorded (Agent Trace, git-ai) | As first-party, with the intent check weighted first |
| Dependency bumps | Lockfile diff, Renovate or Dependabot pull request | The installed artifact at both versions, the source at the claimed tag, provenance |
| Vendored, forked and generated code | Change to the vendored tree, patch set or generator input | The residue after subtracting upstream or regenerating |

Out of scope: approving or blocking on the model's word alone, fixing code, binary-only artifacts, and
performance review. Ecosystems, in order: Python and Go for review; npm joins for the ingestion gate
(D15). Platform agnostic: it runs wherever the team's pipeline runs. Konflux and Conforma appear here
only as the example.

## Principles

Fifteen, numbered so the code, the goals and the other documents can cite them.

1. **The reviewer informs; a person decides.** It is code analysis, never code review, and never approves.
2. **Incoming content is untrusted data.** Diffs, file names, comments, descriptions, commit messages,
   issue text and instruction files are marked as data in every prompt.
3. **Tools before the model.** Deterministic checks run first; the model may add findings, never clear one.
4. **Evidence or silence.** A finding without an anchor, a catalogued rule and its basis is not shown.
5. **The reviewer cannot act.** No tools, network, write token or secret where the model runs.
6. **A verdict must survive its own framing.** Every change is reviewed twice, once blind to its metadata.
7. **Nothing reads as a pass.** Every report states what was checked and what was not.
8. **Noise has a budget, per category,** measured by whether the code changed, not by ratings.
9. **Review what will be installed.** For third-party code the artifact comes first, the git diff second.
10. **The author sees findings first.** The human reviewer gets a spotlight, not a list to confirm.
11. **Bound, reproducible, signed.** The record names the head revision, the model, the prompts and tools.
12. **Fitness is measured, never assumed.** Models and prompts win a measured table on two-sided jobs.
13. **The reviewer tests itself first.** Every observed failure mode is a register entry with a self-check
    that runs before every run and fails closed.
14. **Reuse before building.** Standard formats out, native evidence in, existing tools in the gate.
15. **The team owns every number.** Budgets, size limits, blocking categories and thresholds are settings
    with explained defaults.

## The pipeline

One core, eight stages, each writing the records the next reads.

| Stage | What it does | Writes |
|---|---|---|
| 0 Self-verification | Every register self-check; probes prove the model runs without tools, network or secrets; any failure stops the run | `selfcheck` record |
| 1 Intake | The change and its context. For a bump: the installed artifact at both versions, the source at the claimed tag, attestations and provenance. The harness's evidence for the same revision | Intake bundle |
| 2 Deterministic gate | Invisible and bidi Unicode; secrets; licence change; SAST on changed lines; new install scripts; dependencies never imported; non-existent or newly registered packages; mutable action references; risky CI wiring; lost provenance; artifact against source; vendored residue; generated code that does not regenerate; OpenVEX consistency | Gate findings, which stand |
| 3 Quarantined review | The model reads the bundle as marked data, with no tools, and answers the four questions. Twice: with metadata, and blind | Two candidate sets |
| 4 Grounding | Each candidate is checked against the tree and the tools; a testable claim becomes a test request to the harness; anything ungrounded is dropped | Grounded findings |
| 5 Triage | Class, severity and confidence; the noise budget per category; disagreement between passes becomes `suspicious`; size scoping | The finding set and the checked list |
| 6 Report | To the author first. Then the spotlight, SARIF, forge comments, the check conclusion, the signed statement and UDLM records | Report, attestation |
| 7 Feedback | Whether the code at each finding changed before merge; dismissals with reasons; categories over budget switched off | Acted-on record, evaluation table |

Finding classes: `intent-drift`, `defect`, `security`, `malicious`, `suspicious`, `provenance`,
`licence`, `convention`, `unproven` (the harness's evidence does not cover it), and `scope` (too large to
review well).

**The check and the gate.** The check concludes `neutral` when findings are advisory and `failure` only
when the team's policy holds the merge. By default only stage 2 findings can hold it (D13). The gate
reads the reviewer's statement beside the harness's test results and OpenVEX, joined by the head commit
digest. Either input can hold a merge under the team's policy.

## Ingestion: the artifact first

Twelve of the 21 real malicious changes in the research put nothing malicious in the source diff. For a
dependency bump the gate therefore works on three objects, in order:

1. **What will be installed,** against what was installed before. New files, new install scripts, new
   dependencies, new capabilities (malcontent, OSSGadget, Capslock in the example).
2. **The artifact against the source it claims.** Resolve the tag, diff the package against it, and
   explain every difference. Regenerable build output is explained; anything else is a finding.
   OSS Rebuild attestations count as evidence where they exist.
3. **The source diff,** reviewed like a first-party change for intent and defects.

Provenance the previous release had and this one lacks is a finding on its own. So is a tag that moved
after it was first seen.

## Findings and the report

A finding carries its rule from a fixed catalogue with a CWE where one applies. It also carries its
location at the head revision, its evidence (tool output, a quoted span, the harness result it rests on),
and a stable fingerprint. Model-only findings are SARIF `kind: "review"`. Only what the change introduced
is shown, against the base revision's run. The report opens with the checked list, then the findings,
then the spotlight for the human reviewer. Every comment is labelled as machine-generated.

## Evidence in and out

In: the test harness's in-toto test-result statements, OpenVEX documents and UDLM records, read as
themselves. A change that reaches code an existing `not_affected` statement places outside the execute
path makes that statement stale, and the finding says so. Out: SARIF, GitLab Code Quality and SAST
reports from the same findings, and a signed in-toto statement under an `ai-code-review` predicate whose
subject is the head commit. The same evidence goes into a UDLM `ReviewEvidence` record (D18). An
organization may claim the reviewer as an `ORG_SOURCE_` control at SLSA Source Level 3. The reviewer
confers no Source Level 4: two-party review stays with people.

## Security rules

- The model runs quarantined: no shell, network, write token or secret; the posting step is separate and
  deterministic, and strips links and images to outside hosts.
- Untrusted text is marked as data; a change to any file an agent reads as instructions needs its owner.
- A prompt injection yields at most a wrong candidate. Grounding and the blind pass catch it, and the
  attempt is itself a `suspicious` finding.
- Signing keys live in the pipeline, never where the model runs.
- The reference corpus holds no live malware (D19).

## Built here, reused from elsewhere

Reused, in the example: the pipeline engine, Conforma or OPA for the gate, reviewdog for forge fan-out,
Opengrep, gosec, bandit, ruff, gitleaks, zizmor, GuardDog, OSV-Scanner, OSSGadget, malcontent, Macaron,
Capslock, OSS Rebuild, diffoscope as an invoked tool, ScanCode, find-unicode-control, Sigstore and in-toto.
Built here: the assembly, the quarantined two-pass review, grounding, the noise budget, the
artifact-against-source explanation, the OpenVEX consistency check, the predicate and the reference
corpus. Avoided: AGPL components, Semgrep-maintained rules, and the CodeQL CLI on private code
([landscape](04-landscape.md)).

## How it is judged

- Stage 0 passes on every run.
- Seven guarantees hold on every run: never approves, every finding grounded, no deterministic finding
  cleared, no silent pass, bound to the head revision, reproducible, cannot act.
- The two-sided reference jobs pass both ways, and the six deterministic jobs pass without the model.
- Each finding category stays under its noise budget, and at least 40% of findings are acted on at pilot.
- The pilot does no harm to cycle time or to what human reviewers find; a gain is claimed only when measured.

The full list, with sources, is the [target goals](target-goals.md).
