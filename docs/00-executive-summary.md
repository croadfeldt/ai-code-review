# Executive summary

**For:** executives, board members, managing directors, and anyone who needs the point in five minutes.

## The problem in one sentence

We review the code our engineers write, we trust the code we import, and more and more of what we merge
is written by agents or by strangers upstream.

## What I am proposing

**AI Code Review**: a reviewer that reads every change before a person does. It covers our own pull
requests, changes written by AI coding agents, and the package behind every dependency update. It hands
the person who approves the change grounded findings and a signed record of what was checked and what
was not. It never approves anything itself. A person decides every merge.

## Why now

1. **Review is not catching what now comes in.** Only about one review comment in seven is about a defect.
   About half of dependency updates in the most popular package registries are never code reviewed.
   Teams using AI heavily merge almost twice as many changes while review time per change nearly doubles.
2. **The worst attacks are not in the code a reviewer reads.** In 12 of 21 real malicious changes I
   studied, the harmful part lived in the released package, in a moved version tag or in build
   configuration. The 2024 XZ Utils backdoor was triggered from a file that existed only in the release
   download.
3. **AI reviewers are being bought to fill the gap, and the evidence on them is mixed.** Well-tuned ones
   get about 40% of their comments acted on, close to the human rate. Untuned ones manage 1 to 19%. A
   carefully worded change description can talk them out of seeing a known vulnerability. People shown an
   AI review look where it points and find no more serious problems.

## What makes this different

- **It never approves.** The supply-chain standards I checked count only people as reviewers, and
  OpenSSF says plainly that AI reviews do not count. This one informs the human; it does not replace them.
- **It looks at what will actually be installed,** not only at the code change, and compares it with the
  source it claims to come from.
- **It assumes the change is hostile.** The AI part has no tools, no network and no secrets, so a
  malicious change cannot make it do anything. It reads every change twice, once without the author's
  description, and a different answer is itself a warning.
- **It shows nothing it cannot prove.** Every finding points at the exact line and the evidence. Any kind
  of finding developers mostly ignore is switched off.
- **It never says "safe".** It says what it checked and what it did not.
- **It leaves a signed record** of the diligence done on every change and every component version.
  Supply-chain rules such as the EU Cyber Resilience Act increasingly expect that record.

## What it costs and what it returns

Published figures from companies running AI review put the computing cost per change well under a dollar.
The real cost is people's attention, which is why noise is budgeted. I will measure my own cost and
effect, starting with a baseline before anything is built. The pilot promises to do no harm first: no
slower changes, no worse human reviews. It claims gains only when they are measured.

## What I need

A sponsor, two to four engineers, and a team willing to pilot it. The first three weeks build a test set
of reconstructed historical attacks, each paired with a harmless look-alike, and measure where an AI
reviewer starts from. The plan is in the [business case](01-the-case.md); the design is in the
[blueprint](03-blueprint.md).
