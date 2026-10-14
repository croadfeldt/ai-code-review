# What the research settled

**Status:** research synthesis, v0.1, 2026-10-14. **Owner:** Chris Roadfeldt.
**For:** the reader deciding whether the blueprint should be written on these terms. Read this page first;
the four notes behind it carry the sources.

This page states the positions the research supports, what it changes in the starting plan, and the shape
the blueprint will take. Each position names the evidence it rests on. The open questions for a ruling are
in [open-questions.md](../open-questions.md); the measurable goals are in
[target-goals.md](../target-goals.md).

| Note | What it answers |
|---|---|
| [Landscape](../04-landscape.md) | What exists to reuse, learn from, benchmark against or avoid |
| [Efficacy](efficacy.md) | What measured data says about human review and AI review |
| [Practice and standards](practice-and-standards.md) | What good review requires, and what SLSA, NIST SSDF, Scorecard, the CRA and the forges say |
| [Threats and ingestion](threats-and-ingestion.md) | How an AI reviewer is attacked, and how malicious changes actually got in |

## The positions

1. **The reviewer is code analysis, never code review.** SLSA v1.2 defines the two parties of a review as
   "trusted persons", and a trusted person is "a human". OpenSSF Scorecard says reviews by AI bots "do not
   count as code review". NIST SSDF PW.7.1 separates code review ("a person looks directly at the code") from
   code analysis (tools). So the reviewer informs the human; it never stands in for one. It posts comment
   reviews only, never an approval. Its check concludes `neutral` when it is advisory, because GitHub treats
   `neutral` as passing, and `failure` only when the team's policy says block.
   ([Practice and standards](practice-and-standards.md), sections 2 and 3.)

2. **The filter is the product, not the model.** Tuned reviewers in production get about 40% of comments
   acted on (Atlassian 38.7% against 44.5% for humans; Google about 40%). Untuned ones get 1 to 19% in open
   source, and the best benchmark precision with full PR context is 16.65%. Every company that published
   numbers filtered hard before posting. The only noise rule with a long production record is Google's:
   under 10% of findings left unacted on, or the check is switched off. I apply it per finding category.
   ([Efficacy](efficacy.md), sections 2 and 3.)

3. **Evidence or silence, and tools before the model.** A finding carries a file and line that exist, a
   rule from a fixed catalogue, and the tool result or reasoning behind it. Without evidence, it is not
   shown. Deterministic checks run first, and the model may add findings but never clear one. The strongest
   measured defence against fooling an LLM detector was cross-checking with static analysis (96.9%
   detection), while optimised attacks evade LLM detectors on over 87% of the bugs they otherwise catch.
   ([Threats and ingestion](threats-and-ingestion.md), section 1.)

4. **For code we did not write, the artifact is the primary object.** Of 21 real incidents studied, only
   five put the malicious part plainly in the source diff a reviewer reads. Two more hid the meaning of a
   visible part (xz, event-stream). The rest came in through the release artifact, a moved tag, package
   index resolution or CI configuration. The gate reviews what will be installed, diffed against the
   previous installed version and against the source at the tag it claims. The git diff comes second.
   ([Threats and ingestion](threats-and-ingestion.md), section 2.)

5. **The reviewer cannot act.** It has no shell, no network, no write token and no secret in its runtime,
   and a separate deterministic step posts its output with links and images stripped. Every documented
   attack on an AI agent in CI (Comment and Control, Clinejection, the GitHub MCP case) needed a tool that
   acts or a secret worth stealing. Restriction by construction is cheaper than hardening, and the vendor
   actions say plainly they are not hardened against prompt injection.
   ([Threats and ingestion](threats-and-ingestion.md), section 1.)

6. **Every change is reviewed twice, once blind.** A crafted PR description slipped a known vulnerability
   past AI reviewers in 32 of 33 attempts. Removing the description, commit messages and comments restored
   detection in most cases. The second pass drops the metadata. A verdict that differs between the passes
   is itself a `suspicious` finding, and "same verdict on both" is a headline metric.
   ([Efficacy](efficacy.md), section 3; [Threats and ingestion](threats-and-ingestion.md), rule 5.)

7. **No silent pass, and the author sees findings first.** Reviewers given an AI review looked where it
   pointed and found no more serious issues (Tufano et al., ICSE 2025). Meta's reviewers took 5.5% longer
   when shown AI output, and the slowdown vanished when only authors saw it. So findings go to the author
   first. The human reviewer gets a short spotlight of the riskiest regions and a list of what was checked
   and what was not. The output never says "approved", "safe" or "no issues".
   ([Efficacy](efficacy.md), sections 2 and 3.)

