# Research: what good review requires, and what the standards ask for

**Date:** 2026-10-14. Every source below was fetched on this date.

**What this settles.** This note fixes what AI Code Review may claim and what it must never claim. The short answer: no standard I read lets an automated or AI reviewer count as one of the two people a two-party review needs. SLSA v1.2 defines the reviewer as a human. OpenSSF Scorecard says AI bot reviews "do not count". NIST SSDF treats tool analysis as a separate activity from human review, with a human triaging what the tool reports. So the reviewer is evidence for the human, not a stand-in for one. Second, the standards give me a clean place to stand: an organization-defined technical control (SLSA Source Level 3), the "code analysis" half of SSDF PW.7, and the CRA's "regular tests and reviews of security". Third, the output formats and gates already exist. I do not need a new format. SARIF 2.1.0 carries findings, suppressions and baselines. In-toto has no code-review predicate, so I will define one and keep it close to the existing test-result and vulnerability-scan predicates. Fourth, the forges are moving: GitHub now lets a Copilot approval satisfy required approvals when an admin turns it on. That is exactly the move this blueprint refuses, and I need to say so plainly.

---

## 1. What good code review requires as a practice

### Google engineering practices

The Google guide is still the clearest statement of what a reviewer is for. Three ideas matter here.

The standard is improvement, not perfection. The guide calls this "the senior principle": "reviewers should favor approving a CL once it is in a state where it definitely improves the overall code health". Comments that do not block are marked "Nit:". And "Technical facts and data overrule opinions and personal preferences."

What to look for is a fixed list. Design comes first ("The most important thing to cover in a review is the overall design of the CL"), then functionality, complexity, tests ("Will the tests actually fail when the code is broken?"), naming, comments, style, consistency, documentation, every line, context ("Don't accept CLs that degrade the code health of the system") and good things.

Speed is part of quality. "One business day is the maximum time it should take to respond to a code review request." The guide adds that "Most complaints about the code review process are actually resolved by making the process faster." For large changes the default answer is to ask for a split.

### OWASP Code Review Guide

The OWASP project page lists the guide as "An OWASP lab project", not a flagship. The page shows no current version or release date. The last published edition I know of is v2 (2017). I treat it as a useful checklist of security review topics, not as a live standard to cite for requirements.

### OpenSSF guidance on AI-assisted development

The OpenSSF Best Practices and AI/ML working groups published the "Security-Focused Guide for AI Code Assistant Instructions" (dated 2025-08-01). It is about prompting code assistants, not about reviewers. Three lines bear directly on this blueprint:

- "AI-generated code isn't a shortcut around engineering processes such as code reviews, testing".
- "Generated content, in particular source code, should generally be reviewed and understood by the developers".
- It describes Recursive Criticism and Improvement: asking the model to "Review your previous answer and find problems with your answer."

The guide also advises against persona prompts such as "act as a security expert", because experiments found expert-role prompting often did worse. That is a direct input to how I write the reviewer's own instructions.

The OpenSSF "Concise Guide for Evaluating Open Source Software" (2025-03-28) gives the ingestion side: avoid the dependency if you can, verify you have the authentic project, check for recent maintenance and more than one maintainer.

### Microsoft and SEI

I did not find Microsoft or SEI guidance in this pass that changes any conclusion above. I am leaving them out rather than citing them thinly.

### Table: practice requirements

| Requirement | Source and clause | What it means for AI Code Review |
|---|---|---|
| Judge by "definitely improves overall code health", not perfection | Google eng-practices, Standard of review, "the senior principle" | The reviewer must not block on style or taste. Findings carry a severity, and low ones are labelled as nits. |
| Facts and data beat opinion | Google, Standard of review | Every finding carries evidence: the line, the rule, the test or the trace. No evidence, no finding. |
| Design first, then functionality, complexity, tests | Google, What to look for | The reviewer's checklist follows this order. "Will the tests fail when the code is broken" is a question the test harness's mutation evidence can answer. |
| Respond within one business day; ask to split large changes | Google, Speed of reviews | The reviewer runs in the pipeline and answers in minutes. On oversized changes it says so and scopes what it did review. |
| Tell the author about good things | Google, What to look for | Optional. Low value for a bot; I will not build it. |
| AI-written code still goes through review and testing | OpenSSF AI Code Assistant guide | AI-authored changes are a named input class. They get the same review, never a lighter one. |
| Avoid persona prompts | OpenSSF AI Code Assistant guide | The reviewer's system instructions state the task and the evidence rules, not a role. |
| Verify authenticity and maintenance before adopting a dependency | OpenSSF Concise Guide for Evaluating OSS | The ingestion gate for upstream code checks provenance and maintainer signals, not only the diff. |

