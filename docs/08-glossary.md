# Glossary

**For:** anyone. Plain-language definitions of the terms used in this project.

| Term | What it means here |
|---|---|
| **Acted on** | The code at a finding's location changed before merge, or the finding was answered with a reason. The reviewer's main measure of usefulness. |
| **Artifact** | The file that actually gets installed: a wheel, an npm tarball, a Go module zip, a release tarball. It can differ from the source it claims to come from. |
| **Artifact against source** | Comparing an artifact with the source at the tag it claims, and explaining every difference. The check that would have caught the XZ Utils backdoor. |
| **Attestation** | A signed, machine-readable statement that something happened, for example "this revision was reviewed and these were the findings". |
| **Blind pass** | The second review of a change, with its description, commit messages and code comments removed, so that wording written by an attacker cannot steer the verdict. |
| **Checked list** | The part of every report that says what the reviewer checked and what it did not. It replaces any "pass" or "safe" wording. |
| **Code analysis** | Tools looking for problems in code. NIST's term for what this reviewer does, as distinct from code review by a person. |
| **Code review** | A person reading a change before it is merged. The reviewer informs code review; it is never part of it. |
| **Conforma** | A policy engine that checks signed attestations against rules before something is merged or released. Used here as the example; OPA does the same job. |
| **CWE** | Common Weakness Enumeration: the catalogue of kinds of software weakness, for example CWE-79, cross-site scripting. |
| **Defanged** | A reconstruction of a malicious change with its harmful payload replaced by a harmless marker, keeping the shape the checks look for. |
| **Deterministic gate** | The stage of checks that use tools, not a model, and whose findings the model cannot clear. |
| **Drift** | A gap between what a change says it does and what its diff does. |
| **Effective false positive** | A finding the developer did not act on, whatever its technical merit. Google's measure of noise, and the one used here. |
| **Grounding** | Checking each model finding against the code and the tools. A finding that cannot be grounded is dropped. |
| **Ingestion gate** | The reviewer applied to code we did not write, before it enters: dependency bumps, vendored and generated code. |
| **in-toto** | An open standard for the format of attestations. |
| **Install script** | Code a package runs when it is installed, such as npm's `postinstall`. Many real attacks used one. |
| **Noise budget** | The share of a finding category's findings that may go unacted on before the category is switched off. Under 10% by default. |
| **OpenVEX** | A format for saying whether a product is affected by a known vulnerability, and why. The test harness drafts these; the reviewer reads them. |
| **Prompt injection** | Text written to make an AI system follow the attacker's instructions instead of its own. In a pull request it can hide in a description, a comment or a file. |
| **Provenance** | The recorded history of an artifact: what it was built from, by what process, by whom. |
| **Quarantined review** | The model step, run with no tools, network, write token or secret, reading untrusted text marked as data. |
| **Reference job** | A test case for the reviewer: a defanged malicious change paired with a similar clean one. The reviewer passes only if it flags the first and not the second. |
| **SARIF** | A standard format for the results of code analysis tools, read by GitHub, GitLab and many others. |
| **SLSA** | A framework of supply chain security levels. Its source track's top level requires two-party review by people. |
| **Spotlight** | A short pointer for the human reviewer to the riskiest parts of a change, instead of a list of AI comments to confirm. |
| **Test harness** | The sibling project, the [AI Test Harness](https://github.com/croadfeldt/ai-test-harness), which writes and runs tests for every change. Its evidence is one of the reviewer's inputs. |
| **Trojan Source** | Hiding code from human readers with invisible or direction-changing Unicode characters, so the code does something different from what it appears to do. |
| **Two-sided** | A measure that checks both that the bad thing is flagged and that the similar good thing is not. |
| **UDLM** | The data model the harness and this reviewer use for their records, so evidence from both can be joined. |
