## Smoke tests for HtnLibrary (issue #8 — HTN Libraries for Work/Rest/Social).
extends SceneTree

const HtnLibraryClass = preload("res://scripts/ai/htn_library.gd")
const SimAssert = preload("res://scripts/tools/sim_assert.gd")

func _initialize() -> void:
	SimAssert.reset()

	_test_required_roots_exist()
	_test_compound_methods_have_variants_and_fallback()
	_test_primitives_match_executor_vocabulary()
	_test_decomposition_outputs_ordered_primitives()

	quit(SimAssert.exit_if_failed())

## AC1: Includes PerformWorkday, PerformRestDay, PerformSocialWindow roots.
func _test_required_roots_exist() -> void:
	SimAssert.set_context({"test": "required_roots"})
	var library := HtnLibraryClass.new()
	var roots: Array[String] = library.get_root_tasks()

	SimAssert.assert_true(HtnLibraryClass.ROOT_WORKDAY in roots,
		"root set must include PerformWorkday"
	)
	SimAssert.assert_true(HtnLibraryClass.ROOT_RESTDAY in roots,
		"root set must include PerformRestDay"
	)
	SimAssert.assert_true(HtnLibraryClass.ROOT_SOCIAL in roots,
		"root set must include PerformSocialWindow"
	)

## AC2: Every compound task has at least two methods and one fallback method.
func _test_compound_methods_have_variants_and_fallback() -> void:
	SimAssert.set_context({"test": "method_coverage"})
	var library := HtnLibraryClass.new()
	var validation: Dictionary = library.validate_library()
	var issues: Array = validation.get("issues", [])

	SimAssert.assert_true(
		validation.get("ok", false),
		"all compound tasks must provide at least two methods and one fallback. issues=%s" % [str(issues)]
	)

## AC3: Primitive leaves map to existing executor action vocabulary.
func _test_primitives_match_executor_vocabulary() -> void:
	SimAssert.set_context({"test": "primitive_vocabulary"})
	var library := HtnLibraryClass.new()
	var expected := {
		"GoToWork": true,
		"GoHome": true,
		"SocializeAtHub": true,
		"WanderLocal": true,
	}
	var primitives: Array[String] = library.get_primitive_actions()

	for primitive in primitives:
		SimAssert.assert_true(expected.has(primitive),
			"primitive '%s' must be in executor action vocabulary" % primitive
		)

## AC4: Decomposition output is an ordered primitive sequence.
func _test_decomposition_outputs_ordered_primitives() -> void:
	SimAssert.set_context({"test": "decomposition_order"})
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

	var result: Dictionary = library.decompose(HtnLibraryClass.ROOT_WORKDAY, context)
	SimAssert.assert_true(result.get("success", false),
		"decomposition must succeed for PerformWorkday under standard context"
	)

	var primitives: Array[String] = result.get("primitive_sequence", [])
	SimAssert.assert_true(primitives.size() > 0,
		"decomposition must produce at least one primitive"
	)
	if primitives.size() >= 2:
		SimAssert.assert_equal(primitives[0], "GoToWork",
			"ordered output must begin with travel primitive when not at work"
		)
		SimAssert.assert_equal(primitives[1], "WanderLocal",
			"ordered output must preserve method subtask order"
		)
	else:
		SimAssert.assert_true(false,
			"ordered output must include two primitives for this context"
		)