---

## 2. What standards and regulation require

### SLSA v1.2 Source track: the two-party review text

SLSA v1.2 is the current approved version. SLSA v1.1 has no source track (its source-requirements page returns 404). The draft carries the same text as v1.2 for everything quoted here.

The levels are: "Level 1: Version controlled", "Level 2: History & Provenance", "Level 3: Continuous technical controls", "Level 4: Two-party review".

The two-party control sits at Level 4 only. The exact text:

> Changes in protected branches MUST be agreed to by two or more trusted persons prior to submission.
> The following combinations are acceptable:
> Uploader and reviewer are two different trusted persons.
> Two different reviewers are trusted persons.
> Reviews SHOULD cover, at least, security relevant properties of the code.

The sub-clauses:

> [Final revision approved] This requirement applies to the final revision submitted. I.e., if additional changes are made during the review process, those changes MUST be reviewed as well.
>
> [Context-specific approvals] Approvals are for a specific context, such as a repo + branch in git. Moving fully reviewed content from one context to another still requires review.
>
> [Informed Review] The SCS MUST present reviewers with a clear representation of the result of accepting the proposed change.
>
> [Trusted Robot Contributions] An organization MAY choose to grant a Trusted Robot a perpetual exception to a policy (e.g. a bot may be able to merge a change that has not been reviewed by two parties). Examples: Import and migration bots that move code from one repo to another. Dependabot

**Can an automated or AI reviewer count as a party?** No. The text does not mention AI at all. It settles the question through its definitions:

> Trusted person: A human who is authorized by the organization to propose and approve changes to the source.
>
> Trusted robot: Automation authorized by the organization to act in explicitly defined contexts. The robot's identity and codebase cannot be unilaterally influenced.

A "trusted person" is "a human". The two-party rule names only trusted persons. A trusted robot can receive an exception from the policy, but the exception is a waiver of review, not a robot doing review. So an AI reviewer can never be one of the two parties at Level 4. An organization that let a bot approval satisfy the rule would be granting a robot exception, which means the change was not two-party reviewed.

Level 3 is where the reviewer fits. The text:

> The organization MUST provide evidence of continuous enforcement via technical controls for any claims made in the Source Provenance attestations or VSAs ... The organization MUST document the meaning of their enforced technical controls. For example, if an organization implements a technical control via a custom tool (such as required GitHub Actions workflow), it must indicate the name of this tool, what it accomplishes, and how to find its evidence in the provenance attestation.

The Source VSA lets the organization add its own properties to `verifiedLevels`, "as long as they are prefixed by ORG_SOURCE_". So "this revision passed AI Code Review under policy X" can be a documented ORG_SOURCE_ control. It cannot be SLSA_SOURCE_LEVEL_4.

The spec also names the evidence it expects to see. Its list of example source provenance attestations includes 'A "code review" attestation which describes the basics of any code review that took place', a Vuln Scan attestation, a Test Results attestation and a SCAI attestation "used to describe which source quality tools were run on the revision." No code-review predicate is defined. That gap is the opening for this blueprint's statement.

One oddity to note: the VSA `verifiedLevels` values listed run from SLSA_SOURCE_LEVEL_0 to SLSA_SOURCE_LEVEL_3. Level 4 has no listed value yet.

### NIST SSDF SP 800-218 v1.1, and the v1.2 draft

SSDF v1.1 (February 2022) is the current final. SP 800-218 Rev. 1 (SSDF v1.2) is an initial public draft from 17 December 2025; comments closed 30 January 2026 and no final is posted. PW.7 reads the same in both.

PW.7 is "Review and/or Analyze Human-Readable Code to Identify Vulnerabilities and Verify Compliance with Security Requirements". Its two tasks:

> PW.7.1: Determine whether code review (a person looks directly at the code to find issues) and/or code analysis (tools are used to find issues in code, either in a fully automated way or in conjunction with a person) should be used, as defined by the organization.
>
> PW.7.2: Perform the code review and/or code analysis based on the organization's secure coding standards, and record and triage all discovered issues and recommended remediations in the development team's workflow or issue tracking system.

