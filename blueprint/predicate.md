# The `ai-code-review` predicate, v0.1

**For:** whoever writes a gate policy that reads the reviewer's signed statement, or a tool that emits
one. in-toto has no vetted predicate for code review, so this project defines one (decision D11). It is
shaped like two vetted predicates: Test Result (lists of what ran) and Vulnerabilities (the scanner,
its version, and timestamps).

**Predicate type:** `https://croadfeldt.github.io/ai-code-review/attestation/ai-code-review/v0.1`. The
URI will resolve when the project site is published. Until then this file is the definition.

**What it is not.** It records automated analysis. It is not a human review and must not be read as
one. SLSA v1.2 defines a review party as "a human", and OpenSSF Scorecard says AI reviews "do not
count". The predicate says so in a fixed field, `review_kind: "automated-analysis"`, so a policy can
check it.

## The statement

An in-toto Statement v1, signed in a DSSE envelope by the pipeline's signing step, never by the step
where the model runs.

**Subject.** The head commit that was reviewed, as `{"name": "<repository URL>", "digest": {"gitCommit":
"<40 hex>"}}`. For a dependency bump, each installed artifact reviewed is a further subject, named by
its package URL and digested with `sha256`. A gate rejects a statement whose subject is not the commit
it is about to merge (goal G5).

## Fields

| Field | Required | What it holds |
|---|---|---|
| `review_kind` | yes | Always `"automated-analysis"` |
| `reviewer` | yes | `id` (a URI for this implementation), `version`, `image_digest` |
| `model` | yes, if stage 3 ran | `id`, `endpoint` by label only, `prompt_set` name and `prompt_set_digest` |
| `change` | yes | `source` (`first-party`, `agent`, `dependency`, `vendored`, `generated`); `base` and `head` commits; `forge_ref` (the pull request URL); for a bump, `packages` with old and new package URLs and artifact digests |
| `selfcheck` | yes | `passed` (must be `true`, or there is no statement) and the register ids that ran |
| `checked` | yes | One entry per check: `check` (a rule id or rule family), `tool` and `version`, `status` (`ran`, `failed`), and for `failed` the reason |
| `not_checked` | yes, may be empty | One entry per thing not looked at: `what` and `reason` (over the size limit, ecosystem not supported, artifact unavailable) |
| `findings` | yes, may be empty | Per finding: `rule_id`, `class`, `level`, `kind`, `blocking`, `fingerprint`, `location`. The full findings are in the SARIF log |
| `findings_log` | yes | `uri` and `digest` of the SARIF 2.1.0 log |
| `counts` | yes | `findings`, `blocking`, `suspicious`, `candidates` (model, before grounding), `dropped` (failed grounding) |
| `passes` | yes, if stage 3 ran | `full` and `blind` finding counts and `disagreements` |
| `harness_evidence` | yes, may be empty | Per input read: `type` (`openvex`, `test-result`, `udlm`), `digest`, `status` (`read`, `missing`, `rejected`) and why. See the [evidence input contract](evidence-input.md) |
| `run` | yes | `run_id`, `started_on`, `finished_on`, `tokens` (prompt, completion), `cpu_minutes` |

There is no `result` and no `verdict` field, on purpose. A top-level "passed" would be the anchoring that
principle 7 forbids, and it would invite a gate to read the absence of findings as approval. A gate
reads `counts.blocking`, the `findings` and `not_checked`, and decides under its own policy.

## Mapping to SLSA

- **Source provenance.** SLSA v1.2 expects a "code review" attestation among the source provenance
  attestations. This predicate fits that slot, with `review_kind` saying what kind of review it is.
- **Source VSA.** An organization may claim the reviewer as an organization-defined control. The
  suggested property is `ORG_SOURCE_AI_REVIEWED`, set when a verified statement exists for the final
  revision, its self-check passed, and no blocking finding is open. It confers no Source Level 4:
  two-party review stays with people.

## Example

[`example-statement.json`](example-statement.json) is an unsigned statement for an illustrative pull
request. Every digest in it is a placeholder.

## Versioning

Fields are added, never renamed or removed, within v0. A consumer must ignore fields it does not know.
A change that would break a v0.1 reader becomes v0.2 at a new URI.
