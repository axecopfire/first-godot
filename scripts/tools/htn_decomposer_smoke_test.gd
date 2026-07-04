## Smoke tests for HtnLibrary decomposition guardrails (issue #9 — Bounded HTN Decomposer).
extends SceneTree

const HtnLibraryClass = preload("res://scripts/ai/htn_library.gd")
const SimAssert = preload("res://scripts/tools/sim_assert.gd")

func _initialize() -> void:
	SimAssert.reset()

	_test_missing_valid_method_uses_fallback()
	_test_decomposition_is_deterministic()
	_test_depth_limit_returns_reason_code()
	_test_expansion_limit_returns_reason_code()

	quit(SimAssert.exit_if_failed())

## AC2: Missing valid method falls back to the default method.
func _test_missing_valid_method_uses_fallback() -> void:
	SimAssert.set_context({"test": "fallback_method"})
	var library := HtnLibraryClass.new()
	var context := {
		"bell_pending": false,
		"at_work": false,
		"at_home": false,
		"at_social_hub": false,
	}

	var result: Dictionary = library.decompose(HtnLibraryClass.ROOT_WORKDAY, context)
	var trace: Array = result.get("method_trace", [])

	SimAssert.assert_true(result.get("success", false),
		"decomposition must succeed by using fallback when no root method conditions match"
	)
	SimAssert.assert_equal(result.get("reason_code", ""), HtnLibraryClass.REASON_OK,
		"fallback success must report ok reason code"
	)
	SimAssert.assert_equal(result.get("primitive_sequence", []), ["WanderLocal"],
		"fallback workday method must yield WanderLocal"
	)
	SimAssert.assert_true(trace.size() > 0 and bool(trace[0].get("is_fallback", false)),
		"first selected method must be marked as fallback"
	)

## AC3: Output is deterministic for fixed facts/task input.
func _test_decomposition_is_deterministic() -> void:
	SimAssert.set_context({"test": "determinism"})
	var library := HtnLibraryClass.new()
	var context := {
		"in_work_window": true,
		"bell_pending": false,
		"player_nearby": true,
		"has_friendly_tie": true,
		"at_work": false,
		"at_home": true,
		"at_social_hub": false,
	}

	var first: Dictionary = library.decompose(HtnLibraryClass.ROOT_WORKDAY, context)
	var second: Dictionary = library.decompose(HtnLibraryClass.ROOT_WORKDAY, context)

	SimAssert.assert_equal(first.get("primitive_sequence", []), second.get("primitive_sequence", []),
		"fixed input must produce identical primitive sequence"
	)
	SimAssert.assert_equal(first.get("method_trace", []), second.get("method_trace", []),
		"fixed input must produce identical method trace"
	)

## AC1 + AC4: Depth is bounded and failure returns an explicit reason code.
func _test_depth_limit_returns_reason_code() -> void:
	SimAssert.set_context({"test": "depth_limit"})
	var library := HtnLibraryClass.new(_build_cyclic_library())
	var result: Dictionary = library.decompose("LoopA", {}, {"max_depth": 2, "max_expansions": 20})

	SimAssert.assert_false(result.get("success", true),
		"cyclic decomposition must fail when depth limit is exceeded"
	)
	SimAssert.assert_equal(result.get("reason_code", ""), HtnLibraryClass.REASON_DEPTH_LIMIT_EXCEEDED,
		"depth overflow must report depth_limit_exceeded"
	)

## AC1 + AC4: Expansion is bounded and failure returns an explicit reason code.
func _test_expansion_limit_returns_reason_code() -> void:
	SimAssert.set_context({"test": "expansion_limit"})
	var library := HtnLibraryClass.new(_build_cyclic_library())
	var result: Dictionary = library.decompose("LoopA", {}, {"max_depth": 20, "max_expansions": 3})

	SimAssert.assert_false(result.get("success", true),
		"cyclic decomposition must fail when expansion limit is exceeded"
	)
	SimAssert.assert_equal(result.get("reason_code", ""), HtnLibraryClass.REASON_EXPANSION_LIMIT_EXCEEDED,
		"expansion overflow must report expansion_limit_exceeded"
	)

func _build_cyclic_library() -> Dictionary:
	return {
		"LoopA": [
			{
				"name": "loop_to_b",
				"conditions": {},
				"subtasks": ["LoopB"],
			},
			{
				"name": "fallback_loop_to_b",
				"is_fallback": true,
				"subtasks": ["LoopB"],
			},
		],
		"LoopB": [
			{
				"name": "loop_to_a",
				"conditions": {},
				"subtasks": ["LoopA"],
			},
			{
				"name": "fallback_loop_to_a",
				"is_fallback": true,
				"subtasks": ["LoopA"],
			},
		],
	}