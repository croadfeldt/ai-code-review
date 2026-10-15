# Research: what the evidence says about code review, human and AI

**Date:** 2026-10-14. Every source below was fetched today.

## What this settles

This page gives AI Code Review its numbers. It answers three questions with measured data. What does human review actually catch? What do AI reviewers achieve when they run in production? And where has AI review made things worse? I use it to set target goals and to write the business case.

The short answer has five parts.

1. Human review is mostly not a bug hunt. Between 5 and 20 percent of review comments are about defects, and that range has held from Microsoft in 2013 to OpenDev in 2024 and Atlassian in 2025. Knowledge transfer and code improvement dominate.
2. In production at large companies, a well-tuned AI reviewer gets 40 to 74 percent of its comments acted on. Humans sit at 44 to 60 percent on comparable measures.
3. In open source, untuned AI review actions get 1 to 19 percent of comments acted on. Benchmarks with full PR context put precision at 2 to 17 percent. The gap between these and the industry figures is the most important fact on this page. Tuning, filtering and a noise budget are the product, not an extra.
4. AI review has measurably made things worse in four ways: slower PRs, slower reviewers, anchored reviewers who miss severe issues, and models that a crafted PR description can talk out of finding a vulnerability.
5. The only noise rule with a long production record is Google's: fewer than 10 percent effective false positives, or the check is switched off.

How I label sources. **Peer-reviewed** means a refereed venue (ICSE, FSE, TOSEM, NAACL, MSR, CACM). **Preprint** means arXiv without a confirmed venue. **Industry report** means a company describing its own internal tool, with no product to sell from the numbers. **Vendor** means the company sells the thing being measured. I weight them in that order.

## 1. Human review: the baseline

### What review finds and what people value

| Finding | Figure | Source type | Source |
|---|---|---|---|
| Defects are a minority of review comments | 78 of 570 comments (14%) were about defects; fourth of nine categories. Code improvements were first at 165 (29%). Of the defect comments, 65 were logic issues and 5 were security (§V.A, Fig. 4) | Peer-reviewed | Bacchelli & Bird, ICSE 2013 |
| Yet finding defects is the top stated motivation | 383 of 873 programmers (44%) ranked "finding defects" first (§IV) | Peer-reviewed | Bacchelli & Bird, ICSE 2013 |
| The share has held for a decade | Of 2,500 hand-coded OpenDev Nova comments, 19% fell in the "Functional" group, the most valued by developers; the authors note the ratio matches prior studies (Table 5) | Peer-reviewed (EMSE 2024) | Turzo & Bosu |
| Lower still in a 2025 industrial sample | 30 of 465 human comments (6.5%) on Atlassian pull requests were about bugs; readability was 214 (46.0%) | Preprint (Atlassian) | Goldman et al., arXiv 2510.05450 |
| Defect comments are shallow | Authors say defect comments "mostly address micro level and superficial concerns" (§V.A) | Peer-reviewed | Bacchelli & Bird, ICSE 2013 |
| At Google, education is a primary driver | Interviewees name education, norms, gatekeeping and accident prevention as the themes (§4) | Peer-reviewed | Sadowski et al., ICSE-SEIP 2018 |
| What expert reviewers prioritise | In 18,000 Meta reviews: correctness and reliability 44.4%, code quality 19.2%, security 19.1%, best practices 7.2%, performance 6.6%, design 3.6% (RQ1) | Preprint (Meta) | Maddila et al., ARCTIC, 2026 |

Bacchelli and Bird found that review is "less about defects than expected" and more about understanding, knowledge transfer and alternatives. Meta's 2026 taxonomy shows that when reviewers do write substantive comments, correctness and security are two thirds of them. Both are true. Most comments are not defects, but the comments people value most are.

A share of comments is not a detection rate. It says what reviewers spend their comments on, not how many defects they miss. Escaped defects are measured separately: Chromium OS review caught 516 security defects and let 239 through (Paul et al., ICSE 2021).

### Speed, size and effort

| Finding | Figure | Source type | Source |
|---|---|---|---|
| Google median review latency | Under 1 hour for small changes, about 5 hours for very large ones; overall median under 4 hours (§5.1) | Peer-reviewed | Sadowski et al., ICSE-SEIP 2018 |
| Other companies are slower | Median time to approval 14.7 to 19.8 hours (AMD, Chrome OS, three Microsoft projects); 24 hours in another Microsoft study (§5.1, citing Rigby & Bird) | Peer-reviewed | Sadowski et al., ICSE-SEIP 2018 |
| Google changes are small | Median 24 lines changed; over 35% touch one file; about 90% touch fewer than 10 files (§5.1) | Peer-reviewed | Sadowski et al., ICSE-SEIP 2018 |
| Time spent reviewing | Average 3.2 hours a week per developer (median 2.6) (§5.1) | Peer-reviewed | Sadowski et al., ICSE-SEIP 2018 |
| Review size limit | Review no more than 200 to 400 LOC at a time; under 500 LOC an hour; sessions of 60 minutes; 70 to 90% defect discovery in a well-run review of that size | Vendor (SmartBear, citing its Cisco study) | SmartBear best practices page |

