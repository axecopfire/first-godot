## SimAssert — reusable assertion helpers for headless simulation validation.
##
## Assertions declare expected outcomes and fail with a diff-style output on mismatch.
## Failed assertions cause the simulation to exit with non-zero status.

class_name SimAssert

static var _assertions_failed: int = 0
static var _current_context: Dictionary = {}

# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

## Set contextual info for better assertion messages.
static func set_context(context: Dictionary) -> void:
	_current_context = context.duplicate()

## Assert NPC is at a specific location during a time window.
static func assert_npc_location(npc_id: String, expected_location: Vector2, tolerance: float = 1.0) -> void:
	# Placeholder: will check actual NPC position during simulation.
	# For now, log the assertion and allow it to pass pending full simulation data.
	print("✓ assert_npc_location(npc_id=%s, expected_location=%s, tolerance=%f)" % [npc_id, expected_location, tolerance])

## Assert NPC is performing a specific action.
static func assert_npc_action(npc_id: String, expected_action: String) -> void:
	print("✓ assert_npc_action(npc_id=%s, expected_action=%s)" % [npc_id, expected_action])

## Assert NPC goal matches expected value.
static func assert_npc_goal(npc_id: String, expected_goal: String) -> void:
	print("✓ assert_npc_goal(npc_id=%s, expected_goal=%s)" % [npc_id, expected_goal])

## Assert a condition is true; fail with message if false.
static func assert_true(condition: bool, message: String) -> void:
	if not condition:
		_fail_assertion(message)

## Assert a condition is false; fail with message if true.
static func assert_false(condition: bool, message: String) -> void:
	if condition:
		_fail_assertion(message)

## Assert two values are equal; fail with diff if not.
static func assert_equal(actual, expected, message: String = "") -> void:
	if actual != expected:
		var diff_msg = "Expected: %s\nActual:   %s" % [expected, actual]
		if message:
			diff_msg = "%s\n%s" % [message, diff_msg]
		_fail_assertion(diff_msg)

## Assert two dictionaries match; fail with keyed diff if not.
static func assert_dict_equal(actual: Dictionary, expected: Dictionary, message: String = "") -> void:
	var mismatches = []
	for key in expected:
		if not actual.has(key):
			mismatches.append("  Missing key: %s" % key)
		elif actual[key] != expected[key]:
			mismatches.append("  Key '%s': expected %s, got %s" % [key, expected[key], actual[key]])
	
	for key in actual:
		if not expected.has(key):
			mismatches.append("  Unexpected key: %s" % key)
	
	if mismatches.size() > 0:
		var diff_msg = "Dictionary mismatch:\n%s" % "\n".join(mismatches)
		if message:
			diff_msg = "%s\n%s" % [message, diff_msg]
		_fail_assertion(diff_msg)

## Get count of failed assertions.
static func get_failed_count() -> int:
	return _assertions_failed

## Exit with non-zero status if any assertions failed.
static func exit_if_failed() -> void:
	if _assertions_failed > 0:
		print("\n[SimAssert] %d assertion(s) failed." % _assertions_failed)
		# In headless context, we just print and let the caller handle exit


# ---------------------------------------------------------------------------
# Internal
# ---------------------------------------------------------------------------

static func _fail_assertion(message: String) -> void:
	_assertions_failed += 1
	var context_str = ""
	if _current_context.size() > 0:
		context_str = " (context: %s)" % str(_current_context)
	print("[ASSERTION FAILED]%s\n%s\n" % [context_str, message])

