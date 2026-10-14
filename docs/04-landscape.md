# Landscape: existing work relevant to AI Code Review

**Status:** research track A, draft v0.1
**Date:** 2026-10-14
**Owner:** Chris Roadfeldt
**Settles:** what AI Code Review can reuse, learn from, benchmark against, or must avoid. It feeds the capability map; it does not choose the architecture.

I compiled this on 2026-10-14. I verified every repository through the GitHub REST API or its project page on that date. Stars, versions and push dates are as of that date. "Maintained" means a release or a push in 2026 unless stated. Where a number comes from a vendor or a secondary write-up, I mark it as a claim.

---

## 1. Headline findings

1. **Nobody ships the ingestion gate.** LLM pull-request reviewers are plentiful for first-party code. None of them, open or commercial, reviews the true upstream source diff behind a dependency bump, checks it against the published artifact, and reports with evidence. The pieces exist in separate tools: OSSGadget `oss-diff` and `oss-detect-backdoor`, Chainguard malcontent `diff`, OpenSSF Package Analysis, OSS Rebuild and Oracle Macaron. Nothing assembles them, and nothing reads OpenVEX, in-toto or UDLM evidence.
2. **The first-party reviewer shape is now a commodity.** Claude Code Review, Copilot code review, CodeRabbit (as described in Fullsend's landscape) and Red Hat-led Fullsend have converged on one design: specialist agents run in parallel, a verification pass filters false positives, findings are ranked by severity and posted inline. Building another one of these adds nothing. The value is in evidence, ingestion, and refusing authority.
3. **Approval authority is drifting to bots, so "never approve" is a real position.** Copilot code review can now submit an approving review when an organisation enables it. Fullsend's review agent applies `ready-for-merge` and can close a PR it rejects. Claude Code Review is the counter-example: its check run always completes neutral. AI Code Review sits with the last group by design.
4. **PR-Agent is permissive again, but only from v0.40.0.** Its licence went Apache-2.0 (2023), AGPL-3.0 (May 2025), Apache-2.0 (May 2026), MIT (July 2026), per the LICENSE commit history. It now lives in a community org, The-PR-Agent, and calls itself a "community-maintained legacy project of Qodo." Releases v0.30 to v0.35.0 shipped under AGPL. The other well-known open reviewer, Kodus, is AGPL-3.0 with a commercial enterprise directory.
5. **Red Hat has the substrate and one close relative, not the product.** Fullsend (Apache-2.0, Red Hat engineers among the top contributors, configured for konflux-ci, conforma, quay and redhat-appstudio) is the nearest open project to this one, but it is an autonomous merge system. Konflux already runs deterministic source checks, including a Trojan Source scan. Conforma already gates on attestations. sast-ai-workflow shows how Red Hat scores confidence on an LLM verdict. Nothing at Red Hat reviews dependency source diffs for backdoors.
6. **Independent measurement of AI reviewers only began in 2026, and it is thin.** Martian's Code Review Bench (MIT) and GitHub's ReviewBench (5 October 2026) publish data and judges. Both use an LLM judge. ReviewBench's answer key includes tool findings, and one secondary report says Copilot supplied 1,185 of its 2,623 true positives. Vendor benchmarks, such as Greptile's 50-case table, are claims. The one peer-reviewed field study found 73.8% of automated comments resolved, but average PR closure time rose from 5 h 52 m to 8 h 20 m.
7. **LLM reviewers can be steered by the code they read.** ALIBI (July 2026) beat four LLM vulnerability detectors more than 90% of the time with adversarial code comments. PromptPwnd and CamoLeak showed prompt injection through PR text in CI agents and Copilot Chat. Anthropic's own security-review Action says it "is not hardened against prompt injection attacks." For a gate whose job is to read hostile code, this is the central design constraint, not an edge case.
8. **The deterministic layer is mature, and mostly permissive, with four licence traps.** reviewdog, Opengrep, gosec, bandit, ruff, gitleaks, OSV-Scanner, Scorecard, GuardDog and ScanCode are all maintained and Apache, MIT, BSD or LGPL. The traps: the CodeQL CLI may only be used on open source codebases; the Semgrep rules licence forbids redistribution or offering them as a service; TruffleHog and packj are AGPL-3.0.
9. **Cheap malicious-package detection already works on known patterns.** A 2026 study of 11 npm detectors put GuardDog at 93.32% F1, the best conventional tool, and found 80.3% of malware uses no evasion at all. The gap is the subtle case: a backdoor in a legitimate project's source or build files, as with xz, where the payload lived only in the release tarball.
10. **IBM offers one reusable component and no reviewer.** CodeLLM-Devkit (Apache-2.0) gives call graphs and reachability for LLM context. I found no IBM open source reviewer and no IBM paper on LLM code review. IBM Bob has a review mode but is commercial.

---

## 2. Red Hat

### 2.1 AI-assisted review, triage and agents

| Project | What it is | Licence | Maintained | AI | Relevance |
|---|---|---|---|---|---|
| [Fullsend](https://github.com/fullsend-ai/fullsend) | Autonomous SDLC agents for GitHub, GitLab and Forgejo: triage, code, review, fix, retro. The review agent runs a `pr-review` orchestrator that dispatches parallel sub-agents (correctness, security, intent, style, docs), dedupes, validates JSON output against a schema, and posts inline comments. Sandboxed in NVIDIA OpenShell. 155 stars, created March 2026. Top contributors include ralphbean and waynesun09; `.fullsend` config repos exist for konflux-ci, conforma, quay, redhat-appstudio. | Apache-2.0 | Yes, v0.47.1, 2026-10-11 | Claude Code, Codex, Pi | **Closest relative.** Learn from its schema-validated findings, read-only review sandbox, ADR 0089 risk scoring and ADR 0017 credential isolation. Do not adopt its authority model: the agent labels `ready-for-merge` and closes PRs it rejects. |
| [sast-ai-workflow](https://github.com/RHEcosystemAppEng/sast-ai-workflow) | LangGraph agent that triages SAST findings for false positives. Confidence 0 to 100, weighted from agent certainty (about 37.5%), investigation depth (about 37.5%) and evidence strength (about 25%). Tekton packaging, FAISS store of known false positives. 22 stars. | Apache-2.0 | Yes, last commit 2026-06-29 | Yes | Pattern for confidence that is computed from evidence, not just asked of the model. |
| [Aegis AI](https://github.com/RedHatProductSecurity/aegis-ai) | Product Security agent for CVE and component analysis over OSIDB, Trustify, osv.dev and CWE. 32 stars. | MIT | Yes, 0.10.0, 2026-10-08 | Yes | How Red Hat wires an agent to advisory data. Reusable for "is this bumped dependency affected" context. |
| [openshift-eng/ai-helpers](https://github.com/openshift-eng/ai-helpers) `code-review` plugin | Claude Code plugin: pre-commit review, PR review, and a multi-specialist "deep review" that verifies blocking bugs with runtime reproducers and can post a pending review. 120 stars. | Apache-2.0 | Yes, push 2026-10-14 | Yes | Good idea to borrow: a blocking finding must come with a reproducer. |
| [openshift/coderabbit](https://github.com/openshift/coderabbit) | Org-wide CodeRabbit configuration for the `openshift` GitHub org, created February 2026. | Apache-2.0 | Yes | Commercial reviewer | Evidence that Red Hat engineering already runs a commercial AI reviewer at scale. Useful as a comparison population. |
| [Konveyor Kai](https://github.com/konveyor/kai) | Static analysis (analyzer-lsp) finds migration issues, an LLM proposes fixes. CNCF sandbox. 85 stars. | Apache-2.0 | Yes, v0.11.0-beta.1, 2026-09-22 | Yes | "Analysis first, model second" pattern. Generates fixes, so out of scope as a component. |
| [prodsec-skills](https://github.com/RedHatProductSecurity/prodsec-skills), [harness-eval](https://github.com/redhat-community-ai-tools/harness-eval) | Security skills for coding agents; a linter for agent configurations (credential exfiltration chains, hook conflicts). | Apache-2.0 | Yes (2026-07-15, 2026-10-10) | Yes | Harden the reviewer's own agent setup. |
| [Log Detective](https://github.com/fedora-copr/logdetective) | LLM plus Drain template mining explains failed build logs. 44 stars. | Apache-2.0 | Yes, push 2026-10-13 | Yes | Pattern for summarising long tool output before a model sees it. |

### 2.2 Supply chain substrate and deterministic checks

| Project | What it is | Licence | Maintained | AI | Relevance |
|---|---|---|---|---|---|
| [Konflux build-definitions](https://github.com/konflux-ci/build-definitions) | Tekton tasks for Konflux, including `sast-unicode-check` (runs [find-unicode-control](https://github.com/siddhesh/find-unicode-control) with `-p bidi`), `sast-shell-check`, `sast-snyk-check`, `sast-coverity-check`, `clamav-scan`. | Apache-2.0 | Yes, push 2026-10-14 | No | Konflux already runs Trojan Source detection on source. The reviewer should consume these results, not re-run them. |
| [integration-service](https://github.com/konflux-ci/integration-service) | Runs integration pipelines on snapshots and reports to the git provider. | Apache-2.0 | Yes | No | The natural home for the reviewer as a pipeline step, as for the test harness. |
| [Conforma](https://github.com/conforma/cli) | `ec` verifies signatures, SLSA provenance and Rego policy over attestations. | Apache-2.0 | Yes, 2026-10-14 snapshot | No | Where a reviewer attestation ("reviewed, N open findings") can be enforced. The reviewer reports; Conforma gates. |
| [Trustify](https://github.com/guacsec/trustify) | SBOM, VEX and advisory correlation store, now under OpenSSF GUAC. | Apache-2.0 | Yes | No | Source of which components and versions changed, and which advisories apply. |
| [Hermeto](https://github.com/hermetoproject/hermeto) | Prefetches dependencies for hermetic builds and emits SBOMs. | **GPL-3.0** | Yes, 0.63.0, 2026-10-13 | No | Gives the exact old and new dependency sets to diff. Invoke as a tool; do not vendor. |
| [OpenScanHub](https://github.com/openscanhub/openscanhub), [csmock](https://github.com/csutils/csmock), [csdiff](https://github.com/csutils/csdiff) | Red Hat and Fedora static analysis service for RPMs. csdiff computes added and fixed findings between two scans. | GPL-3.0 | Yes (2026-10-01, 2026-10-13, 2026-06-22) | No | **Differential scanning between versions is already solved here for RPMs.** The "new findings only" idea should be reused. Invoke, do not link. |
| [Anitya](https://github.com/fedora-infra/anitya) | Cross-distribution upstream release monitoring. | GPL-2.0 | Yes | No | Feed of "a new upstream version exists" for the dependency-bump source. |
| [Red Hat Trusted Libraries](https://developers.redhat.com/blog/2026/02/27/red-hat-trusted-libraries-trust-and-integrity-your-software-supply-chain) | Tech preview Python index of libraries rebuilt from source in Konflux, with signed attestations and SBOMs. | Product | Live | No | A source-built artifact to compare against the public wheel. Commercial service. |
| GCC `-Wbidi-chars` ([Red Hat article](https://developers.redhat.com/articles/2022/01/12/prevent-trojan-source-attacks-gcc-12)) | Warning added to GCC 12 by Red Hat engineers David Malcolm and Marek Polacek for CVE-2021-42574. | GPL-3.0 | In GCC | No | Shows Trojan Source is handled at compiler level for C and C++. The reviewer still needs a language-neutral check. |

### 2.3 Searched for at Red Hat and not found

- An AI reviewer for the source diff behind a dependency version bump.
- Any Red Hat project that reads OpenVEX or in-toto evidence into a code review.
- An AI review step inside Konflux build-definitions. The SAST tasks are deterministic.
- Accuracy figures for Fullsend's review agent. The site gives one example timing (a PR merged in 5 m 34 s) and no precision or recall.
- Public precision or recall for sast-ai-workflow. It ships a `calculate_metrics` step but publishes no numbers in its README.

---

## 3. IBM and IBM Research

| Item | What it is | Licence | Maintained | AI | Relevance |
|---|---|---|---|---|---|
| [CodeLLM-Devkit (CLDK)](https://github.com/codellm-devkit/python-sdk) | Program analysis SDK producing LLM-ready facts: symbol tables, call graphs, reachability. Backends for Java (WALA, including binaries), Python, TypeScript. 177 stars. | Apache-2.0 (the [TypeScript analyzer](https://github.com/codellm-devkit/codeanalyzer-typescript) shows no licence) | Yes, v1.5.0, 2026-07-27 | Supports LLMs | **Reuse.** Gives the reviewer "who calls the changed code" without asking the model to guess. Check the TypeScript backend's licence before use. |
| [D2A](https://github.com/IBM/D2A) ([paper, ICSE-SEIP 2021](https://arxiv.org/abs/2102.07995)) | Dataset that labels static-analysis findings by running Infer on commit pairs before and after fixes: an issue that disappears after a fix commit is likely real. | Apache-2.0 | **Archived 2022** | Dataset for AI | Validates differential labelling. Historical. |
| [Granite Guardian](https://github.com/ibm-granite/granite-guardian) | Models that detect risks, including jailbreak attempts, in prompts and responses. | Apache-2.0 | Yes, push 2026-10-14 | Yes | Candidate pre-filter for injected instructions in code under review. Not proven on code comments; ALIBI suggests prompt-level filters are weak alone. |
| [Mellea](https://github.com/generative-computing/mellea) | Library for typed generative programs with requirement validation and retry. 1.8k stars. | Apache-2.0 | Yes, push 2026-10-14 | Yes | Option for schema-enforced findings. |
| IBM Bob ([tutorial](https://www.ibm.com/kr-ko/think/tutorials/ai-code-documentation-ibm-bob)) | Commercial agentic IDE that IBM describes as covering code review among SDLC phases. Third-party guides describe a `/review` command (unverified against IBM docs). | Commercial | Live | Yes | Reference point only. |
| [CycloneDX sbom-utility](https://github.com/CycloneDX/sbom-utility) | IBM-donated SBOM validate and query CLI. | Apache-2.0 | Yes | No | SBOM handling for the dependency-bump source. |

**Searched for at IBM and not found:** an open source IBM PR reviewer; an IBM-authored 2025 or 2026 paper on LLM code review or on LLM detection of malicious commits (arXiv and web searches returned none); open components of watsonx Code Assistant review features; official IBM documentation of a Bob review command.

---

## 4. Wider open source

### 4.1 LLM pull-request reviewers

| Project | What it is | Licence | Maintained | AI | Relevance |
|---|---|---|---|---|---|
| [PR-Agent](https://github.com/The-PR-Agent/pr-agent) (was qodo-ai/pr-agent) | `/review`, `/describe`, `/improve`, `/ask` on GitHub, GitLab, Bitbucket, Azure DevOps. 13.4k stars. Now "community-maintained legacy project of Qodo"; Qodo is gold sponsor. | **MIT since 2026-07-09.** Apache-2.0 to 2025-05-22, then AGPL-3.0 until 2026-05-20, then Apache-2.0. | Yes, v0.47.0, 2026-10-02 | Model-agnostic | Most adopted open reviewer and the base of the ICSE-SEIP field study. Usable from v0.40.0 (first MIT release). Avoid v0.30 to v0.35.0 (AGPL). |
| [claude-code-action](https://github.com/anthropics/claude-code-action) | GitHub Action running Claude Code on PRs and issues. 9.5k stars. | MIT | Yes, push 2026-10-14 | Claude | Generic runner. Review behaviour is whatever the prompt says. |
| [claude-code-security-review](https://github.com/anthropics/claude-code-security-review) | Diff-aware security review Action with false-positive filtering. 6.4k stars. README: "not hardened against prompt injection attacks and should only be used to review trusted PRs." | MIT | Slowing, push 2026-02-11 | Claude | Honest statement of the core risk. Unsuitable for untrusted input as shipped. |
| [run-gemini-cli](https://github.com/google-github-actions/run-gemini-cli) | Action invoking Gemini CLI, with PR review workflows. | Apache-2.0 | Yes, push 2026-08-21 | Gemini | Named in the PromptPwnd disclosure; Google patched after report. |
| [codex-action](https://github.com/openai/codex-action) | Action running OpenAI Codex. | Apache-2.0 | Yes | OpenAI | Generic runner. |
| [Kodus](https://github.com/kodustech/kodus-ai) | Self-hosted reviewer that learns team style from past PRs. 1.5k stars. | **AGPL-3.0 plus commercial `ee/`** | Yes | BYO model | Avoid as a dependency. |
| [shippie](https://github.com/mattzcarey/shippie) (was code-review-gpt) | Extendable review and QA agent. 2.5k stars. | MIT | Yes, push 2026-09-28 | Yes | Small, permissive reference. |
| [ChatGPT-CodeReview](https://github.com/anc95/ChatGPT-CodeReview) | Review bot. 4.5k stars. | ISC | Yes, push 2026-08-10 | Yes | Simple prompt-and-comment loop. Little to learn. |
| [presubmit/ai-reviewer](https://github.com/presubmit/ai-reviewer) | Context-aware PR reviewer Action. 188 stars. | MIT | Yes | Yes | Small reference. |
| [villesau/ai-codereviewer](https://github.com/villesau/ai-codereviewer), [codereview.gpt](https://github.com/sturdy-dev/codereview.gpt) | Early GPT reviewers. | MIT | **No, last push August 2024** | Yes | Historical. |
| [coderabbitai/ai-pr-reviewer](https://github.com/coderabbitai/ai-pr-reviewer) | CodeRabbit's former open reviewer. | n/a | **Gone (404)** | Yes | Shows vendors withdraw open versions. |
| [git-ai](https://github.com/git-ai-project/git-ai) | Git extension recording which lines an agent wrote, with model and prompt. 2.8k stars. Implements [Agent Trace](https://agent-trace.dev/), Cursor's draft attribution spec. | Apache-2.0 | Yes, push 2026-10-14 | Records AI | **Input for the AI-authored change source.** Attribution data tells the reviewer which hunks were machine-written. |

### 4.2 Review plumbing

| Project | What it is | Licence | Maintained | AI | Relevance |
|---|---|---|---|---|---|
| [reviewdog](https://github.com/reviewdog/reviewdog) | Turns any linter output (including SARIF and its own rdjson) into PR comments, filtered to the diff. 9.7k stars. | MIT | Yes, v0.21.2, 2026-09-18 | No | **Reuse** to post findings on GitHub, GitLab, Gerrit and Bitbucket, diff-filtered. |
| [Danger](https://github.com/danger/danger), [danger-js](https://github.com/danger/danger-js) | Rules-as-code PR checks ("you forgot the changelog"). | MIT | Yes (2026-10-09, 2026-10-01) | No | Pattern for deterministic, repo-owned review rules. |
| [Zuul](https://opendev.org/zuul/zuul) | Project gating CI from OpenDev, Gerrit-native. | Apache-2.0 | Yes, 14.3.0, 2026-09-28 | No | Gerrit voting model: a bot can vote `Verified` without `Code-Review +2`. Matches "report, never approve." |
| [Gerrit](https://gerrit-review.googlesource.com/) | Code review server. Its own project defines `Bot-Commit`, `SLSA-Policy-Verified` and `Code-Review` as separate labels. | Apache-2.0 | Yes | No | Clean separation of bot evidence from human approval to copy. |
| [Prow](https://github.com/kubernetes-sigs/prow), [Lighthouse](https://github.com/jenkins-x/lighthouse) | ChatOps CI and review bots for GitHub. | Apache-2.0 | Yes | No | Alternative trigger surfaces. |

### 4.3 Static analysis that feeds review

| Project | What it is | Licence | Maintained | AI | Relevance |
|---|---|---|---|---|---|
| [Semgrep CE](https://github.com/semgrep/semgrep) | Pattern-based multi-language analysis. 17k stars. | Engine LGPL-2.1. [Rules](https://github.com/semgrep/semgrep-rules): **Semgrep Rules License v1.0**, internal business use only, no redistribution, no offering as a service. | Yes, v1.180.0, 2026-10-07 | No | Engine usable. Do not bundle or serve the Semgrep-maintained rules. |
| [Opengrep](https://github.com/opengrep/opengrep) | Fork of Semgrep from December 2024, backed by Aikido, Endor Labs, Orca and others. Adds intrafile taint. 3.2k stars. | LGPL-2.1 | Yes, v1.30.2, 2026-10-07 | No | **Preferred engine** where a fully open rule set is needed. |
| [CodeQL](https://github.com/github/codeql) | Query libraries (MIT) and the [CLI](https://github.com/github/codeql-cli-binaries) (v2.27.2). | Libraries MIT. **CLI terms: use only on open source codebases or for academic research**; private code needs GitHub Advanced Security. | Yes | No | Fine for reviewing open source dependencies. Not a default for private first-party code. |
| [gosec](https://github.com/securego/gosec) | Go security checker. 9k stars. | Apache-2.0 | Yes, v2.29.0, 2026-08-26 | No | Reuse. Already in the test harness image. |
| [bandit](https://github.com/PyCQA/bandit) | Python security checker. 8.3k stars. | Apache-2.0 | Yes, 1.9.4 (2026-02-25), push 2026-10-12 | No | Reuse. |
| [ruff](https://github.com/astral-sh/ruff) | Fast Python linter including the flake8-bandit (`S`) rules. 50k stars. | MIT | Yes | No | Reuse as the fast first pass. |
| [eslint-plugin-security](https://github.com/eslint-community/eslint-plugin-security) | Node security rules. 2.4k stars. | Apache-2.0 | Yes, push 2026-10-01 | No | Reuse for JavaScript. |
| [zizmor](https://github.com/zizmorcore/zizmor), [poutine](https://github.com/boostsecurityio/poutine) | Static analysis of CI workflows (injection, excessive permissions). | MIT; Apache-2.0 | Yes | No | Reuse for PRs that touch `.github/workflows` or `.gitlab-ci.yml`, the PromptPwnd surface. |

### 4.4 Secrets

| Project | What it is | Licence | Maintained | AI | Relevance |
|---|---|---|---|---|---|
| [gitleaks](https://github.com/gitleaks/gitleaks) | Regex and entropy secrets scanner. 30k stars. | MIT | Yes, v8.30.1 (2026-03-21), push 2026-09-30 | No | **Reuse.** |
| [betterleaks](https://github.com/betterleaks/betterleaks) | Secrets scanner. 2.2k stars. | MIT | Yes, push 2026-10-14 | No | Alternative to watch. |
| [Kingfisher](https://github.com/mongodb/kingfisher) | Secrets detection with live validation. | Apache-2.0 | Yes | No | Permissive option when validation is wanted. |
| [detect-secrets](https://github.com/Yelp/detect-secrets) | Baseline-driven scanner. | Apache-2.0 | Slowing, push 2026-04-02 | No | Baseline idea is useful for first adoption. |
| [TruffleHog](https://github.com/trufflesecurity/trufflehog) | Scanner with credential verification. 28.5k stars. | **AGPL-3.0** | Yes, v3.99.2 | No | Avoid as a component. |
| [Nosey Parker](https://github.com/praetorian-inc/noseyparker) | Secrets scanner. | Apache-2.0 | **Archived** | No | Avoid. |

### 4.5 Supply-chain and malicious-change review

| Project | What it is | Licence | Maintained | AI | Relevance |
|---|---|---|---|---|---|
| [OSSGadget](https://github.com/microsoft/OSSGadget) | `oss-diff` diffs two package versions by PURL; `oss-detect-backdoor` and `oss-characteristics` flag risky traits. | MIT | Yes, push 2026-07-31 | No | **Reuse `oss-diff`** to get the published package diff for a bump. |
| [malcontent](https://github.com/chainguard-dev/malcontent) | Chainguard. `diff` mode gives risk-weighted capability changes between two versions, from 14,500+ YARA rules. | Apache-2.0 | Yes, v1.27.1, 2026-10-07 | No | **Reuse.** The closest existing "what new capability did this version gain" signal. |
| [OpenSSF Package Analysis](https://github.com/ossf/package-analysis) | Static and sandboxed dynamic analysis of packages, tracking behaviour across versions. | Apache-2.0 | Yes, push 2026-09-25 | No | Behavioural diff pattern and public data. |
| [OpenSSF Malicious Packages](https://github.com/ossf/malicious-packages) | OSV-format database of malicious package reports. | Apache-2.0 | Yes, push 2026-10-14 | No | Cheap first lookup before any model runs. |
| [GuardDog](https://github.com/DataDog/guarddog) | Source and metadata heuristics for PyPI, npm, Go, crates.io, RubyGems, Actions, VS Code extensions. | Apache-2.0 | Yes, v3.2.0, 2026-08-12 | No | Reuse. Best conventional npm detector in the 2026 study (93.32% F1). |
| [Capslock](https://github.com/google/capslock) | Go capability analysis (network, exec, unsafe). | BSD-3-Clause | Yes | No | Capability delta between versions for Go. |
| [Macaron](https://github.com/oracle/macaron) | Oracle Labs. Provenance verification, malicious-package heuristics, repo and commit detection for artifacts, rebuild-and-compare. | UPL-1.0 | Yes, v0.25.0, 2026-07-26 | No | Reuse its source-finder to map an artifact to the exact upstream commit. UPL is permissive. |
| [OSV-Scanner](https://github.com/google/osv-scanner) | Vulnerability scanner over OSV.dev. 11k stars. | Apache-2.0 | Yes, v2.7.0, 2026-10-12 | No | Reuse for "does the new version fix or add advisories." |
| [OpenSSF Scorecard](https://github.com/ossf/scorecard) | Repository security practice scores. | Apache-2.0 | Yes, v5.6.0, 2026-10-12 | No | Context on the upstream's practices, not a verdict. |
| [deps.dev](https://github.com/google/deps.dev) | Google-hosted dependency graph, advisories, Scorecard, attestations. | Apache-2.0 (API docs) | Yes | No | Hosted lookup. Do not make it a hard dependency of an offline gate. |
| [SafeDep vet](https://github.com/safedep/vet), [pmg](https://github.com/safedep/pmg) | Policy-driven dependency checks; package-manager guard. | Apache-2.0 | Yes, vet v1.20.0, 2026-10-07 | No | The malware check calls SafeDep's hosted threat intel. Open client, hosted brain. |
| [npq](https://github.com/lirantal/npq) | Pre-install audit for npm. | Apache-2.0 | Yes | No | Developer-side complement. |
| [packj](https://github.com/ossillate-inc/packj) | Risky attribute audit. | **AGPL-3.0** | Yes | No | Avoid. |

### 4.6 Source-versus-artifact verification

| Project | What it is | Licence | Maintained | AI | Relevance |
|---|---|---|---|---|---|
| [OSS Rebuild](https://github.com/google/oss-rebuild) | Rebuilds popular npm, PyPI and crates.io packages and publishes attestations when they match upstream. | Apache-2.0 | Yes, push 2026-10-14 (no tagged releases) | No | **Reuse its attestations** as evidence that the artifact matches source. Coverage is popular packages only. |
| [diffoscope](https://salsa.debian.org/reproducible-builds/diffoscope) | Deep recursive diff of archives, binaries and packages. | GPL-3.0+ | Yes, 333, 2026-10-09 | No | **Reuse as a tool** to explain tarball-versus-tag differences. Invoke, do not link. |
| [Reproducible Central](https://github.com/jvm-repo-rebuild/reproducible-central) | Rebuild recipes and results for Maven Central artifacts. | **None declared** | Yes | No | Data source for Java. Licence gap: read, do not redistribute. |
| [gitsign](https://github.com/sigstore/gitsign), [cosign](https://github.com/sigstore/cosign), [Rekor](https://github.com/sigstore/rekor) | Keyless commit and artifact signing with a transparency log. | Apache-2.0 | Yes (gitsign v0.17.1) | No | Verify who signed the upstream tag; sign the reviewer's own attestations. |
| [in-toto](https://github.com/in-toto/in-toto), [witness](https://github.com/in-toto/witness), [slsa-verifier](https://github.com/slsa-framework/slsa-verifier), [vexctl](https://github.com/openvex/vexctl) | Attestation framework, provenance verification, OpenVEX tooling. | Apache-2.0 | Yes | No | The evidence formats the reviewer must read and emit. |

The xz backdoor is the design case: the payload never entered git and existed only in the release tarball, chiefly `m4/build-to-host.m4` ([analysis](https://luj.fr/blog/how-nixos-could-have-detected-xz.html)). Autotools tarballs routinely differ from git, which hid it. I found only small scripts for tarball-versus-tag checks, such as attest-sh. No maintained tool explains every difference and flags the unexplained ones.

### 4.7 Trojan Source and licence change

| Project | What it is | Licence | Maintained | AI | Relevance |
|---|---|---|---|---|---|
| [find-unicode-control](https://github.com/siddhesh/find-unicode-control) | Finds bidi and other non-printing Unicode in a source tree. Used by the Konflux `sast-unicode-check` task. | BSD-3-Clause | Quiet, push 2025-09-30 | No | Reuse. Small and stable. |
| [anti-trojan-source](https://github.com/lirantal/anti-trojan-source) | Detects bidi and invisible-character attacks, updated for the 2025 GlassWorm campaign. | Apache-2.0 | Yes, v1.13.0, 2026-09-08 | No | Reuse for JavaScript ecosystems. |
| [trojan-source](https://github.com/nickboucher/trojan-source) | The original paper's proof-of-concept repository. | MIT | **No, last push April 2023** | No | Test fixtures only. |
| [ScanCode toolkit](https://github.com/aboutcode-org/scancode-toolkit), [ScanCode.io](https://github.com/aboutcode-org/scancode.io) | Licence, copyright and package detection. | Code Apache-2.0, data CC-BY-4.0 | Yes, v32.5.0 (2026-01-15), push 2026-10-13 | No | **Reuse** to diff detected licences between old and new versions and in vendored code. |
| [ORT](https://github.com/oss-review-toolkit/ort) | Compliance orchestration over ScanCode and others. | Apache-2.0 | Yes | No | Heavier option for policy evaluation. |
| [FOSSology](https://github.com/fossology/fossology) | Licence compliance server. | GPL-2.0 | Yes | No | Invoke only. |

---

## 5. Commercial reference points

These are reference points, not candidates. Every number below is the vendor's own unless stated.

| Product | What it claims | Authority | Independent evidence |
|---|---|---|---|
| **GitHub Copilot code review** | Agentic architecture GA since 2026-03-05, runs on Actions, can pull wider repo context. Docs say it "is not guaranteed to spot all problems" and to "supplement Copilot's feedback with a human review." Excludes dependency manifests and lockfiles from review. Lite costs about $0.05 to $1, Balanced about $0.25 to $5 per review. | **Can submit an approving review** when Copilot approvals are enabled; default does not count toward required approvals. | Reported to lead GitHub's own ReviewBench at 40.1% grounded F1 (secondary reports; the blog gives no score). ReviewBench's answer key includes tool findings. Reported fourth on Martian's online leaderboard (secondary). |
| **CodeRabbit** | 17K customers, 6M repositories; customer case studies cite 30% to 70% faster merges and about 70% suggestion acceptance. | Comments; merge stays with the forge. | No independent methodology on its site. Appears on Martian's leaderboard. |
| **Graphite Agent** (was Diamond) | Diamond name deprecated 2025-10-08; Graphite acquired by Cursor, announced 2025-12-19. Fullsend's survey repeats Graphite's claims of under 3% unhelpful comments and 55% of flags acted on. | Humans approve; merge queue automates after approval. | Scored 6% catch rate in Greptile's own vendor benchmark, which is not independent either. |
| **Greptile** | Whole-repo graph, multi-hop investigation. Publishes a benchmark: 50 reintroduced bugs, July 2025, Greptile 82%, Bugbot 58%, Copilot 54%, CodeRabbit 44%, Graphite 6%. | Comments. | Vendor-run. False positives not scored. Per-repo Copilot totals sum to 26/50, not the stated 54%. |
| **Sourcery** | Summaries, reviewer's guide, inline comments, a status check that can gate merges. No metrics on its docs page. | Status check can gate. | None. |
| **Amazon CodeGuru Reviewer** | No new repository associations after 2025-11-07 per secondary reports; CodeGuru Security ended 2025-11-20 per AWS docs (that page returned 404 on a re-check the same day, so I have not re-verified it). AWS points to Amazon Q Developer. | n/a | Retired product. A warning about building on a vendor's reviewer. |
| **Gemini Code Assist on GitHub** | Summaries, reviews, `/gemini` Q&A, per-repo style guides. Skips `.github/workflows` to avoid insecure suggestions. Enterprise edition in preview. | Not stated. | None on the docs page. |
| **Claude Code Review** | Research preview for Team and Enterprise. Parallel agents, a verification step against code behaviour, severity tags, "Why this was flagged" per finding. Averages $15 to $25 per review and about 20 minutes. Secondary reports quote Anthropic's internal rise in substantive PR comments from 16% to 54%. | **Never approves or blocks.** Check run always neutral. Fork PRs reviewed only on explicit request. | None published. Appears on Martian's leaderboard. |

### 5.1 What independent measurement exists

- **Martian Code Review Bench** ([repo](https://github.com/withmartian/code-review-benchmark), MIT, 286 stars, push 2026-09-15). Offline: 50 PRs from Sentry, Grafana, Cal.com, Discourse and Keycloak with 173 human-verified golden comments, judged by three LLMs. Online: fresh merged PRs, where a bot comment counts as useful if the developer then changed the code. Martian says tool-to-tool comparison is unreliable because each tool sees different repos. Qodo notes the online set has no full denominator, so true recall is unknown.
- **GitHub ReviewBench** ([blog](https://github.blog/ai-and-ml/github-copilot/reviewbench-an-open-benchmark-for-ai-code-review/), [repo](https://github.com/review-bench/ReviewBench), MIT). 219 PRs, 187 repositories, 19 languages. Answer key built from human reviewers, follow-up commits, deterministic tools and frontier LLMs, graded by Claude Sonnet 5. Senior engineers agreed with its labels 96.6% of the time. GitHub ran the initial entries itself.
- **Academic.** "Bigger Isn't Always Better" ([arXiv 2606.15689](https://arxiv.org/abs/2606.15689)) found the best model scored F1 0.847 on synthetic bugs and 0.066 on real PRs, and F1 fell from 0.657 on diffs under 10 lines to 0.043 over 150 lines. CR-Bench ([arXiv 2603.11078](https://arxiv.org/abs/2603.11078)) found agents that try to find every issue have a low signal-to-noise ratio. CRJudgeBench ([arXiv 2609.37216](https://arxiv.org/html/2609.37216v1)) offers 1,199 instances for telling valid review comments from plausible invalid ones. "Automated Code Review In Practice" ([arXiv 2412.18531](https://arxiv.org/abs/2412.18531), ICSE-SEIP 2025) studied a PR-Agent-based tool on 4,335 PRs: 73.8% of comments resolved, closure time up from 5 h 52 m to 8 h 20 m.
- **Malicious packages.** "How Effective Are NPM Malicious Package Detectors?" ([arXiv 2603.27549](https://arxiv.org/abs/2603.27549)) benchmarked 11 tools on 6,420 malicious and 7,288 benign packages: IntelGuard 95.98% F1, GuardDog 93.32%, best combinations 97.02%.

---

## 6. Gaps the project would fill

1. **Review of the true upstream source diff behind a version bump.** Resolve old and new versions to upstream commits, diff the source, diff the artifact against the source, and explain every difference. Today this is three or four tools and a human.
2. **Backdoor-shaped findings in legitimate projects.** Malicious-package detectors are tuned for typosquats and obvious payloads. Subtle changes to build scripts, test fixtures and binary blobs in a trusted project are not covered.
3. **Evidence-first findings.** Every reviewer posts prose. None emits a finding as a signed statement that cites the diff hunk, the tool output, and the test harness evidence it rests on.
4. **Native reading of OpenVEX, in-toto and UDLM records.** No reviewer consumes "this CVE is not affected because..." or "these tests ran against this version" when judging a change.
5. **A reviewer designed for hostile input.** Every open reviewer I found assumes trusted PRs or leaves injection to the operator. An ingestion gate has to assume the code is adversarial.
6. **A uniform treatment of vendored, forked and generated code.** Tools skip these paths. Claude Code Review's docs suggest skipping vendored code and lockfiles; Copilot excludes manifests. That is exactly where an ingestion gate must look.
7. **Report, never approve, as a published contract.** Only Claude Code Review states it plainly. No open project does.

---

## 7. Implications

### Reuse directly

- **Plumbing:** reviewdog for diff-filtered comments on every forge. Konflux integration-service as the pipeline home. Conforma to enforce, so the reviewer never has to.
- **Deterministic analysis:** Opengrep (with self-written or permissively licensed rules), gosec, bandit, ruff, eslint-plugin-security, zizmor, gitleaks.
- **Dependency bump source:** OSSGadget `oss-diff`, malcontent `diff`, Macaron's source finder, OSV-Scanner, GuardDog, OpenSSF Malicious Packages, Capslock, Scorecard as context.
- **Artifact versus source:** OSS Rebuild attestations, diffoscope as an invoked tool, gitsign and slsa-verifier for signatures and provenance.
- **Unicode and licence:** find-unicode-control (already in Konflux), anti-trojan-source, ScanCode.
- **Context and attribution:** CodeLLM-Devkit for call graphs. git-ai and Agent Trace records for AI-authored hunks. Trustify for advisories.
- **Evidence formats:** in-toto, OpenVEX via vexctl, SARIF.

### Learn from, do not depend on

- **Fullsend:** schema-validated findings, read-only review sandbox, credential isolation, PR risk scoring. Reject its merge authority.
- **Claude Code Review:** neutral check run, per-finding "why flagged," explicit verification step, `REVIEW.md` evidence bars such as "behaviour claims need a file:line citation."
- **sast-ai-workflow:** confidence computed from investigation depth and evidence, not self-report alone.
- **ai-helpers deep review:** blocking bugs need a runtime reproducer.
- **csdiff and OpenScanHub:** report only findings new in this version.
- **Gerrit and Zuul:** bot labels separate from `Code-Review +2`.
- **PR-Agent:** command model and forge abstraction. Reusable code from v0.40.0, but I would learn from it rather than fork a project whose licence has changed three times in 14 months.

### Benchmark against

- **Martian Code Review Bench** (offline set) and **ReviewBench** for first-party PRs. Report both, and report the judge.
- **The npm detector benchmark** from arXiv 2603.27549 for the malicious-change path. GuardDog's 93.32% F1 is the floor to beat on known patterns.
- **ALIBI-style adversarial comments** as a red-team suite: the reviewer must not change its verdict when a hostile comment is added.
- **Historical backdoors** (xz 5.6.0 and 5.6.1 tarballs against their git tags) as must-catch cases.

### Avoid

- **AGPL:** Kodus, TruffleHog, packj, PR-Agent v0.30 to v0.35.0.
- **Restrictive terms:** Semgrep-maintained rules (no redistribution or service use), CodeQL CLI on private code without a licence.
- **No licence:** Reproducible Central (data only), CLDK's TypeScript analyzer until a licence appears.
- **Unmaintained or gone:** villesau/ai-codereviewer, codereview.gpt, coderabbitai/ai-pr-reviewer, Nosey Parker, D2A, trojan-source.
- **Untrusted-input runners as shipped:** claude-code-security-review and similar Actions, by their own warning.
- **Vendor lock on the verdict:** CodeGuru Reviewer's retirement is the cautionary example.

### Licensing note

Everything in "reuse directly" is Apache-2.0, MIT, BSD-3-Clause, UPL-1.0 or LGPL-2.1 (Opengrep, used as a separate program). Hermeto, OpenScanHub, csmock, csdiff and diffoscope are GPL-3.0 and FOSSology is GPL-2.0: invoke them as separate tools, never vendor or link them. ScanCode's licence data is CC-BY-4.0 and needs attribution if redistributed. I excluded every AGPL and every unlicensed component from reuse.

---

## 8. Sources

All fetched 2026-10-14. Repository facts (stars, licence, last push, latest release, LICENSE history) came from the GitHub REST API for each repository linked in sections 2 to 4, and from the opendev.org and salsa.debian.org APIs for Zuul and diffoscope.

**Red Hat**
- https://github.com/fullsend-ai/fullsend (README, MAINTAINERS.md, docs/agents/review.md, docs/ADRs/0089-pr-risk-assessment-scoring.md, docs/landscape.md)
- https://fullsend.sh
- https://github.com/RHEcosystemAppEng/sast-ai-workflow
- https://github.com/RedHatProductSecurity/aegis-ai
- https://github.com/openshift-eng/ai-helpers/tree/main/plugins/code-review
- https://github.com/openshift/coderabbit
- https://github.com/konflux-ci/build-definitions (archived-tasks/sast-unicode-check)
- https://github.com/openscanhub/openscanhub, https://github.com/csutils/csdiff, https://github.com/csutils/csmock
- https://developers.redhat.com/blog/2026/02/27/red-hat-trusted-libraries-trust-and-integrity-your-software-supply-chain
- https://developers.redhat.com/articles/2022/01/12/prevent-trojan-source-attacks-gcc-12

**IBM**
- https://github.com/codellm-devkit/python-sdk, https://github.com/codellm-devkit/codeanalyzer-typescript
- https://github.com/IBM/D2A
- https://github.com/ibm-granite/granite-guardian, https://github.com/generative-computing/mellea
- https://www.ibm.com/kr-ko/think/tutorials/ai-code-documentation-ibm-bob

**Open source** (repositories as linked in the tables), plus:
- https://github.com/The-PR-Agent/pr-agent/commits/main/LICENSE (licence history)
- https://github.com/kodustech/kodus-ai/blob/main/license.md
- https://semgrep.dev/legal/rules-license
- https://github.com/github/codeql-cli-binaries/blob/main/LICENSE.md
- https://github.com/opengrep/opengrep
- https://agent-trace.dev/ and https://www.thoughtworks.com/radar/platforms/agent-trace (Agent Trace, secondary)
- https://luj.fr/blog/how-nixos-could-have-detected-xz.html (xz payload location)

**Commercial**
- https://docs.github.com/en/copilot/concepts/agents/code-review
- https://github.blog/changelog/2026-03-05-copilot-code-review-now-runs-on-an-agentic-architecture/
- https://www.coderabbit.ai/
- https://www.greptile.com/benchmarks
- https://graphite.com/blog/introducing-graphite-agent-and-pricing; https://siliconangle.com/2025/12/19/cursor-acquires-ai-code-review-startup-graphite/ (secondary)
- https://docs.sourcery.ai/Code-Review/Overview/
- https://docs.aws.amazon.com/codeguru/latest/security-ug/end-of-support.html; Reviewer status from https://issoh.co.jp/tech/details/2869 (secondary)
- https://docs.cloud.google.com/gemini/docs/code-review/review-repo-code
- https://code.claude.com/docs/en/code-review; internal 16% to 54% figure from https://infoq.com/news/2026/04/claude-code-review (secondary)

**Benchmarks and research**
- https://github.com/withmartian/code-review-benchmark
- https://github.blog/ai-and-ml/github-copilot/reviewbench-an-open-benchmark-for-ai-code-review/; https://github.com/review-bench/ReviewBench
- ReviewBench Copilot 40.1% and answer-key share: https://www.devx.com/coding/what-is-reviewbench-ai-code-review-benchmark/ and https://runtimewire.com/article/github-launches-reviewbench-an-open-benchmark-for-ai-code-re-4528d7 (secondary, unverified against the leaderboard, which did not render)
- Martian online ranking of Copilot: https://thenewstack.io/github-reviewbench-code-review/ (secondary)
- https://arxiv.org/abs/2606.15689 (Bigger Isn't Always Better)
- https://arxiv.org/abs/2603.11078 (CR-Bench)
- https://arxiv.org/html/2609.37216v1 (CRJudgeBench)
- https://arxiv.org/abs/2412.18531 (Automated Code Review In Practice)
- https://arxiv.org/abs/2603.27549 (npm malicious package detectors)
- https://arxiv.org/abs/2607.24964 (ALIBI)
- https://arxiv.org/abs/2102.07995 (D2A)

**Prompt injection in review agents**
- https://github.com/anthropics/claude-code-security-review (README security note)
- https://csoonline.com/article/4101751/ai-in-ci-cd-pipelines-can-be-tricked-into-behaving-badly-2.html (PromptPwnd, secondary)
- https://labs.cloudsecurityalliance.org/research/csa-research-note-ai-github-actions-security-20260503-csa-st/
- https://theregister.com/2025/10/09/github_copilot_chat_vulnerability/ (CamoLeak)