The SmartBear figures are the most cited and the weakest. They come from a vendor of review tools, from one Cisco team in 2006, and secondary write-ups disagree on the thresholds (200, 300 or 500 LOC). I use them only for direction. The direction is confirmed for AI below: review quality falls steeply with diff size.

### Contradiction to note

Bacchelli and Bird count all comments and find few defects. ARCTIC classifies what expert reviewers chose to raise and finds correctness first. Read together: an AI reviewer that adds style comments adds to the part of review humans already over-produce.

## 2. AI and ML review in production: industry reports

### The numbers

| Company and system | What it measured | Figure | Source type | Source |
|---|---|---|---|---|
| Google, ML-suggested edits for reviewer comments (2023) | Share of previewed edits applied by authors | 40 to 50% applied; model addresses 52% of comments offline at a 50% precision target | Industry report | Google Research blog, May 2023 |
| Google, AutoCommenter (best-practice comments, 2024) | Developer "useful" ratio | Plateaued at 54%; raised to 66% by suppressing 17 non-actionable URLs; reached the 80% target after summary rewrites (§V) | Peer-reviewed (Google) | Vijayvergiya et al., AIware 2024 |
| Google, AutoCommenter | Comment resolution | About 40% of comments resolved by the author's next change; only about 10% of comments got any explicit thumbs feedback (§VI) | Peer-reviewed (Google) | Vijayvergiya et al., AIware 2024 |
| Google, Tricorder static analysis | "Not useful" rate | Most successful analyzers 0 to 3%; analyzers above 10% are disabled; 0.14 "not useful" clicks per changelist on average (§IV-E, Fig. 9) | Peer-reviewed (Google) | Sadowski et al., ICSE 2015 |
| Uber, uReview (2025) | Usefulness and addressed rate | 75% of comments marked useful; 65% addressed in the same changeset. Human comments: 51% addressed. Over 90% of about 65,000 weekly diffs covered; median 4 minutes per commit | Industry report | Uber engineering blog, Aug 2025 |
| Atlassian, RovoDev Code Reviewer (12 months, 2024-25) | Code resolution rate | 38.70% AI vs 44.45% human comments led to code changes (§4.2) | Peer-reviewed (ICSE-SEIP 2026) | Atlassian, arXiv 2601.01129 |
| Atlassian, RovoDev | PR cycle time | Median 20.73 h to 14.35 h (-30.8%); 43,633 vs 42,981 PRs; interrupted time series over 77 weeks (§4.2, Table 1) | Peer-reviewed (ICSE-SEIP 2026) | Atlassian, arXiv 2601.01129 |
| Atlassian, RovoDev | Human comments per PR | 4.45 to 2.87 (-35.6%); AI averaged 2.1 comments per PR (§4.1-4.2) | Peer-reviewed (ICSE-SEIP 2026) | Atlassian, arXiv 2601.01129 |
| Atlassian, RovoDev | Offline alignment with human comments | Only 7% of PRs had at least one AI comment matching a human one; an actionability filter added 15 to 20 points (§5) | Peer-reviewed (ICSE-SEIP 2026) | Atlassian, arXiv 2601.01129 |
| Microsoft, internal AI reviewer (2025) | PR completion time | 10 to 20% median improvement across 5,000 onboarded repositories; over 90% of PRs, 600K+ PRs a month. No acceptance rate published | Industry report | Microsoft engineering blog, Jul 2025 |
| Meta, MetaMateCR (AI fixes for reviewer comments) | Patch accepted by author | 19.75% ActionableToApplied for the best fine-tuned model, vs 10.5% for GPT-4o; offline exact match 68% (Table, §7) | Peer-reviewed (FSE 2026 industry) | Meta, arXiv 2507.13499 |
| Meta, MetaMateCR | Reviewer time | Showing AI patches to reviewers made reviews 5.5% longer (p=.029) and active review time 6.7% longer. Showing them only to authors removed the regression (§7) | Peer-reviewed (FSE 2026 industry) | Meta, arXiv 2507.13499 |
| Meta, ARCTIC code critique (2026) | What AI reviewers say vs humans | AI comments: best practices 30.8% (humans 7.2%), design 16.2% (3.6%), security 2.0% (19.1%), correctness 25.5% (44.4%) (RQ2) | Preprint (Meta) | Maddila et al., arXiv 2607.29516 |
| Meta, ARCTIC | Intent and drift | Intent prediction F1 0.86; drift scoring agreement with humans QWK 0.907; intent approved by engineers 90.2% (n=112); spotlight beats baseline AI reviewer 2.4x at 5x fewer tokens | Preprint (Meta) | Maddila et al., arXiv 2607.29516 |
| Beko, Qodo PR-Agent (3 projects, 4,335 PRs) | Comments resolved | 73.8% resolved, 21.3% "won't fix"; 68.8% of surveyed developers saw a minor quality improvement (§IV) | Peer-reviewed (ICSE-SEIP 2025) | Cihan et al., arXiv 2412.18531 |
| Beko | PR closure time | Rose from 5 h 52 min to 8 h 20 min (+42%) after rollout (§IV.3) | Peer-reviewed (ICSE-SEIP 2025) | Cihan et al., arXiv 2412.18531 |
| Mozilla and Ubisoft, RevMate (live study) | Comments accepted by reviewers | 8.1% (Mozilla) and 7.2% (Ubisoft) accepted; a further 23% and 28.3% judged useful as tips. Refactoring comments accepted at 18.2 to 18.6%, functional ones at 4.8 to 5.2%. Median 43 s extra per patch | Preprint (Mozilla, Ubisoft) | Olewicki et al., arXiv 2411.07091 |
| GitHub, Copilot code review | Reviews with any comment | 71% of reviews produce actionable feedback, 29% stay silent; about 5.1 comments per review; 60M reviews; a stronger model raised positive feedback 6% but latency 16% | Vendor | GitHub blog, Mar 2026 |

