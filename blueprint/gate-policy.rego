# Reference gate policy for AI Code Review, in Rego v1.
#
# Runs under Conforma (`ec validate input` before merge, `ec validate image` at release) or plain OPA.
# It holds a merge on a blocking deterministic finding, and never on a model finding unless the team has
# raised that rule (decision D13). It never reads the absence of findings as approval: it only says
# what holds the merge. A person still decides every merge.
#
# Input, for the OPA form (Conforma supplies verified attestations in its own shape; adapt the two
# helper rules at the bottom):
#   {
#     "head_commit": "<40 hex>",
#     "attestations": [ { "verified": true, "statement": { ...in-toto Statement v1... } } ],
#     "settings": {
#       "raised_model_rules": ["model.security.removed-check"],   # model rules the team made blocking
#       "require_test_evidence": false                            # also require the harness's statement
#     }
#   }

package ai_code_review.gate

import rego.v1

review_type := "https://croadfeldt.github.io/ai-code-review/attestation/ai-code-review/v0.1"

harness_result_type := "https://in-toto.io/attestation/test-result/v0.1"

# --- What holds the merge -----------------------------------------------------------------------

deny contains msg if {
	count(reviews) == 0
	msg := sprintf("no verified ai-code-review statement for head commit %s", [input.head_commit])
}

deny contains msg if {
	some r in reviews
	r.predicate.review_kind != "automated-analysis"
	msg := "an ai-code-review statement claims to be something other than automated analysis"
}

deny contains msg if {
	some r in reviews
	r.predicate.selfcheck.passed != true
	msg := "the reviewer's self-check did not pass, so its statement is not evidence"
}

deny contains msg if {
	some r in reviews
	some f in r.predicate.findings
	startswith(f.rule_id, "gate.")
	f.blocking == true
	msg := sprintf("blocking finding %s at %s:%d", [f.rule_id, f.location.path, f.location.start_line])
}

deny contains msg if {
	some r in reviews
	some f in r.predicate.findings
	startswith(f.rule_id, "model.")
	f.rule_id in object.get(input, ["settings", "raised_model_rules"], [])
	msg := sprintf("finding %s at %s:%d, a model rule this team made blocking", [f.rule_id, f.location.path, f.location.start_line])
}

deny contains msg if {
	object.get(input, ["settings", "require_test_evidence"], false) == true
	count(harness_results) == 0
	msg := sprintf("no verified test-result statement for head commit %s", [input.head_commit])
}

# --- What the person deciding should see, without holding the merge -----------------------------

warn contains msg if {
	some r in reviews
	some f in r.predicate.findings
	not holds(f)
	msg := sprintf("advisory finding %s at %s:%d", [f.rule_id, f.location.path, f.location.start_line])
}

warn contains msg if {
	some r in reviews
	some n in r.predicate.not_checked
	msg := sprintf("not checked: %s (%s)", [n.what, n.reason])
}

holds(f) if {
	startswith(f.rule_id, "gate.")
	f.blocking == true
}

holds(f) if {
	startswith(f.rule_id, "model.")
	f.rule_id in object.get(input, ["settings", "raised_model_rules"], [])
}

# --- Helpers: verified statements about this head commit -----------------------------------------

reviews contains s if {
	some a in input.attestations
	a.verified == true
	s := a.statement
	s.predicateType == review_type
	about_head(s)
}

harness_results contains s if {
	some a in input.attestations
	a.verified == true
	s := a.statement
	s.predicateType == harness_result_type
	about_head(s)
}

about_head(s) if {
	some subj in s.subject
	subj.digest.gitCommit == input.head_commit
}