8. **Large changes are split or scoped, not reviewed line by line.** Model F1 falls from 0.657 on diffs
   under 10 lines to 0.043 on diffs over 150 lines. The reviewer says what it covered and asks for a split
   above a size the team sets. ([Efficacy](efficacy.md), section 3.)

9. **"Does it do what it says" is a first-class check.** Meta's drift score, which compares stated intent
   with the diff, agreed with human judges at QWK 0.907. It is the check that matters most for agent-written
   changes and vendored code, and no open tool does it. ([Efficacy](efficacy.md), section 5.)

10. **Standard formats out, harness evidence in.** SARIF 2.1.0 carries findings, stable fingerprints,
    baselines ("new only") and suppressions with reasons. `kind: "review"` marks a finding a person must
    judge. No in-toto predicate for code review exists, so I define one, shaped like the test-result and
    vulnerability-scan predicates. It maps to SLSA's "code review" attestation slot and to an
    organization-defined `ORG_SOURCE_` control at Source Level 3. The reviewer reads the test harness's
    OpenVEX, in-toto statements and UDLM records as themselves. One new check falls out: a change that
    reaches code an existing `not_affected` statement says is not in the execute path makes that statement
    stale. ([Practice and standards](practice-and-standards.md), sections 3 and 4.)

11. **Building another first-party reviewer adds nothing.** Claude Code Review, Copilot code review,
    CodeRabbit and Red Hat-led Fullsend have converged on one design: parallel specialist agents, a pass
    that filters false positives, severity ranking, inline comments. The gaps are the ingestion gate,
    evidence-first findings, native reading of VEX and attestations, a design for hostile input, and a
    published refusal of approval authority. That is where this project spends its effort.
    ([Landscape](../04-landscape.md), sections 1 and 6.)

12. **Fitness is measured, never assumed.** A smaller model beat a larger one on real review at a third of
    the cost. Offline scores overstated production about threefold at Meta. Models and prompts are chosen
    by a measured table. The table includes clean changes, so false positives are counted. It is checked
    against what developers actually did. BLEU, which agrees with human judgement worse than chance, is
    not used. ([Efficacy](efficacy.md), sections 3 and 4.)

## What this changes in the starting plan

| Starting plan said | The research changes it to |
|---|---|
| Four questions: does it do what it says, is it safe to admit, does it fit, is it proven | The four stay. The report adds a fifth part: what was checked and what was not |
| Deterministic analysis feeds the model | Deterministic checks are a gate of their own, with findings the model cannot clear |
| One review pass per change | Two passes, one with metadata removed; disagreement is a finding |
| Review the dependency's source diff | Review the installed artifact first, against the previous artifact and against the tagged source |
| Findings posted to the pull request | Findings go to the author first; the human reviewer gets a spotlight and the checked list |
| A noise budget | Google's rule per finding category: under 10% left unacted on, measured by code change at the finding's location, not by thumbs |
| A signed statement | A defined `ai-code-review` in-toto predicate, a documented `ORG_SOURCE_` property, and a reference gate policy in Rego |
| Read harness evidence | Read it natively, and check the change against the harness's OpenVEX justifications |

## The blueprint's stages, as the research shapes them

| Stage | What it does |
|---|---|
| 0 Self-verification | The failure register's checks, then probes of the model and the quarantine; any failure stops the run |
| 1 Intake | The change and its source: diff, metadata, linked issue; for a dependency, the installed artifact at both versions, the source at the tag, provenance and attestations; harness evidence for the same revision |
| 2 Deterministic gate | Invisible and bidi Unicode, secrets, licence change, unused binary fixtures, new install scripts, dependencies never imported, non-existent or newly registered packages, mutable action references, lost provenance, artifact against source, generated code that does not regenerate, SAST on changed lines. Findings here stand regardless of the model |
| 3 Quarantined review | The model, with no tools, reads untrusted text marked as data and answers the four questions. It does this twice: with metadata, and blind |
| 4 Grounding | Every model finding is checked against the tree and the tools. A testable claim becomes a test request to the harness. Ungrounded findings are dropped |
| 5 Triage | Classes, severity and the noise budget per category; disagreement between the two passes becomes `suspicious` |
| 6 Report | To the author first. Then the spotlight, the checked list, SARIF, forge comments, the signed statement and UDLM records |
| 7 Feedback | Whether the code at each finding changed before merge, read back as the measure, plus dismissals with reasons |
