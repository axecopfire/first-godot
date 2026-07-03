## SimAssert — reusable assertion helpers for headless simulation validation.
##
## Assertions declare expected outcomes and fail with a diff-style output on mismatch.
## Failed assertions cause the simulation to exit with non-zero status.

class_name SimAssert

static var _assertions_failed: int = 0
static var _assertions_passed: int = 0
static var _current_context: Dictionary = {}

# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

## Set contextual info for better assertion messages.
static func set_context(context: Dictionary) -> void:
	_current_context = context.duplicate()

## Reset assertion counters and context before a new simulation run.
static func reset() -> void:
	_assertions_failed = 0
	_assertions_passed = 0
	_current_context = {}

## Assert NPC is at a specific location during a time window.
static func assert_npc_location(npc_id: String, expected_location: Vector2, actual_location: Vector2, tolerance: float = 1.0, message: String = "") -> void:
	var distance = actual_location.distance_to(expected_location)
	if distance > tolerance:
		var diff_msg = "NPC '%s' location mismatch\n%s" % [npc_id, _format_diff(expected_location, actual_location)]
		diff_msg += "\nTolerance: %.2f | Distance: %.2f" % [tolerance, distance]
		if message:
			diff_msg = "%s\n%s" % [message, diff_msg]
		_fail_assertion(diff_msg)
		return
	_pass_assertion()

## Assert NPC is performing a specific action.
static func assert_npc_action(npc_id: String, expected_action: String, actual_action: String, message: String = "") -> void:
	if expected_action != actual_action:
		var diff_msg = "NPC '%s' action mismatch\n%s" % [npc_id, _format_diff(expected_action, actual_action)]
		if message:
			diff_msg = "%s\n%s" % [message, diff_msg]
		_fail_assertion(diff_msg)
		return
	_pass_assertion()

## Assert NPC goal matches expected value.
static func assert_npc_goal(npc_id: String, expected_goal: String, actual_goal: String, message: String = "") -> void:
	if expected_goal != actual_goal:
		var diff_msg = "NPC '%s' goal mismatch\n%s" % [npc_id, _format_diff(expected_goal, actual_goal)]
		if message:
			diff_msg = "%s\n%s" % [message, diff_msg]
		_fail_assertion(diff_msg)
		return
	_pass_assertion()

## Assert a condition is true; fail with message if false.
static func assert_true(condition: bool, message: String) -> void:
	if not condition:
		_fail_assertion(message)
		return
	_pass_assertion()

## Assert a condition is false; fail with message if true.
static func assert_false(condition: bool, message: String) -> void:
	if condition:
		_fail_assertion(message)
		return
	_pass_assertion()

## Assert two values are equal; fail with diff if not.
static func assert_equal(actual, expected, message: String = "") -> void:
	if actual != expected:
		var diff_msg = _format_diff(expected, actual)
		if message:
			diff_msg = "%s\n%s" % [message, diff_msg]
		_fail_assertion(diff_msg)
		return
	_pass_assertion()

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
		return
	_pass_assertion()

## Assert selected fields in an event dictionary match expected values.
static func assert_event_fields(actual_event: Dictionary, expected_fields: Dictionary, message: String = "") -> void:
	var mismatches: Array[String] = []
	for key in expected_fields:
		if not actual_event.has(key):
			mismatches.append("  Missing key: %s" % key)
			continue
		if actual_event[key] != expected_fields[key]:
			mismatches.append("  Key '%s'\n    %s" % [key, _format_diff(expected_fields[key], actual_event[key])])

	if mismatches.size() > 0:
		var diff_msg = "Event field mismatch:\n%s" % "\n".join(mismatches)
		if message:
			diff_msg = "%s\n%s" % [message, diff_msg]
		_fail_assertion(diff_msg)
		return
	_pass_assertion()

## Get count of failed assertions.
static func get_failed_count() -> int:
	return _assertions_failed

## Get count of passed assertions.
static func get_passed_count() -> int:
	return _assertions_passed

## Exit with non-zero status if any assertions failed.
static func exit_if_failed() -> int:
	if _assertions_failed > 0:
		print("\n[SimAssert] %d assertion(s) failed, %d passed." % [_assertions_failed, _assertions_passed])
		return 1

	print("\n[SimAssert] All assertions passed (%d total)." % _assertions_passed)
	return 0


# ---------------------------------------------------------------------------
# Internal
# ---------------------------------------------------------------------------

static func _format_diff(expected, actual) -> String:
	return "- expected: %s\n+ actual:   %s" % [expected, actual]

static func _pass_assertion() -> void:
	_assertions_passed += 1

static func _build_context_suffix() -> String:
	if _current_context.size() == 0:
		return ""
	return " (context: %s)" % str(_current_context)

static func _fail_assertion(message: String) -> void:
	_assertions_failed += 1
	print("[ASSERTION FAILED]%s\n%s\n" % [_build_context_suffix(), message])

