# Tests for the reference gate policy. Run: opa test blueprint/

package ai_code_review.gate_test

import rego.v1

import data.ai_code_review.gate

head := "1111111111111111111111111111111111111111"

statement(findings) := {
	"_type": "https://in-toto.io/Statement/v1",
	"subject": [{"name": "https://github.com/example/service", "digest": {"gitCommit": head}}],
	"predicateType": gate.review_type,
	"predicate": {
		"review_kind": "automated-analysis",
		"selfcheck": {"passed": true, "register": []},
		"findings": findings,
		"not_checked": [],
	},
}

finding(rule, blocking) := {
	"rule_id": rule, "blocking": blocking,
	"location": {"path": "src/a.py", "start_line": 3},
}

run(findings, settings) := {
	"head_commit": head,
	"attestations": [{"verified": true, "statement": statement(findings)}],
	"settings": settings,
}

test_no_findings_holds_nothing if {
	count(gate.deny) == 0 with input as run([], {})
}

test_blocking_gate_finding_holds if {
	some msg in gate.deny with input as run([finding("gate.install-script.added", true)], {})
	contains(msg, "gate.install-script.added")
}

test_advisory_gate_finding_only_warns if {
	count(gate.deny) == 0 with input as run([finding("gate.licence.changed", false)], {})
	count(gate.warn) == 1 with input as run([finding("gate.licence.changed", false)], {})
}

test_model_finding_never_holds_alone if {
	# Even marked blocking by a misconfigured triage, a model rule holds only if the team raised it.
	count(gate.deny) == 0 with input as run([finding("model.defect.logic", true)], {})
}

test_raised_model_rule_holds if {
	inp := run([finding("model.security.removed-check", false)], {"raised_model_rules": ["model.security.removed-check"]})
	count(gate.deny) == 1 with input as inp
}

test_statement_for_other_commit_is_ignored if {
	inp := object.union(run([], {}), {"head_commit": "2222222222222222222222222222222222222222"})
	some msg in gate.deny with input as inp
	startswith(msg, "no verified ai-code-review statement")
}

test_unverified_statement_is_ignored if {
	inp := {"head_commit": head, "attestations": [{"verified": false, "statement": statement([])}]}
	some msg in gate.deny with input as inp
	startswith(msg, "no verified ai-code-review statement")
}

test_failed_selfcheck_holds if {
	s := json.patch(statement([]), [{"op": "replace", "path": "/predicate/selfcheck/passed", "value": false}])
	inp := {"head_commit": head, "attestations": [{"verified": true, "statement": s}]}
	count(gate.deny) == 1 with input as inp
}

test_mislabelled_review_kind_holds if {
	s := json.patch(statement([]), [{"op": "replace", "path": "/predicate/review_kind", "value": "human-review"}])
	inp := {"head_commit": head, "attestations": [{"verified": true, "statement": s}]}
	count(gate.deny) == 1 with input as inp
}

test_required_test_evidence_missing_holds if {
	some msg in gate.deny with input as run([], {"require_test_evidence": true})
	startswith(msg, "no verified test-result statement")
}
