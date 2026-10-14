# Open questions

**Status:** v0.1, 2026-10-14. **Owner:** Chris Roadfeldt.
**For:** the record of what was open before the blueprint. **All eleven were ruled on 2026-10-14, as
recommended;** each ruling is an entry in the [decision record](21-decision-record.md), O1 to O11 as D13 to
D23.

The research settled most of the shape ([what the research settled](research/README.md)). These are the
points it could not settle, because they are choices, not facts. Each has my recommendation.

| # | Question | Why it is open | My recommendation |
|---|---|---|---|
| O1 | **What may hold a merge by default?** | Blocking is a team's policy, but the blueprint needs a default. Model findings are the noisiest part. | Only stage 2 deterministic findings can hold a merge by default, on ingestion (artifact mismatch, new install script, lost provenance, invisible Unicode). Model findings never block alone; a team can raise a category to blocking once it meets the noise goal (G8). |
| O2 | **Author first: how?** | The evidence says findings should reach the author before the human reviewer. Forges differ in how to do that. | Run on draft pull requests and on push to the branch. The human reviewer is asked only after the author has seen the findings. Where the forge has no draft state, findings start collapsed for reviewers. |
| O3 | **Which ecosystems first?** | The harness has Python and Go. Most of the real ingestion incidents are npm. | Python and Go first, to share the harness's targets and adapters. npm comes in the first wave for the ingestion gate only, because that is where the attacks are. |
| O4 | **Bot identity on the forge.** | Check runs on GitHub need a GitHub App. The harness's design queue item Q7 needs the same decision. | One decision for both projects: a GitHub App per organization, with comment and check permissions only, no approval rights. |
| O5 | **Shared code with the harness.** | The LLM client, prompt sets, self-check and register machinery, run index, story, attestation, UDLM records, deploy templates and site builders are needed by both. | Copy for the first slice, then extract a shared library once both use the same piece unchanged. Decide at the start of implementation. |
| O6 | **A UDLM record type for review evidence.** | The harness added `TestEvidence` to UDLM. The reviewer's evidence needs a home too. | Propose a `ReviewEvidence` class to UDLM the same way, with the in-toto statement as its signed projection. Do it after the predicate is drafted. |
| O7 | **Where the defanged reference corpus lives.** | Even defanged reconstructions of malicious changes can trip scanners and confuse readers. | A separate public repository, clearly labelled, with each job's malicious side reduced to a harmless marker. No live samples anywhere. |
| O8 | **Publish on public benchmarks?** | Martian's bench and ReviewBench both grade with an LLM judge, and ReviewBench's publisher ranks first on it. | Report on both, with the judge named, as context only. Our own two-sided reference jobs are the measure that counts. |
| O9 | **A baseline probe now?** | The GPUs are free again. A small measured number would ground the targets before the blueprint. | Optional. If wanted: an open model reviews the 14 reference jobs' clean and malicious sides with a plain prompt, so the blueprint starts from a measured baseline. |
| O10 | **Mine AIDev for agent test-weakening?** | Nobody has measured how often agent PRs delete assertions, add skip markers or relax CI. AIDev is public. | Yes, as a small separate study once the deterministic checks exist. It is a number this project can publish first. |
| O11 | **Fullsend.** | It is the closest open relative, with Red Hat engineers among its top contributors, but it merges autonomously. | Learn from it, cite it, and offer the evidence-first findings and the ingestion checks upstream later. Do not build on it. |