The PW.7.2 examples that matter:

> Example 1: Perform peer review of code, and review any existing code review, analysis, or testing results as part of the peer review.
> Example 2: Use expert reviewers to check code for backdoors and other malicious content.
> Example 4: Use a static analysis tool to automatically check code for vulnerabilities and compliance with the organization's secure coding standards with a human reviewing the issues reported by the tool and remediating them as necessary.

SSDF defines "code review" as "a person looks directly at the code". An AI reviewer is "code analysis ... in a fully automated way or in conjunction with a person". Example 1 is the model for this blueprint: the human peer reviewer reads the tool's results as part of their review.

PW.4.4 covers third-party code: "Verify that acquired commercial, open-source, and all other third-party software components comply with the requirements, as defined by the organization, throughout their life cycles." PW.7.1 Example 1 adds that review policy "may include third-party code and reusable code modules written in-house." That is the ingestion gate's warrant.

**SP 800-218A (July 2024)** is the SSDF profile for generative AI. It is about building AI models, not about AI writing or reviewing code. Its PW.7 additions say review policy "should include code for AI models" and "Scan all AI models for malware, vulnerabilities, backdoors". It applies to this blueprint only where a team reviews model code with it. It does not bless AI as a reviewer.

### CWE Top 25 (2025)

The 2025 list (page updated 15 December 2025) is led by CWE-79 cross-site scripting, CWE-89 SQL injection, CWE-352 CSRF, CWE-862 missing authorization and CWE-787 out-of-bounds write. Authorization weaknesses are prominent: CWE-862, CWE-863, CWE-284, CWE-639 and CWE-306 are all on it. Those are the classes static tools find worst and a reviewer with context can find better. The list is a sensible default rule set for tagging findings, and SARIF lets every finding carry a CWE tag.

### OWASP Top 10 for LLM Applications (2025), and the Agentic Top 10 (2026)

The reviewer is itself an LLM application that reads untrusted text: diffs, commit messages, PR descriptions, code comments and upstream source. So these lists apply to the reviewer, not only to the code it reads.

- **LLM01:2025 Prompt Injection.** "Indirect prompt injections occur when an LLM accepts input from external sources, such as websites or files." A pull request is exactly such a file. The listed mitigations include "Constrain model behavior", "Define and validate expected output formats", "Enforce privilege control and least privilege access", "Require human approval for high-risk actions" and "Segregate and identify external content".
- **LLM06:2025 Excessive Agency.** It arises from "excessive functionality; excessive permissions; excessive autonomy." Mitigations include "Minimize extension permissions" and "Require user approval".
- **LLM09:2025 Misinformation** covers confident wrong output, which in a reviewer is a false finding.

The OWASP Top 10 for Agentic Applications was published 9 December 2025. ASI01 is "Agent Goal Hijack", which is prompt injection that changes what the agent is trying to do. ASI09 "Human-Agent Trust Exploitation" is the risk that people rubber-stamp the agent's output. I read the ASI list from a secondary source; the OWASP page only links the PDF.

### EU Cyber Resilience Act (Regulation (EU) 2024/2847)

Dates, from Article 71: "This Regulation shall apply from 11 December 2027. However, Article 14 shall apply from 11 September 2026". Article 14 (reporting actively exploited vulnerabilities and severe incidents) is therefore in force today.

Annex I Part II lists the vulnerability-handling duties. Three touch review:

> (1) identify and document vulnerabilities and components contained in products with digital elements, including by drawing up a software bill of materials ...
> (3) apply effective and regular tests and reviews of the security of the product with digital elements;
> (6) take measures to facilitate the sharing of information about potential vulnerabilities in their product with digital elements as well as in third-party components contained in that product ...

Article 13(5) covers ingestion: manufacturers "shall exercise due diligence when integrating components sourced from third parties so that those components do not compromise the cybersecurity of the product", including free and open-source components. Recital text adds that when due diligence finds a vulnerability in a component, the manufacturer "should inform the person or entity manufacturing or maintaining the component".

### EU AI Act (Regulation (EU) 2024/1689)

A code reviewer is not in the Annex III high-risk categories as I read them. Article 50 transparency duties could touch it. Article 50(1) requires that people "are informed that they are interacting with an AI system, unless this is obvious". Article 50(2) requires generated text to be "marked in a machine-readable format and detectable as artificially generated". The low-cost answer is to label every comment as machine-generated and carry the producer identity in the signed statement. I am not giving legal advice here; this is a design default.

