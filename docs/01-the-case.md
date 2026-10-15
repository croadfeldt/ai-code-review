# AI Code Review Business Case

## Blueprint Identity

**Owner:** Chris Roadfeldt

**Elevator pitch:** How does a reviewer know a change is safe to admit when much of it was written by an
agent or by a stranger upstream, and the real payload may not even be in the diff? AI Code Review reads
every change before a person does. That covers our own pull requests, agent-written code, and the package
behind every dependency bump. It hands the reviewer grounded findings and a signed record of what was
checked and what was not. It never approves. The person at the gate decides with evidence, and the code
we did not write gets reviewed at all.

## Problem Statement

**Customer name:** Any organization that ships software built on code it did not write, and that now
accepts changes written by AI agents: product teams, platform teams, and the security and compliance
functions that answer for what they ship. The first pilot runs on two example projects, one Python and
one Go, plus a corpus of reconstructed historical attacks; the first customer team is to be named with
the sponsor.

**Customer stakeholder:** Whoever answers for what gets merged: the head of engineering, the product
security lead, the platform owner. The pilot serves the person who approves the merge. Their measures
come first: what the reviewer caught, how much of their time it cost, and whether it made their own
review better or worse.

**Customer pain:** Human review is not built to catch what now comes in.

- Only 5 to 20% of human review comments are about defects, a range that has held from Microsoft in 2013
  to OpenDev in 2024 and Atlassian in 2025 (Bacchelli and Bird; Turzo and Bosu; Goldman et al.).
- Dependency updates are worse: in the top packages of four registries only about half of updates were
  code reviewed at all (Imtiaz and Williams, 2022).
- Teams with high AI adoption merge 98% more pull requests while review time per request rises 91%
  (Faros AI, 2025).
- The attacks that matter often never reach the diff a reviewer reads. In 12 of 21 real malicious changes
  studied, the payload lived in the release artifact, a moved tag or CI configuration. The XZ Utils
  backdoor's trigger existed only in the release tarball.

**Current workaround:** Teams rely on human review for their own code and on trust for everything else.
AI reviewers comment on pull requests. Tuned in-house ones at Atlassian and Google get about 40% of their
comments acted on, close to the human rate; untuned ones in open source manage 1 to 19%. None reviews the
package behind a dependency bump against its source. The one vendor action that states its position on
prompt injection says it is not hardened against it. One commercial reviewer now offers to approve pull
requests itself. Malicious-package scanners catch known patterns but not a
backdoor in a trusted project.

**Impact of inaction:** Agent-written and third-party changes keep growing faster than review capacity. A
compromised release enters through the artifact while the diff looks clean. AI reviewers bought to fill
the gap add noise and anchor human reviewers, who look where the tool points and find no more serious
issues (Tufano et al., ICSE 2025). And when an auditor or a regulator asks what diligence was done on a
third-party component, there is no record to show.

**Impact of action:**

- Every change reaches its reviewer with findings that carry their evidence, the list of what was checked
  and what was not, and a signed record.
- Every dependency bump is checked at the installed artifact, against its source and its previous
  version, so an XZ-style or axios-style compromise is a finding before it is installed.
- Agent-written changes are checked against what they claim to do.
- The noise budget keeps only the categories developers act on.
- The record gives SSDF PW.7 and CRA Article 13(5) due-diligence evidence per change and per component
  version, without claiming to replace human review.

## Proposed solution

**Landing BUs:** The supply chain security, build platform and developer tooling teams. To be confirmed
with the sponsor.

**Aligned TDPs:** To be named with the sponsor; the natural fits are the supply chain security and trusted
AI plans.

**Considered alternatives:**

- **Commercial reviewers** (Copilot code review, CodeRabbit, Graphite, Greptile, Claude Code Review) have
  converged on one design for first-party pull requests. None reviews the artifact behind a bump, reads
  VEX or attestations, or emits signed evidence. Some can now approve. One retired product (CodeGuru
  Reviewer) shows the risk of resting a verdict on a vendor.
- **Open reviewers** are thin: PR-Agent's licence changed three times in fourteen months, and Kodus is AGPL.
- **Red Hat-adjacent Fullsend** is the closest relative but merges autonomously.

The components underneath are open and maintained. What does not exist is the assembly. Survey in the
[landscape](04-landscape.md).

