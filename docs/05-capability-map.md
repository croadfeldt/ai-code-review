# Capability map: what fills each capability

**For:** engineers and architects choosing components. Companion to the [landscape](04-landscape.md),
which is the full inventory. This page is the decision: for every capability the reviewer needs, a
primary choice, a fallback, and the reason. Research date 2026-10-14. Products named here are the
example; any component that does the same job fits.

## Two facts that shape the choices

1. **The deterministic layer exists and is permissively licensed.** Almost every stage 2 check is an
   existing, maintained tool under Apache-2.0, MIT, BSD or LGPL. What is built here is the assembly,
   the artifact-against-source explanation, the quarantined review and the evidence (D12).
2. **There is no code-review predicate and no open reviewer worth building on.** in-toto has no
   predicate for code review, so this project defines one. PR-Agent's licence changed three times in
   fourteen months and Kodus is AGPL, so I learn from them and take no code (D23 applies the same rule to
   Fullsend).

## The decision table

| Capability | Primary | Fallback | Why |
|---|---|---|---|
| Pipeline engine | **The team's own.** Tekton on Konflux in the example; GitHub Actions and GitLab CI triggers shipped | Any engine that runs a container step | The reviewer is one more step beside the harness, not a platform |
| Forge identity | **One GitHub App per organization**, comment and check-run permissions only, shared with the harness (D16) | GitLab: a project bot user, with approvals blocked by rule. Gerrit: a bot account with no Code-Review +2 | Check runs need an App on GitHub; a required check can be pinned to it |
| Forge fan-out | **reviewdog** reading the reviewer's SARIF, after the posting step has stripped outside links and images | The reviewer's own posting step for each forge | One input, every forge; diff filtering built in |
| Model serving | **Any OpenAI-compatible endpoint.** vLLM in the example, open models first | A hosted model behind the same interface | The model is chosen by measurement on the reference jobs, never by size (principle 12) |
| Model step isolation | **A sandboxed container** (Kata or gVisor in the example) with egress to the model endpoint only, no forge token, no signing key | A plain container with a deny-all network policy plus the endpoint | The reviewer cannot act (D7); the cheap way to be safe is to have nothing worth stealing |
| SAST on changed lines | **Opengrep** with self-written rules; **bandit** and **ruff** for Python; **gosec** for Go; **eslint-plugin-security** for npm | CodeQL, for open source code only | Permissive and maintained; Semgrep-maintained rules forbid service use; CodeQL CLI is limited to open source |
| Secrets | **gitleaks** | None chosen | TruffleHog is AGPL; Nosey Parker is gone |
| Invisible and bidi Unicode | **find-unicode-control**, plus a byte-range scan for variation selectors and tag characters (U+E0000 block) | anti-trojan-source | Already in Konflux; common tools miss variation selectors, and a byte scan is simple |
| Licence change | **ScanCode** | FOSSology, invoked as a separate tool (GPL-2.0) | Mature; licence data needs attribution if redistributed |
| CI and workflow wiring | **zizmor** for GitHub Actions; the harness's CI reader (rules P-01 to P-08) for GitLab CI and Tekton | Own rules only | Mutable action references, `pull_request_target`, agents with tools on outside text |
| Known malicious patterns | **GuardDog**, and **OSV-Scanner** with the OpenSSF Malicious Packages feed | malcontent | GuardDog had the best conventional F1, 93.32%, in the 2026 npm study |
| What changed in the installed package | **OSSGadget** `oss-diff` and **malcontent** `diff`; **Capslock** for Go capabilities | The ecosystem's own diff (`npm diff`) | Diffs what will be installed, including capability changes |
| Artifact against source | **Macaron**'s source finder to locate the tag, then the reviewer's own explanation step, with **diffoscope** invoked for archives; **OSS Rebuild** attestations as evidence | Manual tag resolution from package metadata | Nothing assembles this today (landscape, headline 1); diffoscope is GPL-3.0, so invoked, never linked |
| Provenance and signatures | **Sigstore** clients: `npm audit signatures`, PEP 740 attestations for PyPI, the Go checksum database plus tag ancestry | in-toto verification of SLSA provenance | Lost provenance is a finding in its own right (the axios case) |
| Package existence and age | **The registries' own metadata APIs** | deps.dev | Hallucinated and days-old names are a deterministic flag |
| Code context | **CodeLLM-Devkit** for call graphs (Python, Java) and the ecosystem's own tools for Go | The diff with surrounding lines only | Reachability for the model's context, not for its verdict |
| AI attribution | **Agent Trace and git-ai records** where present | Commit trailers such as `Co-Authored-By` | Weights the intent check for agent-written changes; absence is not a finding |
| Findings format | **SARIF 2.1.0**, with GitLab Code Quality and SAST reports generated from the same findings | None needed | Every forge reads it; fingerprints and `baselineState` give dedup and "new only" |
| Signed statement | **in-toto Statement v1** with the [`ai-code-review` predicate](../blueprint/predicate.md), signed with Sigstore in the pipeline's signing step | A DSSE envelope with a local key, as the harness does in development | Signing keys never reach the model step |
| Harness evidence | **OpenVEX** read with the go-vex library or its schema; **in-toto** test-result statements; **UDLM** records, all read natively (D11) | None: if evidence is missing, the report says so | The [evidence input contract](../blueprint/evidence-input.md) |
| Gate policy | **Conforma** (`ec validate input` before merge, `ec validate image` at release), with the [reference Rego](../blueprint/gate-policy.rego) | OPA running the same Rego; a GitHub required check pinned to the App | The same policy before merge and before release |
| Evaluation | **The reviewer's own evaluator** over the two-sided reference jobs | Martian Code Review Bench and ReviewBench, reported as context with their judge named (D20) | Public benchmarks use an LLM judge; the reference jobs are the measure |
| Shared machinery | **Copied from the harness** (D17): LLM client, prompt sets, self-check and register, run index, story, attestation, UDLM records, deploy templates, site | A shared library, once both projects use a piece unchanged | Copy first, extract later |

## Learn from, do not depend on

| Project | What I take | What I reject |
|---|---|---|
| Fullsend | Schema-validated findings, a read-only review sandbox, credential isolation, risk scoring | Agents that merge and close pull requests |
| Claude Code Review | A check run that always concludes neutral, a "why flagged" per finding, evidence bars such as "behaviour claims need a file:line citation" | Nothing; it is a reference point, not a component |
| sast-ai-workflow | Confidence from the depth of the investigation and its evidence, not the model's self-report | |
| csdiff and OpenScanHub | Report only what is new in this version | |
| Gerrit and Zuul | Bot labels kept apart from Code-Review +2 | |
| PR-Agent | The command model and the forge abstraction | Its code: the licence has changed three times in fourteen months |

## Avoided

AGPL components (Kodus, TruffleHog, packj, PR-Agent v0.30 to v0.35.0), Semgrep-maintained rules, the
CodeQL CLI on private code, and any action that warns it is not hardened against prompt injection.
Reasons and sources are in the [landscape](04-landscape.md).