### ISO/IEC 20246

ISO/IEC 20246:2017 "Software and systems engineering: Work product reviews" exists. The ISO page refused my fetch (HTTP 403), so I could not confirm its current status or quote it. I do not cite it for any requirement.

### OpenSSF Scorecard: Code-Review and Branch-Protection

Code-Review "determines whether the project requires human code review before pull requests (merge requests) are merged." It looks at roughly the last 30 commits for an approval on GitHub or GitLab, a merger different from the committer, Prow "lgtm"/"approved" labels, or Gerrit "Reviewed-on"/"Reviewed-by". On bots:

> Review by bots, including bots powered by artificial intelligence / machine learning (AI/ML), do not count as code review.

Scoring is leveled: 7 points off for one unreviewed human change, 3 more for several. Changes that are only bot activity return inconclusive.

Branch-Protection tiers reward "Require at least 1 reviewer" (tier 2), "Require at least 2 reviewers" and code-owner review (tier 4), and dismissing stale approvals on new commits (tier 5).

### Table: standards requirements

| Requirement | Source and clause | What it means for AI Code Review |
|---|---|---|
| Two or more trusted persons agree to each change | SLSA v1.2 Source L4, Two-party review | The reviewer is never one of the two. It never submits an approving review. |
| A trusted person is "a human" | SLSA v1.2, Source Roles | Settles the AI question. Any doc or UI that implies otherwise is wrong. |
| Robots may get a policy exception, not a review credit | SLSA v1.2, [Trusted Robot Contributions] | If a team waives review for bot changes, the reviewer still runs and its statement records that the waiver was used. |
| Review applies to the final revision | SLSA v1.2, [Final revision approved] | The verdict binds to the head commit digest. New commits invalidate it. |
| Reviewers see a clear picture of the result | SLSA v1.2, [Informed Review] | This is where the reviewer earns its place: it makes the human's review better informed. |
| Org technical controls are documented and continuously enforced | SLSA v1.2 Source L3 | "Passed AI Code Review" is a valid ORG_SOURCE_ control. Its meaning and evidence location must be documented. |
| Code-review attestation is an expected kind of source provenance | SLSA v1.2, Source provenance attestations | Emit one. No predicate exists, so define it. |
| Code review is a person; code analysis is a tool | SSDF PW.7.1 | The reviewer is code analysis. It never claims to be code review. |
| Record and triage all issues in the team's workflow | SSDF PW.7.2 | Findings go to the forge and to SARIF, where they can be tracked and suppressed with reasons. |
| Human reviews what the tool reports | SSDF PW.7.2 Example 4 | Every finding is for a person to act on. The reviewer does not fix code. |
| Check code for backdoors and malicious content | SSDF PW.7.2 Example 2 | A named check for the ingestion gate, especially on upstream diffs. |
| Third-party components meet org requirements over their life | SSDF PW.4.4; PW.7.1 Example 1 | The ingestion gate is in scope of SSDF, not an extra. |
| Regular tests and reviews of security | CRA Annex I Part II (3), applies 11 Dec 2027 | Each run's signed statement is a dated record of a security review. |
| Due diligence on third-party and open-source components | CRA Art. 13(5) | Upstream diff review produces due-diligence evidence per component version. |
| Report actively exploited vulnerabilities | CRA Art. 14, applies 11 Sep 2026 | Out of scope for the reviewer. It may surface a finding; reporting is a human process. |
| Treat external content as untrusted; least privilege; human approval | OWASP LLM01 and LLM06 (2025) | The reviewer reads PR text as data, has read-only credentials, and cannot merge, approve or push. |
| Tell people they are dealing with AI; mark generated text | EU AI Act Art. 50(1), (2) | Label comments as machine-generated; identify the producer in the statement. |
| Bot and AI reviews do not count | OpenSSF Scorecard Code-Review | Using the reviewer will not raise a project's Scorecard. Claiming it does would be false. |

---

## 3. Output formats and integration surfaces

### SARIF 2.1.0 (OASIS, errata 01 of 28 August 2023)

SARIF already has every field this blueprint needs. The ones that matter:

- `result.fingerprints`: each value "SHALL be a string that provides a stable identifier for the result", the same for logically identical results and resistant to changes such as moving the enlistment root. `partialFingerprints` holds partial inputs a consumer can combine.
- `result.baselineState`: "new", "unchanged", "updated", "absent", against the run named by `run.baselineGuid`. This is how the reviewer reports only what the change introduced.
- `result.suppressions`: an array of suppression objects. `kind` is "inSource" or "external". `status` is "accepted", "underReview" or "rejected". An empty array means "not suppressed"; a non-empty one means read the statuses. Suppression objects also carry a `justification`.
- `result.kind`: includes "pass", "fail", "open", "informational", "notApplicable" and "review". "review" means "The result requires review by a human user to decide if it represents a problem." That is the honest kind for most LLM findings.
- `result.level` ("error", "warning", "note", "none"), `result.fixes`, property bags, and `run.automationDetails` round it out.

### GitHub

Code scanning SARIF upload: 10 MB gzip-compressed per file, 20 runs per file, 25,000 results per run of which "Only the top 5,000 results will be included, prioritized by severity." GitHub "uses the `partialFingerprints` property ... to detect when two results are logically identical" but "Code scanning only uses the `primaryLocationLineHash`", and "The `ruleId` for a result has to be the same across analysis." Use `automationDetails.id` ("category/run-id") to keep separate analyses apart.

Check runs: write access "is only available to GitHub Apps." Conclusions are `action_required`, `cancelled`, `failure`, `neutral`, `success`, `skipped`, `stale` (GitHub only), `timed_out`. Annotations are capped at "a maximum of 50 per API request", appended across updates. Annotation levels are `notice`, `warning`, `failure`. Up to three action buttons.

Branch protection treats `neutral` as passing: "Required status checks must have a `successful`, `skipped`, or `neutral` status". A required check can be pinned to one GitHub App as its expected source, so nobody else can set it.

Pull request reviews take `event` APPROVE, REQUEST_CHANGES or COMMENT. Review comments anchor by `commit_id`, `line`/`side`, and optionally `start_line` for ranges, or `subject_type: file`. Suggested changes are a fenced `suggestion` block in a comment, which the author can apply with a click.

Required approvals come from "people with write permissions", or code owners. Stale approvals can be dismissed on push, and "Require approval of the most recent reviewable push" needs someone other than the pusher. Workflows can approve PRs only if "Allow GitHub Actions to create and approve pull requests" is enabled; new personal repositories have it off.

**The important change:** GitHub's Copilot code review docs now say "By default, Copilot's reviews do not count toward required approvals", but "When Copilot approvals are enabled in repository, organization, and enterprise settings, Copilot can submit an approving review that satisfies your repository's required-approval rule the same way a teammate's approval would." This is in public preview. A team that enables it on a branch that claims SLSA Source L4 has, in SLSA terms, granted a robot exception.

### GitLab

Code Quality report: a JSON array of objects with `description`, `check_name`, `fingerprint`, `location.path`, `location.lines.begin` (or `positions.begin.line`) and `severity` of `info`, `minor`, `major`, `critical`, `blocker`. Declared as `artifacts:reports:codequality`. Results show in the MR Reports tab on all tiers; inline diff markers need Ultimate.

Security (SAST) report: validated against the security-report-schemas project, with `version`, `scan` (analyzer, scanner, times, status) and `vulnerabilities` (id, identifiers, location with file and lines, severity Unknown to Critical). Declared as `artifacts:reports:sast`.

MR approvals: authors "do not count as eligible approvers on their own merge requests by default"; committers can approve unless "Prevent committers approval" is on. GitLab's docs do not say whether bot users from access tokens count. GitLab issue 440302 reports that group and project access tokens "provide a way to by-pass two-eyes merge request approval controls". Treat bot approvals as possible and block them by rule.

### Gerrit and reviewdog

Gerrit 3.13 removed robot comments: "Robot comments are not supported anymore and users have to move to the Checks API." So Gerrit integration goes through Checks plus ordinary comments, with a bot account whose label permissions exclude Code-Review +2.

reviewdog reads errorformat, checkstyle, rdjson/rdjsonl, diff and SARIF, and posts to GitHub checks, PR reviews and annotations, GitLab MR discussions and commits, Gerrit, and Bitbucket Code Insights. `-filter-mode` is `added` (default), `diff_context`, `file` or `nofilter`. Code suggestions post only through `github-pr-review` and `gitlab-mr-discussion`. It is a ready-made fan-out layer for one SARIF file.

### Table: integration surfaces