### What the industry figures agree on

Three things hold across every company that published.

- **Filtering is where the value is made.** Uber runs three filter layers and per-category confidence thresholds. Atlassian's actionability gate added 15 to 20 points. Google raised AutoCommenter from 54% to 80% useful mainly by suppressing whole categories. None of them shipped raw model output.
- **The best AI comments are acted on at about the human rate, not above it.** Atlassian measured 38.7% vs 44.5%. Google's 40% resolution sits in the same band. Uber's 65% vs 51% is the outlier. It uses an LLM to judge "addressed", while Atlassian uses code changes. I treat 40% as the evidenced floor and 65% as the evidenced ceiling.
- **Explicit feedback is rare.** About 10% of AutoCommenter comments got a thumbs click. Atlassian says thumbs were "rarely used". A target that depends on thumbs ratings will be measured on a biased tenth of the data. Measure what the author did to the code.

### Contradictions

- **PR time went down at Atlassian and Microsoft and up at Beko.** Atlassian measured -30.8% and Microsoft -10 to 20%. Beko measured +42%. Beko's authors attribute it partly to authors spending time on bot comments before human review. Meta saw review time rise 5.5% until it hid AI output from reviewers. Cycle time is a result to measure, not a benefit to assume.
- **Offline numbers overstate production.** Meta's best model matched exactly 68% offline and was applied 19.75% of the time in production. Google's 52% offline coverage became 40 to 50% application of previewed edits, and only about 40% of suggestions were previewed at launch.

## 3. Academic studies 2023-2026: accuracy, noise and harm

### Accuracy and noise

| Finding | Figure | Source type | Source |
|---|---|---|---|
| With full PR context, AI review precision is low | Best combination (PR-Review on Gemini 2.5 Pro): precision 16.65%, recall 23.18%, F1 19.38%. Four of five techniques had precision below 10%. Up to 7.6 false positives per PR (Table 4) | Peer-reviewed (FSE 2026) | Zeng et al., SWR-Bench |
| Aggregating several reviews helps | Multi-review aggregation raised F1 by up to 43.67% (abstract, §6) | Peer-reviewed (FSE 2026) | Zeng et al., SWR-Bench |
| AI review actions in open source rarely change code | Of 22,326 comments across 178 repositories: file-level actions 0.9% and 4.2% fully addressed; hunk-level actions 6.5% and 19.2%; human comments 60.0% (Table) | Preprint | Sun et al., arXiv 2508.18771 |
| What gets acted on | Concise comments, comments with code snippets, manually triggered and hunk-level comments were more likely to cause changes | Preprint | Sun et al., arXiv 2508.18771 |
| Real PRs are far harder than synthetic ones | Best model F1 0.847 on injected bugs vs 0.066 on real bug-fix PRs (-92%) | Preprint | Kumar et al., arXiv 2606.15689 |
| Review quality collapses with diff size | F1 0.657 on diffs under 10 lines vs 0.043 on diffs over 150 lines; near-zero recall on performance bugs | Preprint | Kumar et al., arXiv 2606.15689 |
| Bigger model is not always better | A smaller model beat a larger one on F1 (0.365 vs 0.343) at 3.2x lower cost per review, reproduced on Martian's benchmark | Preprint | Kumar et al., arXiv 2606.15689 |
| An AI reviewer aims at defects and often misses | CodeRabbit in open source: 43.3% of its comments were about functional defects, a rising share, and 35.8% of those were rejected as invalid. 36.4% of all its comments were accepted, 56.3% rejected | Preprint | Lin et al., arXiv 2607.03316 |
| Bug comments are acted on as often as others | Resolution of 4,000 LLM comments at Atlassian: readability 43.3%, bugs 41.9%, maintainability 36.2%, design 28.6%. Resolved means the commented line changed | Preprint (Atlassian) | Goldman et al., arXiv 2510.05450 |
| LLM security review flags almost everything | Apparent false positive rate on already-fixed code at least 88% for five of six models; 75% of a manual sample were genuine false positives (§III) | Preprint | Alexopoulos et al., arXiv 2603.18740 |