**Solution overview:** A change arrives.

1. The reviewer gathers the diff and its context. For a dependency bump it also gathers the installed
   package at both versions and the source it claims to come from.
2. Deterministic checks run first: invisible Unicode, secrets, licence changes, new install scripts,
   dependencies never imported, mutable action references, lost provenance, and the artifact against its
   source. Their findings stand whatever the model says.
3. A model with no tools, network or secrets reads the change as marked data and answers four questions:
   does it do what it says, is it safe to admit, does it fit, is it proven by the test harness's evidence.
   It does so twice, the second time blind to the description and comments. A different verdict is itself
   a finding.
4. Every model finding is checked against the code and the tools, and anything it cannot ground is
   dropped.
5. The author sees the findings first. The reviewer gets a short spotlight and the checked list. The gate
   gets a signed record.

It runs wherever the team's pipeline runs. The design is the [blueprint](03-blueprint.md); the positions
settled are the [decision record](21-decision-record.md).

**Cost and noise.** I have not measured the reviewer yet. A baseline run comes before the implementation
(decision D21), and every run will record its tokens and CPU-minutes. For scale, published figures from
others are small next to people's time: about 3,900 tokens and $0.48 per pull request at Beko (ICSE-SEIP
2025), 8,000 to 52,000 tokens per review at Meta, and a median of 4 minutes per commit at Uber. The real
cost is a developer's attention on a comment not worth acting on. So each category of finding must keep
under 10% left unacted on, Google's rule for review-time checks, or it is switched off.

**Timeline & Milestones:**

1. **Baseline and corpus, weeks 1 to 3.** The two-sided reference corpus of defanged historical attacks;
   an unfiltered open model measured against it.
2. **Pilot, weeks 4 to 9.** Two example projects; first-party and agent-written pull requests; the
   deterministic gate on every dependency bump; findings to authors only.
3. **Ingestion gate, weeks 10 to 16.** Artifact against source for Python, Go and npm; the signed
   statement read by the release gate; the harness's evidence read natively.
4. **Reviewer-facing, weeks 17 to 22.** The spotlight for human reviewers; noise budgets enforced per
   category from measured action.
5. **Continuous operation, week 23 on.** Vendored and generated code; remaining ecosystems; the agent
   test-weakening study; upstream contributions.

Durations assume two to four engineers and are replaced by measured velocity after the pilot.

**Definition of Done:** A product team can point the reviewer at a repository and receive, without the
project team involved:

- grounded findings on every pull request, with the list of what was checked and what was not;
- a signed record that its release gate verifies;
- every dependency bump checked at the installed artifact against its source.

The seven guarantees in the [target goals](target-goals.md) hold on every run. The reference jobs pass
both ways on each release, with no measure worse than the last. The pilot shows no increase in cycle time
or reviewer time, and no fall in what human reviewers find. It runs where the customer runs, through the
shipped triggers.

## References

- Bacchelli and Bird, [Expectations, outcomes, and challenges of modern code review](https://sback.it/publications/icse2013.pdf), ICSE 2013.
- Turzo and Bosu, [What makes a code review useful to OpenDev developers?](https://arxiv.org/abs/2302.11686), EMSE 2024.
- Goldman et al., [What types of code review comments do developers most frequently resolve?](https://arxiv.org/abs/2510.05450), Atlassian preprint, 2025.
- Imtiaz and Williams, [Are your dependencies code reviewed?](https://arxiv.org/abs/2206.09422), 2022.
- Faros AI, [The AI Productivity Paradox](https://www.faros.ai/blog/ai-software-engineering), 2025.
- Atlassian, [RovoDev Code Reviewer](https://arxiv.org/html/2601.01129v1), ICSE-SEIP 2026.
- Tufano et al., [Deep learning-based code reviews](https://arxiv.org/pdf/2411.11401), ICSE 2025.
- Sadowski et al., [Lessons from building static analysis tools at Google](https://6826.csail.mit.edu/2020/papers/google-analysis-cacm.pdf), CACM 2018.
- NIST, [CVE-2024-3094](https://nvd.nist.gov/vuln/detail/CVE-2024-3094): the XZ Utils backdoor.
- In this repository: the [blueprint](03-blueprint.md), the [decision record](21-decision-record.md), the
  [target goals](target-goals.md), and the [research](research/README.md) with every source.