| Requirement | Source and clause | What it means for AI Code Review |
|---|---|---|
| Stable fingerprint per logical result | SARIF 2.1.0 §3.27.16 | Compute fingerprints from rule, normalized code and symbol, not line number. Required for dedup across runs. |
| GitHub dedups only on `primaryLocationLineHash` with stable `ruleId` | GitHub SARIF support | Populate it, and never let the LLM invent rule IDs. Rule IDs come from a fixed catalogue. |
| Report only what is new | SARIF `baselineState`, `baselineGuid` | Diff against the base commit's run. The PR comment shows `new` only. |
| Suppressions with status and reason | SARIF §3.35 | Dismissals are recorded as external suppressions with a justification, and the gate reads them. |
| Findings needing human judgment | SARIF `kind: "review"` | Default kind for model-only findings without tool or test corroboration. |
| 5,000 results kept per run | GitHub SARIF limits | Cap and rank. A reviewer that floods is broken. |
| Check runs need a GitHub App; 50 annotations per call | GitHub Checks API | Ship as an App for GitHub. Batch annotations. |
| `neutral` passes a required check | GitHub protected branches | The verdict check uses `neutral` for "advisory findings, not blocking" and `failure` only when policy says block. Pin the check to the App. |
| Bot approvals can count if enabled | GitHub Copilot approvals; Actions approval setting; GitLab issue 440302 | The reviewer only ever posts COMMENT reviews. Docs tell teams how to keep bot approvals off protected branches. |
| GitLab Code Quality and SAST formats | GitLab docs | Emit Code Quality JSON on all tiers, SAST JSON where security dashboards are used. Both from the same findings. |
| Gerrit robot comments are gone | Gerrit 3.13 release notes | Use Checks API and plain comments. |
| One-input, many-forge fan-out exists | reviewdog | Use it as an option instead of writing forge clients for every CI. |

---

## 4. Gate policy: reading a verdict plus test evidence

### What exists for attestations

The vetted in-toto predicates include SLSA Provenance, SLSA Verification Summary (VSA), Test Result, Vulnerabilities (vulns v0.2), SCAI, Simple Verification Result (SVR), SPDX, CycloneDX, Release, Reference, Runtime Trace and Link. **There is no code-review predicate.**

The nearest shapes:

- **Test Result** (`https://in-toto.io/attestation/test-result/v0.1`): `result` PASSED, WARNED or FAILED, required `configuration`, optional `url` and lists of passed, warned and failed tests.
- **Vulnerabilities v0.2**: `scanner` with `uri`, `version`, `db` and a `result` list of `id` and `severity`, plus `metadata.scanStartedOn` and `scanFinishedOn`.
- **SVR v0.2** (`https://in-toto.io/attestation/svr/v0.2`): states an artifact "has been evaluated against one or more policies", with `verifier.id`, `verifier.policies`, `timeCreated` and `properties` scoped by prefix such as `CONFORMA_`.
- **SCAI v0.3**: attribute assertions with `attribute`, `target`, `conditions` and `evidence`. SLSA itself points to SCAI for "which source quality tools were run".
- **SLSA Source VSA**: `verifiedLevels` with `ORG_SOURCE_` properties for org-defined controls.

Kyverno's verifyImages documentation already uses an example predicate type `https://example.com/CodeReview/v1` and checks conditions on fields such as `reviewers`. That is precedent for a custom code-review predicate checked at admission.

### Engines

- **Conforma** (formerly Enterprise Contract) verifies signed attestations and evaluates Rego rules over `input.attestations`, filtering by `predicateType`. It ships rule packages for attestation types, SLSA provenance and source, SBOMs, CVEs and tests ("No tests failed"). `ec validate input` validates "arbitrary JSON or yaml file input with the provided policies", which suits a PR-time gate that has no image yet. Policy config supports include and exclude per rule.
- **OPA/Rego** directly, where a team does not run Conforma. Same policy, different runner.
- **Kyverno** verifies attestation signatures by `attestors` and applies conditions to the decoded predicate, at admission.
- **GitHub rulesets and required checks**, with the check pinned to the App, are the lowest-cost gate on GitHub.

### OpenVEX essentials for a consumer

