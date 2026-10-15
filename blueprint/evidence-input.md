# Evidence input contract

**For:** whoever wires the reviewer to the test harness, or to another source of test and vulnerability
evidence. It says what the reviewer reads, how it decides the evidence is about the same change, and
what it does when evidence is missing or does not match. Decision D11 settles that each format is read
as itself; UDLM is one way in, not the only one.

## What the reviewer reads

| Input | Format | What the reviewer uses it for |
|---|---|---|
| Test results | in-toto Statement v1 with the vetted `https://in-toto.io/attestation/test-result/v0.1` predicate, in a DSSE envelope | Question 4, "is it proven": which changed behaviour a test reaches, which advisories a test proved fixed. A changed path no test reaches becomes `model.unproven.untested-path` |
| Vulnerability status | OpenVEX v0.2.0 documents, signed or carried as an in-toto predicate | The staleness check `gate.vex.stale`, and context for security findings |
| Records | UDLM records (the harness's `TestEvidence` and, once proposed, `ReviewEvidence`, decision D18) | The same facts as the statements, for estates that join evidence through UDLM |
| Advisories | OSV records | Context for security findings on dependencies |

The reviewer reads evidence. It never writes, edits or publishes a VEX statement, and never changes a
test.

## Binding evidence to the change

Evidence counts only if it is about the commit under review. The join key is the head commit.

- **Test results:** accepted when the statement names the head commit as a subject,
  `{"digest": {"gitCommit": "<40 hex>"}}`, and its signature verifies against a key the team trusts.
- **OpenVEX:** a document applies when one of its `products` or `subcomponents` identifies the artifact
  or repository being changed. Statement timestamps override document timestamps, and later statements
  override earlier ones, as the specification says.
- **UDLM records:** accepted when the record's integrity head is a subject of a statement that passes
  the first rule.

Evidence that fails a rule is not used. The report says so, and the predicate records it in
`harness_evidence` with status `rejected` and the reason. Evidence that does not exist is recorded as
`missing`. Neither is ever treated as a pass.

**A gap in the harness today.** The harness's test-result statement names the test patch and its
manifest as subjects. It records the head commit only as a 12-character prefix inside a manifest
reference. The contract above needs the full head commit as a `gitCommit` subject. Until the harness
adds it, the reviewer cannot bind harness evidence by commit and records it as `rejected` with that
reason. Closing the gap is a change to the harness, raised there, not worked around here.

## The staleness rule

An OpenVEX `not_affected` statement with the justification `vulnerable_code_not_in_execute_path` is a
claim the reviewer can check against the diff. If the change adds a call path from the product's code
into a symbol the advisory names, the claim may no longer hold. The finding `gate.vex.stale` says so,
names the statement and the new path, and asks the statement's owner to look again. The reviewer does
not change the statement.

Other justifications are not checked by the reviewer, and the checked list says so.

## Draft evidence

The harness drafts VEX statements for Product Security to review, with `"role": "draft"` and an author
marked as a draft. The reviewer reads drafts as context, labels them as drafts in the report, and never
uses a draft as the basis of a staleness finding. Only a statement the organization has published
counts for that.

## Trust

Every signed input is verified before it is read. The keys and identities to trust are the team's
setting. Unsigned evidence is accepted only where the team's setting allows it, and is labelled
unsigned wherever it appears. Evidence is incoming data like any other: its text is marked as data in
the model's prompt, and nothing in it can change what the reviewer checks.
