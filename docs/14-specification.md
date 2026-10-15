# Implementation specification

**For:** the engineer implementing or evaluating an AI Code Review. What an implementation must do, the
contracts it must honour, and how it is judged. The reasons are in the [blueprint](03-blueprint.md) and
the [decision record](21-decision-record.md); this page states only what is required. MUST is required;
SHOULD is expected unless a written reason says otherwise.

There is no implementation yet. Each line names the check that will prove it, or the goal that measures
it. One check exists today: the reference gate policy's tests (`opa test blueprint/`).

## Requirements

| Id | Requirement | Proved by |
|---|---|---|
| R1 | A run MUST take a repository by path or address, a base and a head commit, and the change's source (`first-party`, `agent`, `dependency`, `vendored`, `generated`); a forge reference is optional. Every ref MUST be resolved to a full commit before anything is read. | `test_intake_refs` (planned) |
| R2 | Before reading the change, a run MUST pass every entry of the [failure register](15-failure-register.md) and probe the model step: no shell or tool, no network beyond the model endpoint, no forge token, no signing key. Any failure stops the run and no statement is produced. | `test_selfcheck` (planned), goal G7 |
| R3 | Intake MUST gather, for a dependency bump, the installed artifact at both versions, the source at the tag each claims, their signatures and attestations, and registry metadata; when any of these cannot be fetched, the run MUST record it in `not_checked` with the reason. | `test_intake_bump` (planned), goal G19 |
| R4 | Every check in stage 2 MUST run without the model, and its findings MUST reach the report unchanged whatever stage 3 returns. | `test_gate_findings_stand` (planned), goal G3 |
| R5 | Stage 2 MUST cover the deterministic rules of the [rule catalogue](../blueprint/rule-catalogue.yaml) for the change's ecosystem, and catch reference jobs 1, 2, 5, 6, 9 and 13 with the model switched off. | goal G17 |
| R6 | Every incoming text (diff, file names, comments, description, commit messages, issue text, instruction files, evidence) MUST be marked as data in the prompt. | `test_prompt_marks_data` (planned) |
| R7 | Stage 3 MUST review every change twice, once with the description, commit messages and issue text removed, and MUST raise `model.suspicious.pass-disagreement` where the verdicts on a region differ. | `test_blind_pass` (planned), goal G13 |
| R8 | Stage 3 MUST reach the model only through a named, digested prompt set, and MUST return candidates that validate against the [finding schema](../blueprint/finding.schema.json); a candidate that does not validate is dropped and counted. | `test_candidate_schema` (planned) |
| R9 | Grounding MUST drop any candidate whose file and line do not exist at the head commit, whose quoted span does not match, or whose rule is not in the catalogue; the count of dropped candidates MUST be recorded. | `test_grounding` (planned), goal G2 |
| R10 | A claim only a test can settle MUST become a test request to the harness, and the finding MUST be shown as `unproven` until the harness answers. | `test_test_request` (planned) |
| R11 | Triage MUST set confidence from the evidence, never from the model's self-report, and MUST set `blocking` from the catalogue and the team's settings, never from the model. | `test_triage_blocking` (planned) |
| R12 | Triage MUST apply the noise budget per finding category from measured action, and a category over its budget MUST be switched off by default with the reason recorded. | `test_noise_budget` (planned), goal G8 |
| R13 | A diff over the team's size limit (400 changed lines by default) MUST get a scope notice listing what was covered and asking for a split, instead of line findings on what was not. | `test_size_scope` (planned), goal G15 |
| R14 | Every report MUST open with what was checked and what was not, and MUST NOT contain "approved", "safe", "no issues" or equivalent wording. Every comment MUST say it is machine-generated. | `test_report_wording` (planned), goal G4 |
| R15 | Only findings new against the base commit's run MUST be posted as comments; the SARIF log carries every finding with its `baselineState`. | `test_baseline_state` (planned) |
| R16 | The reviewer MUST post COMMENT reviews only, never an approval or a change request. The check MUST conclude `neutral` unless a finding holds the merge under the team's policy, then `failure`. | `test_forge_post` (planned), goal G1 |
| R17 | The posting step MUST be separate from the model step and MUST strip links and images to outside hosts from every posted text. | `test_post_sanitize` (planned) |
| R18 | Every run MUST emit SARIF 2.1.0 with stable rule ids and fingerprints, and SHOULD emit GitLab Code Quality and SAST reports from the same findings. | `test_sarif` (planned) |
| R19 | Every run MUST emit an in-toto statement under the [`ai-code-review` predicate](../blueprint/predicate.md), whose subject is the head commit, signed only in the attest step. | `test_statement` (planned), goal G5 |
| R20 | Harness evidence MUST be read as itself (OpenVEX, in-toto test results, UDLM records) under the [evidence input contract](../blueprint/evidence-input.md); evidence not bound to the head commit, or not verified, MUST be recorded as rejected and never used. | `test_evidence_binding` (planned) |
| R21 | The reviewer MUST NOT merge, push, edit code, edit a test, or write a VEX statement. | goal G1, `test_no_write_scopes` (planned) |
| R22 | Every run MUST record the model, prompt set, tool versions, image digests, tokens and CPU-minutes, and write its story and an index naming every file with its reader and reason. | `test_run_record` (planned), goals G6 and G20 |
| R23 | After merge, feedback MUST record per finding whether the code at its location changed before merge, or the finding was answered with a reason. | `test_acted_on` (planned), goal G9 |
| R24 | Fitness of a model and a prompt set MUST be measured on the two-sided reference jobs; a model or set becomes a default only by winning that table. | `test_evaluate` (planned), goals G11 and G16 |
| R25 | A gate built on the reviewer MUST NOT hold a merge on a model finding unless the team raised that rule, and MUST ignore a statement that is unverified or names another commit. | `opa test blueprint/` (exists) |

## Contracts

- **Findings.** [`blueprint/finding.schema.json`](../blueprint/finding.schema.json), mapped field by
  field to SARIF 2.1.0; rule ids from [`blueprint/rule-catalogue.yaml`](../blueprint/rule-catalogue.yaml).
- **Signed statement.** [`blueprint/predicate.md`](../blueprint/predicate.md), with an
  [example](../blueprint/example-statement.json).
- **Evidence in.** [`blueprint/evidence-input.md`](../blueprint/evidence-input.md).
- **Gate.** [`blueprint/gate-policy.rego`](../blueprint/gate-policy.rego), with its tests.
- **Records.** Planned layout, one directory per stage: `selfcheck/`, `intake/`, `gate/`, `review/`,
  `grounding/`, `triage/`, `report/` (`findings.sarif`, `story.md`, `posted.json`), `attest/`
  (`statement.json`, `statement.dsse.json`, `udlm/`), `feedback/`, and `run.json` with `run-index.json`
  at the top. The names match the "read from" column of the [target goals](target-goals.md).

## How an implementation is judged

1. The register passes: every entry has a self-check, and stage 0 runs them all before every run.
2. The seven guarantees (G1 to G7) hold on every run.
3. The two-sided reference jobs pass both ways, and the six deterministic jobs pass with the model off.
   The baseline they are compared against comes from decision D21 and does not exist yet. A change that
   makes any line of that table worse is a regression until the table says otherwise.
