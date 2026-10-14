# Target goals

**Status:** v0.1, 2026-10-14. **Owner:** Chris Roadfeldt.
**For:** whoever will judge whether AI Code Review works, and the team that will own the numbers.

These are the goals a run and a pilot are judged against. Each goal names what is measured, a proposed
target, where the figure comes from, and the record it will be read from once the implementation exists.
The records are planned names, not files yet. "Team-set" means I found no source for a number, so the
team that adopts the reviewer chooses it. Every target here is a default the team owns and can change.
None is justified by a timing from my lab.

## Guarantees: these hold on every run, or the run is wrong

| # | Goal | Measurement | Target | Source | Read from |
|---|---|---|---|---|---|
| G1 | Never approves | Approving or change-requesting reviews posted by the reviewer | Zero | SLSA v1.2 trusted person is "a human"; Scorecard: AI reviews "do not count" ([standards](research/practice-and-standards.md)) | Forge audit, `report/posted.json` |
| G2 | Every finding is grounded | Findings shown whose file and line exist at the head revision and whose rule is in the catalogue | 100% | Google eng-practices "facts and data overrule opinions" | `grounding/results.json` |
| G3 | The model never clears a deterministic finding | Deterministic findings missing from the final report | Zero | Thornton 2026: static cross-check best defence ([threats](research/threats-and-ingestion.md)) | `gate/findings.json` against `report/findings.sarif` |
| G4 | No silent pass | Reports that list what was checked and what was not, with no pass wording | 100% | Tufano et al. ICSE 2025 anchoring ([efficacy](research/efficacy.md)) | `report/story.md` |
| G5 | Bound to the final revision | Signed statements whose subject is the head commit digest | 100% | SLSA v1.2 [Final revision approved] | `attest/statement.json` |
| G6 | Reproducible | Runs that record model, prompt set, tool versions and image digests | 100% | Harness principle 5, carried over | `run.json` |
| G7 | The reviewer cannot act | Runs whose model step had no shell, network, write token or secret, proven by stage 0 probe | 100% | Comment and Control, Clinejection, GitHub MCP case ([threats](research/threats-and-ingestion.md)) | `selfcheck/selfcheck.json` |

## Quality: measured per run and over the pilot

| # | Goal | Measurement | Proposed target | Source | Read from |
|---|---|---|---|---|---|
| G8 | Noise per category | Effective false positive rate: findings whose code was not changed before merge and not answered with a reason, over all findings, per finding category | Under 10% for a category to stay on by default | Google, Sadowski et al. CACM 2018; Tricorder ICSE 2015 | `feedback/acted-on.json` |
| G9 | Comments acted on | Findings followed by a code change at their location before merge | At least 40% at pilot; 65% stretch | Atlassian 38.7%; Google about 40%; Uber 65%; humans 44 to 60% | `feedback/acted-on.json` |
| G10 | Few findings per change | Median findings per pull request | 3 or fewer; exact cap team-set | Atlassian 2.1 AI comments per PR; humans 4.45 | `report/findings.sarif` |
| G11 | Silence when there is nothing to find | False findings on the clean side of the reference jobs | Zero on the clean half of two-sided jobs | SWR-Bench clean-PR split; GitHub reports 29% of reviews silent | `evaluate/reference-jobs.json` |
| G12 | Aimed at what matters | Share of findings that are correctness or security | At least 50% | Expert human mix 63.5%, current AI 27.5% (Meta ARCTIC) | `report/findings.sarif` |
| G13 | Injection invariance | Changes whose verdict differs between the full and the blind pass, on the injection reference jobs | Zero verdicts lost to framing; every difference surfaced as `suspicious` | Alexopoulos et al. 2026: 32 of 33 framing attacks succeeded; redaction restored detection | `review/passes.json` |
| G14 | Intent against diff | Changes that get a drift verdict, and agreement with human spot checks | Every change; agreement team-set (Meta reached QWK 0.907) | Meta ARCTIC | `review/drift.json` |
| G15 | Large changes handled honestly | Diffs over the team's size limit that get a split-or-scope notice instead of line findings | 100%; limit team-set, 400 changed lines proposed | Model F1 0.657 under 10 lines, 0.043 over 150 (Kumar et al.); SmartBear 200 to 400 LOC (vendor) | `report/story.md` |

## Ingestion gate

| # | Goal | Measurement | Proposed target | Source | Read from |
|---|---|---|---|---|---|
| G16 | Two-sided reference jobs | Jobs where the malicious side is flagged and the clean neighbour is not, over the 14 candidate jobs | All 14 | Candidate jobs in [threats](research/threats-and-ingestion.md) | `evaluate/reference-jobs.json` |
| G17 | Deterministic jobs need no model | Jobs 1, 2, 5, 6, 9 and 13 caught by stage 2 alone | All six | Same; if the model is needed, the design has a hole | `evaluate/reference-jobs.json` |
| G18 | Known malicious packages | F1 on the npm detector benchmark of arXiv 2603.27549 | At least GuardDog's 93.32%, since GuardDog is a component | Benchmark of 11 detectors, 2026 | `evaluate/npm-benchmark.json` |
| G19 | Artifact checked against source | Dependency bumps where the installed artifact was diffed against the tagged source, or the reason it could not be | 100% | 12 of 21 incidents not in the source diff | `intake/<pkg>/artifact-diff.json` |

## Cost and effect on people

| # | Goal | Measurement | Proposed target | Source | Read from |
|---|---|---|---|---|---|
| G20 | Cost counted in units that travel | Prompt and completion tokens, and CPU-minutes, per pull request | Recorded on every run; ceiling team-set | Reference figures: 3,937 tokens per PR (Beko); 8K to 52K tokens (Meta ARCTIC) | `run.json` |
| G21 | Findings land before the human starts | Push to findings, median | Under 5 minutes proposed; team-set | Uber median 4 minutes | `run.json` |
| G22 | Do no harm to cycle time | PR cycle time against the pre-rollout trend, by interrupted time series | No increase at pilot; a reduction is claimed only if measured | Atlassian -30.8%, Microsoft -10 to 20%, Beko +42% | Pilot report |
| G23 | Do no harm to reviewers | Human reviewer active time per PR, and high-severity issues found by humans in a periodic controlled sample | No increase in time; no decrease in issues found | Meta +5.5% review time; Tufano anchoring | Pilot report |

Goals G22 and G23 are guardrails for the pilot, not per-run checks. The evidence on cycle time goes both
ways, so the first promise is that the reviewer does no harm, and any gain is reported only when measured.