### Studies where AI review made things worse

| Finding | Figure | Source type | Source |
|---|---|---|---|
| AI review anchors human reviewers | In a controlled experiment with 29 professional developers and 50+ hours of recordings, reviewers given an AI review focused on the locations it flagged. They found more low-severity issues, not more high-severity ones. Review time and confidence did not improve | Peer-reviewed (ICSE 2025) | Tufano et al., arXiv 2411.11401 |
| PR descriptions can switch off AI security review | Detection on vulnerable code fell from 97.2% under neutral framing to 3.6% under a strong "bug-free" framing for one model (Table II) | Preprint | Alexopoulos et al., arXiv 2603.18740 |
| Attackers can craft that framing | An iterative refinement attack re-introduced a known vulnerability past the AI reviewer in 32 of 33 cases (97%): 17/17 on one pipeline, 15/16 on another | Preprint | Alexopoulos et al., arXiv 2603.18740 |
| Redacting metadata is a working defence | Removing the PR description recovered detection in 16 of 32 cases; also removing commit messages and code comments recovered 12 of the remaining 16 (§IV, RQ3) | Preprint | Alexopoulos et al., arXiv 2603.18740 |
| AI review slows PRs | Beko +42% closure time; Meta +5.5% review time when reviewers saw AI patches (see section 2) | Peer-reviewed | Cihan et al.; Meta |
| Perceived speed is not real speed | 16 experienced developers took 19% longer with AI tools but believed they were 20% faster (RCT, 246 issues). METR's 2026 follow-up said its new data was too biased by selection to measure the current effect | Industry research (non-profit) | METR, Jul 2025 and 2026 note |
| AI adoption and delivery stability | Each 25% rise in AI adoption associated with +3.1% code review speed but an estimated -1.5% throughput and -7.2% delivery stability; 39% of respondents have little or no trust in AI code | Industry survey | DORA 2024 (Google Cloud announcement) |

The anchoring result matters most for design. An AI review shown to the human reviewer as a starting point narrows where the human looks. Meta's fix (show AI output to the author, not the reviewer) and ARCTIC's "spotlight" (point the reviewer at the riskiest regions instead of listing comments) are two answers to it.

The framing result matters most for the ingestion gate. An AI reviewer that reads the PR description is reading attacker-controlled text. For code we did not write, that is the threat model.

### The static analysis noise literature

| Finding | Figure | Source type | Source |
|---|---|---|---|
| Developers abandon noisy tools | All 20 interviewed developers saw value in static analysis; false positives and warning presentation were the main barriers | Peer-reviewed (ICSE 2013) | Johnson et al. |
| Google's rule for code review checks | "Produce less than 10% effective false positives. Developers should feel the check is pointing out an actual issue at least 90% of the time." | Peer-reviewed (CACM 2018) | Sadowski et al. |
| Enforcement | Analyzers whose "not useful" ratio exceeds 10% are disabled until fixed | Peer-reviewed (CACM 2018) | Sadowski et al. |

Google defines an effective false positive as any finding the developer takes no action on, whatever its technical correctness. That definition is the right one for AI review. It does not ask whether the model was technically right. It asks whether a developer acted. That is also what Atlassian, Google and Martian measure. By that rule, the best production AI reviewers today (about 26 to 62 percent not acted on) are well above Google's 10 percent bar for static analysis. The bar has to apply per finding category, not to the tool as a whole, or the tool will never pass.

## 4. Benchmarks and datasets

| Benchmark | What it measures | Size | Licence | Last updated | Is the metric meaningful? |
|---|---|---|---|---|---|
| CodeReviewer (Microsoft, FSE 2022) | Quality estimation, comment generation, refinement on diff hunks | Pre-training on 7.9M PRs; benchmark from GitHub projects in 9 languages | Code MIT; data from permissively licensed repos | Repo last pushed 2023-07-09 | Weak. Best comment-generation BLEU was 5.32; the authors note BLEU stayed under 10 even for good comments |
| SWR-Bench (FSE 2026) | PR-level review with full project context; change-action hit precision, recall, F1 | 1,000 verified PRs: 500 with issues, 500 clean (to measure false positives) | Paper CC BY 4.0; data repo not confirmed | Paper v2, 2026-06-05 | Yes. LLM judge agreed with humans at Kappa 52.8 to 62.0, matching inter-human 56.3 to 62.6. BLEU scored -35 to -41 Kappa, worse than chance |
| ContextCRBench (2025) | Hunk quality, line-level defect localisation, comment generation with issue and PR text | 67,910 entries from 153.7K issues and PRs | Repo has no licence file | Repo pushed 2026-02-27 | Partly. Shows textual context helps more than code context; generation still graded by similarity |
| CodeReviewQA (Melbourne and SMU, 2025) | Comprehension of review comments as multiple choice: change type, location, solution | 900 curated examples, 9 languages, 72 models evaluated | MIT (Hugging Face) | 2026-02-28 | Yes for comprehension. Built to avoid text-match metrics and contamination. It does not measure finding issues |
| CRScore (NAACL 2025) | Reference-free metric for review comment quality | 2.9K human-annotated quality scores | MIT | 2025-11-14 | Better than BLEU: 0.54 Spearman with human judgement, the highest of open metrics tested |
| ReviewBench (GitHub with Microsoft) | Grounded precision and recall against golden findings | 219 PRs from 187 repositories, 19 languages | MIT (repository, checked 2026-10-14) | 2026-10-05 | Yes in design. But the publisher's own tool ranks first (grounded F1 40.1%), and rivals were tested months earlier |
| Martian Code Review Bench | Offline (50 PRs, golden comments) and online (developer action on real open source PRs) | Online track over many thousands of PRs; exact count varies by source | MIT (repository, checked 2026-10-14) | Online leaderboard snapshot 2026-10-06 | The online track is the closest public proxy for production. Martian made it the headline after offline scores diverged from real use. Top online F1 about 61 to 65% (secondary reporting) |
| AIDev (agentic PRs) | Dataset of PRs authored by coding agents, not a review benchmark | 456K PRs in v1 paper; 932,791 in later use | CC BY 4.0 (Hugging Face) | 2026-10-09 | Useful for studying agent PRs. Acceptance rates depend heavily on the subset (see section 5) |