OpenVEX v0.2.0. A document needs `@context`, `@id`, `author`, `timestamp`, `version` and `statements`; `version` must increase when content changes. A statement has `vulnerability` (with `name`), `products`, optional `subcomponents`, and `status`: `not_affected`, `affected`, `fixed` or `under_investigation`. A `not_affected` statement "MUST include either a status justification or an impact_statement". Justifications are `component_not_present`, `vulnerable_code_not_present`, `vulnerable_code_not_in_execute_path`, `vulnerable_code_cannot_be_controlled_by_adversary` and `inline_mitigations_already_exist`. The spec has no merge algorithm: later statements override and enrich earlier ones, and statement timestamps override document timestamps. An in-toto attestation can carry a VEX document as its predicate.

For this reviewer, the useful rule is: a `not_affected` claim with `vulnerable_code_not_in_execute_path` is a claim the reviewer can check against the diff. If the change adds a call into the vulnerable path, the earlier VEX statement is now stale and that is a finding.

### Table: gate requirements

| Requirement | Source and clause | What it means for AI Code Review |
|---|---|---|
| No code-review predicate exists | in-toto vetted predicates list | Define `ai-code-review/v0.1`, modelled on Test Result (verdict plus lists) and Vulns (tool, version, timestamps). |
| SLSA expects a "code review" attestation | SLSA v1.2 Source provenance attestations | Name the predicate to fit there, and be explicit that it records automated analysis, not human approval. |
| Org controls appear as ORG_SOURCE_ properties | SLSA v1.2 Source VSA | Offer a documented property name, e.g. `ORG_SOURCE_AI_REVIEWED`, for VSA issuers. |
| Policy verdicts can be summarized | in-toto SVR v0.2 | The gate's own decision can be emitted as an SVR, separate from the reviewer's statement. |
| Gates read signed attestations by predicate type | Conforma; Kyverno verifyImages | Ship a reference Rego policy that joins reviewer statement, test-result, vulns and OpenVEX by subject digest. |
| Gate on arbitrary JSON at PR time | Conforma `ec validate input` | The same policy runs before merge and before release. |
| `not_affected` needs a justification | OpenVEX v0.2.0 | The reviewer reads the harness's VEX and flags changes that undercut a justification. |
| Verdict binds to the final revision | SLSA [Final revision approved] | Subject is the head commit digest; the gate rejects a statement for any other digest. |

---

## Principles this implies

1. **The reviewer is code analysis, never code review.** SSDF draws the line ("a person looks directly at the code"), SLSA defines the reviewer as "a human", and Scorecard says AI reviews "do not count". I keep that language everywhere.
2. **It never approves.** On GitHub it posts COMMENT reviews only, never APPROVE or REQUEST_CHANGES. Blocking, when policy wants it, happens through a required check owned by the App.
3. **Evidence or silence.** Google's "facts and data overrule opinions" and SSDF's "record and triage all discovered issues" both point the same way. A finding without evidence is not emitted.
4. **Its job is the informed review.** SLSA's [Informed Review] and SSDF PW.7.2 Example 1 describe exactly this: the human reviews "any existing code review, analysis, or testing results as part of the peer review."
5. **Bind to the final revision.** The statement's subject is the head commit. New commits mean a new run.
6. **Standard formats out, signed statement on top.** SARIF for findings, forge-native surfaces for people, one in-toto statement for gates.
7. **Treat every input as hostile.** The reviewer reads attacker-controlled text. Read-only credentials, no merge or push rights, structured output validated against a schema, external content segregated in the prompt.
8. **Third-party code is in scope by standard.** SSDF PW.4.4 and CRA Art. 13(5) make the ingestion gate a compliance input, not a nice-to-have.
9. **Say what it is.** Comments are labelled machine-generated, and the statement names the producer, model and policy.

## What this changes in the plan

