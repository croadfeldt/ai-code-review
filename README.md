# AI Code Review

**A blueprint for using AI to inform the people who review code, and to gate code we did not write
before it enters, without ever approving a change itself.**

Author: Chris Roadfeldt. Status: blueprint draft v0.1, October 2026.

Every change that reaches a product passes a human reviewer, or is meant to. Our own pull requests get
read. A version bump of a package five layers deep usually does not: a [2022 study](https://arxiv.org/abs/2206.09422) found only about half of
dependency updates in the top packages of four registries were code reviewed at all. Agents now write a
growing share of changes. AI reviewers are being sold to fill the gap, and the measured results are mixed.
Tuned ones get their comments acted on at close to the human rate. Untuned ones are mostly noise, they
narrow where human reviewers look, and a crafted pull request description can talk them out of seeing a
known vulnerability.

This project is a plan for a reviewer built on what the evidence says works. It treats every input as
hostile. It runs the deterministic checks first and lets the model add findings, never clear them. It
reviews the artifact that will be installed, not only the git diff. It shows a finding only with its
evidence. It never says a change is safe, and it never approves. A person owns every merge.

It is a sibling to the [AI Test Harness](https://github.com/croadfeldt/ai-test-harness). The harness
proves what a change does with tests. This project asks whether the change does what it says, is safe to
admit, fits the code base, and is proven, and it reads the harness's evidence (OpenVEX, in-toto
statements, UDLM records) as an input.

## Start here

| If you are | Read |
|---|---|
| An executive, or anyone who wants the point in five minutes | [Executive summary](docs/00-executive-summary.md) |
| Deciding whether to fund it | [Executive summary](docs/00-executive-summary.md), then [The case](docs/01-the-case.md) |
| An engineer or architect who will build or run it | [Blueprint](docs/03-blueprint.md), then [Decision record](docs/21-decision-record.md) and [Target goals](docs/target-goals.md) |
| Judging whether it would work | [Target goals](docs/target-goals.md) |
| Looking for what already exists | [Landscape](docs/04-landscape.md) |
| Checking a claim | The four research notes under [docs/research/](docs/research/), each with its sources |

## What is in this repository

```
AGENTS.md                         For an AI assistant or coding agent pointed at this repository
docs/
  00-executive-summary.md         The point, in one page
  01-the-case.md                  The business case
  03-blueprint.md                 The blueprint in three pages
  04-landscape.md                 Existing work: reuse, learn from, benchmark against, avoid
  research/
    README.md                     What the research settled, and what it changes in the plan
    efficacy.md                   Measured evidence on human review and AI review
    practice-and-standards.md     Review practice; SLSA, NIST SSDF, Scorecard, CRA; SARIF and the forges
    threats-and-ingestion.md      Attacks on AI reviewers; how 21 real malicious changes got in
  target-goals.md                 The goals a run and a pilot are judged against
  open-questions.md               What was open before the blueprint, and where each ruling went
  08-glossary.md                  Plain-language definitions
  21-decision-record.md           The positions settled, each with its reason and what it rules out
```

Document numbers follow the harness wherever a document has a counterpart there, so a reader of one can
find their way in the other.

## What comes next

1. The rest of the blueprint: how it works, the capability map, the specification, the failure register
   and the contracts (finding schema, the `ai-code-review` predicate, the evidence input contract).
2. The two-sided reference corpus and a measured baseline (decisions D19 and D21).
3. An opinionated implementation, then examples that are all tool output, on the same target repositories
   the harness uses, plus a two-sided reference corpus of defanged historical malicious changes.

## How this is written

Quality of results first, then readable by a person. Plain English, concise, every claim with its source.
See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

Apache-2.0. See [LICENSE](LICENSE).