The lesson from benchmarks is about metrics. BLEU against a human comment is worse than useless for review. SWR-Bench showed it inversely correlated with F1: hunk-level models score high BLEU and low F1. Any internal benchmark for AI Code Review must grade by "did the finding hit a real issue", include clean PRs to count false positives, and be checked against an online measure of developer action.

## 5. AI-authored pull requests

| Finding | Figure | Source type | Source |
|---|---|---|---|
| Agent PRs are accepted less often than human PRs | Codex 64%, Devin 49%, Copilot agent 35% accepted; 15 to 40 points below humans (Finding #2) | Preprint | Li et al., AIDev, arXiv 2507.15003 |
| Same dataset, different subset, higher numbers | In repositories with 100+ stars: Codex 85.8%, Cursor 74.6%, Claude Code 71.3%, Devin 55.5%, Copilot 55.0%, humans 82.6% (Table 1) | Preprint (MSR-style) | Nakashima et al., arXiv 2602.04226 |
| Claude Code PRs in 157 projects | 83.8% accepted vs 91.0% for human PRs; 54.9% of merged agent PRs needed no further change vs 58.5% for human PRs | Peer-reviewed (TOSEM) | Watanabe et al., arXiv 2509.14745 |
| Most rejections carry no stated reason | 67.9% of 654 rejected agent PRs had no explicit reviewer feedback. Seven rejection modes appear only for agents, including distrust of AI code | Preprint | Nakashima et al., arXiv 2602.04226 |
| Rejection overstates agent error | Of rejected agent PRs, 35.7% were clear agent failures, 31.2% workflow constraints, 33.1% no visible rationale. Of merged ones, 15.4% needed reviewer feedback or commits (MSR 2026) | Peer-reviewed (MSR 2026) | Peralta et al., arXiv 2605.22534 |
| Agent PRs are often not reviewed at all | 58.2% of agent PRs and 75.3% of human PRs had no explicit review; bots reviewed 20.1% of agent PRs vs 10.0% of human PRs | Preprint | Li et al., AIDev |
| AI-authored PRs carry more review findings | 10.83 issues per PR vs 6.45 for human-only (about 1.7x); logic and correctness 75% more; security up to 2.74x. Authorship was inferred, not verified | Vendor | CodeRabbit, Dec 2025 (470 PRs) |
| Reviewers of agent PRs comment on correctness most | Of 19,007 inline comments on 3,162 agent-authored PRs (AIDev): functional correctness and feature work 38.5% of comments and 46.5% of PRs; refactoring 14%; documentation 11.4%; security 2.9% | Peer-reviewed (MSR 2026) | Haider & Zimmermann, arXiv 2601.19287 |
| More PRs, slower review | High-AI-adoption teams merged 98% more PRs; review time rose 91%; PR size rose 154%; bugs per developer rose 9% | Vendor telemetry | Faros AI, Jul 2025 (10,000+ developers) |
| Intent drift is measurable | Meta scores divergence between a developer's stated intent and an agent's diff; agreement with human annotators QWK 0.907; drift scores reduced misalignment by a further 5.76 points (p=0.026) in rollout | Preprint (Meta) | Maddila et al., ARCTIC |

### Contradictions

- **Agent acceptance rates disagree by up to 20 points for the same agent.** AIDev v1 reports Codex at 64%. The 100-star subset reports 85.8%. Human baselines also differ (82.6% vs 91.0%). The cause is sampling: popular repositories, closed-only PRs, and different time windows. I will not quote a single "agent PR acceptance rate" in the business case.
- **Scope creep is a reported complaint, not a measured rate.** Beko developers said the bot "makes suggestions that fix code blocks that are not in the scope of the task". Rejection studies list "too large" (1.5% of agent rejections vs 0% human) and "increase complexity". I found no study that measures description-vs-diff mismatch as a rate. ARCTIC's drift score is the only working measurement, and its dataset is internal.

## 6. Cost

| Finding | Figure | Source type | Source |
|---|---|---|---|
| Tokens and money per PR | 3,937 tokens per PR on average, $0.48 per PR (§V.A) | Peer-reviewed (ICSE-SEIP 2025) | Cihan et al., Beko |
| Agentic vs single-pass tokens | 52,191 tokens agentic vs 8,089 zero-shot per review | Preprint (Meta) | Maddila et al., ARCTIC |
| Small models on small diffs | $0.003 vs $0.010 per review for a small vs large model on a 150-sample set | Preprint | Kumar et al., arXiv 2606.15689 |
| Latency | Median 4 minutes per commit in CI | Industry report | Uber uReview |
| Reviewer cost of AI comments | Median 43 seconds extra per patch to inspect or edit generated comments | Preprint | Olewicki et al., RevMate |

Token cost is small next to people cost. At $0.48 a PR, a review costs less than one minute of an engineer. The real cost is the time a developer spends on a comment that was not worth acting on. That is why the noise budget is the cost control.

## Candidate target goals

Each target names the measurement, the evidence and the reason. "Team-set" means I found no source and the team must choose.

| # | Measurement | Target | Evidence | Why |
|---|---|---|---|---|
| T1 | Effective false positive rate per finding category: findings the author did not act on, over all findings | Under 10% for a category to stay on by default; categories above it are switched off until fixed | Google rule, Sadowski et al. CACM 2018; Tricorder ICSE 2015 | The only noise rule with a decade of production use. Per category, because no AI reviewer passes it as a whole today |
| T2 | Code resolution rate across all findings: findings followed by a code change at that location | At least 40% at pilot; 65% as the stretch | 38.7% Atlassian; about 40% Google AutoCommenter; 65% Uber; humans 44 to 60% | Matches the human band. Below 40% the tool costs more attention than it returns |
| T3 | Useful rate from explicit ratings | At least 75% | Uber 75%; Google AutoCommenter target 80% | A sanity check only. Ratings cover about 10% of comments |
| T4 | Findings per PR | Median of 3 or fewer | Atlassian 2.1 AI comments per PR; humans 4.45; GitHub 5.1. Exact cap is team-set | Fewer, better comments. The noise budget in numbers |
| T5 | Silence on clean changes: share of PRs with no finding when there is nothing to find | At least 30% of all PRs silent; zero findings on a held-out set of clean PRs at the 50th percentile | GitHub 29% silent; SWR-Bench clean-PR split | A reviewer that always speaks teaches people to ignore it |
| T6 | Severity mix: share of findings that are correctness or security | At least 50% | Human expert mix is 63.5% (ARCTIC); current AI is 27.5% | Aims the tool at what reviewers value, away from style |
| T7 | PR cycle time, by interrupted time series against the pre-rollout trend | No increase at pilot; 10% median reduction as the goal | Microsoft -10 to 20%; Atlassian -30.8%; Beko +42% | The evidence goes both ways, so the first goal is to do no harm |
| T8 | Human reviewer active time per PR | No increase | Meta +5.5% when AI output shown to reviewers | Directly tests the anchoring and distraction risk |
| T9 | High-severity issues found by humans with the tool vs without | No decrease | Tufano et al. 2025 anchoring result | Catches over-trust. Needs a periodic controlled sample, not telemetry |
| T10 | Framing robustness on a canary set of known-vulnerable changes | Zero detections lost between a run with PR metadata and a run with it redacted | Alexopoulos et al. 2026: 97% attack success; redaction restored detection | The ingestion gate reads attacker-controlled text |
| T11 | Description-vs-diff drift flagged on every ingestion | Every ingested change gets a drift verdict; agreement with human spot checks is team-set (ARCTIC reached QWK 0.907) | ARCTIC | Agent PRs and vendored code are where stated intent and diff part ways |
| T12 | Latency, from push to findings | Median under 5 minutes | Uber 4 minutes; Google median human first response under 1 hour | Findings must land before the human reviewer starts |
| T13 | Cost per PR | Under $0.50 median; team-set ceiling for large diffs | Beko $0.48; ARCTIC 8K to 52K tokens | Keeps the business case honest at fleet scale |
| T14 | Large-diff handling | Diffs over 400 changed lines get a "split or spotlight" notice instead of line findings | SmartBear 200 to 400 LOC (vendor); AI F1 falls from 0.657 to 0.043 above 150 lines | Neither humans nor models review large diffs well |

## What this changes in the plan

1. **The noise budget becomes a rule with a number.** Each finding category carries its own effective false positive rate, measured as "author did not act". Above 10% it is off by default. This is Google's rule, and it gives the "noise has a budget" principle teeth.
2. **Measure action on code, not ratings.** The primary signal is whether the code at the finding's location changed before merge. Thumbs feedback is a secondary signal because about 90% of comments never get one.
3. **Show findings to the author first.** Meta's reviewer-time regression and Tufano's anchoring result both point the same way. The author sees and resolves findings before the human reviewer is asked. The reviewer sees a short spotlight of risky regions and what was resolved, not a list of AI comments to confirm.
4. **The ingestion gate runs twice: once blind.** For code we did not write, run one pass with the PR description, commit messages and code comments redacted. A finding that appears only in the blind pass is itself a signal. This is the only measured defence against framing attacks.
5. **Add a drift check as a first-class finding.** For agent-authored and third-party changes, compare stated intent with the diff and report the mismatch with evidence. ARCTIC shows it can be measured with high agreement.
6. **Prefer hunk-level, concise findings with a code snippet.** The open source study found these are acted on far more often than file-level summaries. It fits "every finding carries evidence".
7. **Aggregate several review passes before posting.** SWR-Bench measured up to 43.67% better F1 from multi-review aggregation. The cost is tokens, which are cheap next to attention.
8. **Choose the model by measurement, not size.** A smaller model beat a larger one on real code review at a third of the cost. Model choice belongs in the evaluation harness, re-run on each model release.
9. **Grade the internal benchmark the right way.** No BLEU. Grade by hits against known issues, include clean PRs to count false positives, and check offline scores against the production resolution rate. At Meta, offline exact match (68%) was about three times the production acceptance rate (19.75%).
10. **Promise "no harm, then gains" in the business case.** The evidence for faster PRs is real (Atlassian, Microsoft) but so is the evidence for slower ones (Beko, Meta). The pilot commits to T7 and T8 as guardrails, measured by interrupted time series, and claims the gain only if it shows up.
11. **Do not quote an agent-PR acceptance rate.** The published figures differ by up to 20 points for the same agent. Quote the stable findings instead: agent PRs are accepted less often than human ones, most rejections carry no stated reason, and many agent PRs get no review at all.

## Sources

All fetched 2026-10-14.

**Peer-reviewed**
- Bacchelli, A. and Bird, C. "Expectations, Outcomes, and Challenges of Modern Code Review." ICSE 2013. https://sback.it/publications/icse2013.pdf.
- Turzo, A. K. and Bosu, A. "What Makes a Code Review Useful to OpenDev Developers? An Empirical Investigation." EMSE 29(1), 2024. https://arxiv.org/abs/2302.11686.
- Paul, R. et al. "Why Security Defects Go Unnoticed during Code Reviews? A Case-Control Study of the Chromium OS Project." ICSE 2021. https://arxiv.org/abs/2102.06909.
- Haider, M. A. and Zimmermann, T. "Understanding Dominant Themes in Reviewing Agentic AI-authored Code." MSR 2026. https://arxiv.org/abs/2601.19287.
- Sadowski, C. et al. "Modern Code Review: A Case Study at Google." ICSE-SEIP 2018. https://sback.it/publications/icse2018seip.pdf.
- Sadowski, C. et al. "Tricorder: Building a Program Analysis Ecosystem." ICSE 2015. https://static.googleusercontent.com/media/research.google.com/en//pubs/archive/43322.pdf.
- Sadowski, C. et al. "Lessons from Building Static Analysis Tools at Google." CACM 61(4), 2018. https://6826.csail.mit.edu/2020/papers/google-analysis-cacm.pdf.
- Johnson, B. et al. "Why Don't Software Developers Use Static Analysis Tools to Find Bugs?" ICSE 2013. https://research.google/pubs/pub43477/.
- Li, Z. et al. "CodeReviewer: Automating Code Review Activities by Large-Scale Pre-training." FSE 2022. https://arxiv.org/pdf/2203.09095.
- Vijayvergiya, M. et al. "AI-Assisted Assessment of Coding Practices in Modern Code Review." AIware 2024. https://arxiv.org/pdf/2405.13565.
- Cihan, U. et al. "Automated Code Review In Practice." ICSE-SEIP 2025. https://arxiv.org/pdf/2412.18531.
- Tufano, R. et al. "Deep Learning-based Code Reviews: A Paradigm Shift or a Double-Edged Sword?" ICSE 2025. https://arxiv.org/pdf/2411.11401.
- Meta. "AI-Assisted Fixes to Code Review Comments at Scale." FSE 2026 industry track. https://arxiv.org/pdf/2507.13499.
- Atlassian. "RovoDev Code Reviewer: A Large-Scale Online Evaluation of LLM-based Code Review Automation at Atlassian." ICSE-SEIP 2026. https://arxiv.org/html/2601.01129v1.
- Zeng, Z. et al. "SWR-Bench: Assessing LLM Performance in Real-World Code Review Comment Generation." FSE 2026. https://arxiv.org/pdf/2509.01494.
- Naik, A. et al. "CRScore." NAACL 2025. https://arxiv.org/pdf/2409.19801.
- Watanabe, M. et al. "On the Use of Agentic Coding: An Empirical Study of Pull Requests on GitHub." TOSEM. https://arxiv.org/pdf/2509.14745.
- Peralta, S. R. O. et al. "Why Are Agentic Pull Requests Merged or Rejected?" MSR 2026. https://arxiv.org/pdf/2605.22534.

**Preprints**
- Maddila, C. et al. "From Code Review to Code Critique: Intent, Drift, and Spotlight for AI-Generated Diffs at Scale." Meta, arXiv 2607.29516 v2, 2026-08-14. https://arxiv.org/pdf/2607.29516.
- Olewicki, D. et al. "Impact of LLM-based Review Comment Generation in Practice" (RevMate). arXiv 2411.07091. https://arxiv.org/pdf/2411.07091.
- Sun, K. et al. "Does AI Code Review Lead to Code Changes? A Case Study of GitHub Actions." arXiv 2508.18771. https://arxiv.org/pdf/2508.18771.
- Alexopoulos, G. et al. "Measuring and Exploiting Contextual Bias in LLM-Assisted Security Code Review." arXiv 2603.18740 v4, 2026-09-23. https://arxiv.org/pdf/2603.18740.
- Kumar, S. P. et al. "Bigger Isn't Always Better: A Comparative Evaluation of LLMs for Automated Code Review." arXiv 2606.15689. https://arxiv.org/pdf/2606.15689.
- Hu, R. et al. "Benchmarking LLMs for Fine-Grained Code Review with Enriched Context in Practice" (ContextCRBench). arXiv 2511.07017 v2. https://arxiv.org/pdf/2511.07017.
- Lin, H. Y. et al. "CodeReviewQA." arXiv 2503.16167 v2. https://arxiv.org/pdf/2503.16167.
- Li, H. et al. "The Rise of AI Teammates in Software Engineering (SE) 3.0" (AIDev). arXiv 2507.15003. https://arxiv.org/pdf/2507.15003.
- Nakashima, S. et al. "Why Agentic-PRs Get Rejected: A Comparative Study of Coding Agents." arXiv 2602.04226. https://arxiv.org/pdf/2602.04226.
- Goldman, S. et al. "What Types of Code Review Comments Do Developers Most Frequently Resolve?" Atlassian, arXiv 2510.05450. https://arxiv.org/pdf/2510.05450.
- Lin, H. Y. et al. "Is Agentic Code Review Helpful? Mining Developers' Feedback to CodeRabbit Reviews in the Wild." arXiv 2607.03316 v2, 2026-07-24. https://arxiv.org/abs/2607.03316.

**Industry reports**
- Google Research. "Resolving code review comments with ML." 2023-05-23. https://research.google/blog/resolving-code-review-comments-with-ml/.
- Uber Engineering. "uReview." 2025-08-12. https://www.uber.com/en-US/blog/ureview/. The post gives both 65,000 diffs a week and 65,000 a month in different sections.
- Microsoft Engineering. "Enhancing Code Quality at Scale with AI-Powered Code Reviews." 2025-07-14. https://devblogs.microsoft.com/engineering-at-microsoft/enhancing-code-quality-at-scale-with-ai-powered-code-reviews/.
- METR. "Measuring the Impact of Early-2025 AI on Experienced Open-Source Developer Productivity." 2025-07-10. https://metr.org/blog/2025-07-10-early-2025-ai-experienced-os-dev-study/.
- DORA 2024 report announcement. Google Cloud. https://cloud.google.com/blog/products/devops-sre/announcing-the-2024-dora-report.

**Vendor**
- GitHub. "60 million Copilot code reviews and counting." 2026-03-05. https://github.blog/ai-and-ml/github-copilot/60-million-copilot-code-reviews-and-counting/.
- GitHub ReviewBench, as described by DevX. 2026-10-05. https://www.devx.com/coding/what-is-reviewbench-ai-code-review-benchmark/.
- Martian Code Review Bench, leaderboard as reported secondhand (primary page not reached). Snapshot 2026-10-06.
- CodeRabbit. "State of AI vs Human Code Generation Report." 2025-12-17. https://www.coderabbit.ai/blog/state-of-ai-vs-human-code-generation-report.
- Faros AI. "The AI Productivity Paradox Report 2025." 2025-07-23. https://www.faros.ai/blog/ai-software-engineering.
- SmartBear. "Best Practices for Code Review." https://smartbear.com/learn/code-review/best-practices-for-peer-code-review/.

**Repository and dataset metadata** (licence and last update checked through the GitHub and Hugging Face APIs today): microsoft/CodeBERT, kinesiatricssxilm14/ContextCRBench, atharva-naik/CRScore, Tomo-Melb/CodeReviewQA, hao-li/AIDev.

**Not verified.** Mäntylä and Lassenius (TSE 2009) is often cited for "75% of review defects are evolvability". I reached only secondary summaries, which give 60 to 75% or 71%, so I left it out of the tables. The Martian leaderboard figures come from secondary reporting; I could not reach Martian's own page.