- **Add a "what this is not" section to the blueprint** quoting the SLSA trusted-person definition and the Scorecard bot rule. That stops anyone reading AI Code Review as a second reviewer.
- **Write guidance for the Copilot-approvals setting** and its equivalents. Teams that claim two-party review should keep bot approvals off protected branches. The reviewer can check this and report it as a configuration finding.
- **Define the `ai-code-review` in-toto predicate** now, shaped like Test Result and Vulns, and map it to SLSA's "code review" attestation slot and an `ORG_SOURCE_` property. No existing predicate covers it.
- **Make SARIF the primary output.** Fixed rule catalogue (stable `ruleId`), CWE tags, `baselineState`, `fingerprints` plus `primaryLocationLineHash`, and `kind: "review"` for uncorroborated model findings. Generate GitLab Code Quality and SAST JSON from the same findings. Consider reviewdog for fan-out.
- **Use `neutral` deliberately.** On GitHub, `neutral` passes required checks. Advisory runs conclude `neutral`; `failure` only when the gate policy says block.
- **Ship a reference gate policy in Rego** that runs under Conforma (`ec validate input` at PR time, `ec validate image` at release) or plain OPA, joining the reviewer statement with the harness's test-result, vulns and OpenVEX by subject digest.
- **Add an OpenVEX consistency check** to the reviewer: flag changes that reach code an existing `not_affected` statement says is not in the execute path.
- **Add a threat model section** against OWASP LLM01, LLM06 and Agentic ASI01 and ASI09, with the controls above.
- **Drop OWASP Code Review Guide and ISO/IEC 20246 as cited requirements.** The first is a lab project with no current release shown; the second I could not fetch.

## Sources (all fetched 2026-10-14)

- SLSA v1.2, Source: Requirements for producing source. https://slsa.dev/spec/v1.2/source-requirements (also /spec/ and /spec/draft/source-requirements; /spec/v1.1/source-requirements returns 404)
- Google Engineering Practices: The Standard of Code Review; What to look for in a code review; Speed of Code Reviews. https://google.github.io/eng-practices/review/reviewer/
- OWASP Code Review Guide project page. https://owasp.org/www-project-code-review-guide/
- OpenSSF, Security-Focused Guide for AI Code Assistant Instructions (2025-08-01). https://best.openssf.org/Security-Focused-Guide-for-AI-Code-Assistant-Instructions
- OpenSSF, Concise Guide for Evaluating Open Source Software (2025-03-28). https://best.openssf.org/Concise-Guide-for-Evaluating-Open-Source-Software
- NIST SP 800-218 v1.1. https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-218.pdf
- NIST SP 800-218 Rev. 1 ipd (SSDF v1.2 draft). https://csrc.nist.gov/pubs/sp/800/218/r1/ipd
- NIST SP 800-218A. https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-218A.pdf
- MITRE, 2025 CWE Top 25. https://cwe.mitre.org/top25/archive/2025/2025_cwe_top25.html
- OWASP Top 10 for LLM Applications 2025, LLM01 and LLM06. https://genai.owasp.org/llm-top-10/
- OWASP Top 10 for Agentic Applications 2026 (release page, and list via secondary source). https://genai.owasp.org/resource/owasp-top-10-for-agentic-applications-for-2026/ ; https://www.giskard.ai/knowledge/owasp-top-10-for-agentic-application-2026
- Regulation (EU) 2024/2847 (Cyber Resilience Act). https://eur-lex.europa.eu/legal-content/EN/TXT/HTML/?uri=CELEX:32024R2847
- Regulation (EU) 2024/1689 (AI Act), Article 50. https://eur-lex.europa.eu/legal-content/EN/TXT/HTML/?uri=CELEX:32024R1689
- ISO/IEC 20246 page (HTTP 403, not read). https://www.iso.org/standard/67407.html
- OpenSSF Scorecard checks. https://github.com/ossf/scorecard/blob/main/docs/checks.md
- OASIS SARIF 2.1.0 errata 01. https://docs.oasis-open.org/sarif/sarif/v2.1.0/errata01/os/sarif-v2.1.0-errata01-os-complete.html
- GitHub: SARIF support for code scanning; REST check runs; REST pull request reviews and review comments; About protected branches; Commenting on a pull request; Copilot code review concepts; Managing GitHub Actions settings. https://docs.github.com/
- GitLab: Code Quality; Security report integration; MR approval rules; GitLab Duo in merge requests; issue 440302. https://docs.gitlab.com/ ; https://gitlab.com/gitlab-org/gitlab/-/issues/440302
- Gerrit 3.13 release notes. https://www.gerritcodereview.com/3.13.html
- reviewdog. https://github.com/reviewdog/reviewdog
- in-toto attestation predicates: index, test-result, vulns v0.2, SVR, SCAI. https://github.com/in-toto/attestation/tree/main/spec/predicates
- Conforma: policy index, custom configuration, `ec validate input`. https://conforma.dev/docs/
- Kyverno verifyImages (Sigstore). https://kyverno.io/docs/policy-types/cluster-policy/verify-images/sigstore/
- OpenVEX specification v0.2.0. https://github.com/openvex/spec/blob/main/OPENVEX-SPEC.md
