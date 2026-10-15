# Decision record

**Status:** 2026-10-14. **Owner:** Chris Roadfeldt.
**For:** the engineering team building AI Code Review, so the positions behind the blueprint do not have
to be reconstructed from the research notes.

Each entry says what I decided, why, and what it rules out. D1 to D12 are the positions the research
supported and I accepted with [the research](research/README.md). D13 to D23 are my rulings on the
[open questions](open-questions.md). Numbers are stable; new decisions append.

## Positions from the research

**D1. The reviewer is code analysis, never code review.** It informs the person who reviews; it is never
one of the reviewers. It posts comment reviews only, never an approval or a change request. *Why:* SLSA
v1.2 defines a review party as "a human", Scorecard says AI reviews "do not count", and NIST SSDF PW.7.1
calls tools "code analysis". *Rules out:* a bot approval that satisfies a required-approval rule, and any
wording that presents the reviewer as a second reviewer.

**D2. The filter is the product.** Each finding category carries a noise budget: under 10% of its findings
left unacted on, or the category is off by default. *Why:* tuned production reviewers get about 40% of
comments acted on and untuned ones 1 to 19%; Google's under-10% rule is the only noise rule with a long
production record. *Rules out:* shipping raw model output, and judging the tool as a whole rather than by
category.

**D3. Acted on means the code changed.** The measure is whether the code at a finding's location changed
before merge, or the finding was answered with a reason. *Why:* about 90% of AI comments never get a
thumbs rating, so ratings measure a biased tenth. *Rules out:* thumbs ratings as the primary measure.

**D4. Tools first; the model adds findings and never clears one.** Deterministic checks are a gate of
their own. *Why:* optimised attacks evade LLM detectors on over 87% of the bugs they otherwise catch, and
static cross-checking was the best measured defence. *Rules out:* a model verdict that downgrades or
dismisses a deterministic finding.

**D5. Evidence or silence.** A finding is shown only with a file and line that exist at the head revision,
a rule from a fixed catalogue, and its tool result or reasoning. *Why:* Google's "facts and data overrule
opinions"; a model may not invent rule identifiers, because forges deduplicate by them. *Rules out:*
free-text findings with no anchor.

**D6. For code we did not write, the installed artifact is the primary object.** The gate diffs what will
be installed against the previous installed version and against the source at the tag it claims. *Why:*
12 of 21 real malicious changes put nothing in the source diff. *Rules out:* an ingestion gate that reads
only the git diff.

**D7. The reviewer cannot act.** No shell, network, write token or secret in the model's runtime; a
separate deterministic step posts the output with outside links and images stripped. *Why:* every
documented attack on an AI agent in CI needed a tool that acts or a secret worth stealing. *Rules out:*
giving the model tools to "investigate", and posting from the model's own process.

**D8. Every change is reviewed twice, once blind.** The second pass drops the description, commit
messages and code comments. A verdict that differs between the passes is a `suspicious` finding. *Why:*
a crafted description defeated AI reviewers in 32 of 33 attempts, and removing it restored detection.
*Rules out:* a single pass that reads attacker-controlled framing.

**D9. Nothing reads as a pass, and the author sees findings first.** The report lists what was checked and
what was not, and never says "approved", "safe" or "no issues". The human reviewer gets a short spotlight
of the riskiest regions. *Why:* reviewers anchor on what an AI flagged and find no more serious issues;
Meta's review time rose 5.5% when reviewers saw AI output and recovered when only authors did. *Rules
out:* an AI comment list as the reviewer's starting point.

**D10. Large changes are scoped, not reviewed line by line.** Above a size the team sets, 400 changed lines
by default, the reviewer reports what it covered and asks for a split. *Why:* model F1 falls from 0.657
under 10 lines to 0.043 over 150. *Rules out:* findings on a diff the reviewer cannot read well, presented
as if it could.

**D11. Standard formats out, native evidence in.** SARIF 2.1.0 for findings, forge comments for people, a
defined `ai-code-review` in-toto predicate for gates, mapped to SLSA's code-review attestation slot and an
`ORG_SOURCE_` property. The test harness's OpenVEX, in-toto statements and UDLM records are read as
themselves. *Why:* the formats exist; only the code-review predicate does not. *Rules out:* a private
findings format, and reading harness evidence only through UDLM.

**D12. Effort goes where nothing exists.** The ingestion gate, evidence-first findings, native VEX and
attestation reading, and a design for hostile input. *Why:* the first-party reviewer design is now a
commodity shared by four products. *Rules out:* building another general-purpose PR commenter as the
headline.

## Rulings on the open questions

**D13. Only deterministic findings hold a merge by default (O1).** On ingestion: artifact against source
mismatch, a new install script, lost provenance, invisible Unicode, and the other stage 2 checks the team
marks blocking. Model findings never block alone; a team may raise a category to blocking once it meets
its noise budget. *Rules out:* a model-only block out of the box.

**D14. Author first, through the forge's draft state (O2).** The reviewer runs on draft pull requests and
on push to the branch; a human reviewer is requested after the author has seen the findings. Where the
forge has no draft state, findings start collapsed for reviewers. *Rules out:* findings appearing first
in front of the human reviewer.

**D15. Python and Go first; npm joins for the ingestion gate (O3).** The first two match the test harness's
targets and adapters. npm comes in the first wave for ingestion only, because that is where most real
attacks were. *Rules out:* waiting for a full npm review adapter before the gate covers npm.

**D16. One forge identity for both projects (O4).** A GitHub App per organization, with comment and
check-run permissions only and no approval rights, shared with the test harness. This also settles the
harness's design queue item Q7. *Rules out:* a personal or machine user account, and approval rights.

**D17. Copy first, then extract a shared library (O5).** The first slice copies what it needs from the
harness: the LLM client, prompt sets, self-check and failure register, run index and story, attestation,
UDLM records, deploy templates and site builders. A piece moves into a shared library once both projects
use it unchanged. *Rules out:* a shared library designed before either side needs it.

**D18. A `ReviewEvidence` record type goes to UDLM (O6).** Proposed the way the harness proposed
`TestEvidence`, after the predicate is drafted, with the signed statement as the record's projection.
*Rules out:* review evidence that exists only as an in-toto statement.

**D19. The reference corpus lives in its own public repository (O7).** Each job pairs a defanged malicious
change, its payload replaced by a harmless marker, with a clean neighbour. No live samples anywhere.
*Rules out:* reference jobs inside this repository, and any live malware.

**D20. Public benchmarks are context, not the measure (O8).** I report on Martian's bench and ReviewBench
with the judge named. The two-sided reference jobs are the measure that counts. *Rules out:* claiming
fitness from an LLM-judged leaderboard.

**D21. A baseline is measured before the implementation starts (O9).** An open model, with a plain prompt
and no filtering, reviews both sides of the reference jobs. The result sets the starting line every later
change is compared against. It runs on the lab GPUs once the corpus exists, after checking with the
serving owner. *Rules out:* targets that rest only on other people's numbers.

**D22. Agent test-weakening is measured from AIDev (O10).** Once the deterministic checks exist, I measure
how often agent pull requests delete assertions, add skip markers or relax CI, and publish it. *Rules
out:* asserting that rate without a measurement.

**D23. Fullsend is a relative to learn from, not a base (O11).** I cite it and learn from its findings
schema, sandbox and credential isolation, and offer evidence-first findings and ingestion checks upstream
later. *Rules out:* building on a system whose agents merge and close pull requests.
