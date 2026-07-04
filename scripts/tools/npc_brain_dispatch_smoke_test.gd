## Smoke tests for NPC brain hybrid dispatch boundary (issue #10).
extends SceneTree

const NpcBrainClass = preload("res://scripts/npc_brain.gd")
const HtnLibraryClass = preload("res://scripts/ai/htn_library.gd")
const SimAssert = preload("res://scripts/tools/sim_assert.gd")

func _initialize() -> void:
	SimAssert.reset()

	_test_bootstrap_trigger_runs_goap_policy()
	_test_winning_goal_binds_htn_and_decomposes()
	_test_primitive_precondition_failure_replans()

	quit(SimAssert.exit_if_failed())

func _test_bootstrap_trigger_runs_goap_policy() -> void:
	SimAssert.set_context({"test": "bootstrap_trigger"})
	var brain := NpcBrainClass.new(123)
	var decision := _tick(brain, 9, {
		"bell_pending_tolls": 0,
	}, false, false)

	SimAssert.assert_true(bool(decision.get("new_decision", false)),
		"bootstrap must produce a decision event"
	)
	SimAssert.assert_equal(str(decision.get("trigger", "")), "bootstrap",
		"first tick must classify as bootstrap trigger"
	)
	SimAssert.assert_true(str(decision.get("goal", "")) != "",
		"GOAP policy must choose a non-empty goal"
	)

func _test_winning_goal_binds_htn_and_decomposes() -> void:
	SimAssert.set_context({"test": "htn_binding"})
	var brain := NpcBrainClass.new(321)
	var decision := _tick(brain, 10, {
		"bell_pending_tolls": 0,
	}, false, false)
	var primitives: Array = decision.get("primitive_sequence", [])

	SimAssert.assert_equal(str(decision.get("htn_root", "")), HtnLibraryClass.ROOT_WORKDAY,
		"work-window winner must bind to PerformWorkday HTN root"
	)
	SimAssert.assert_true(primitives.size() > 0,
		"successful HTN decomposition must produce at least one primitive"
	)
	SimAssert.assert_true(str(decision.get("method", "")) != "",
		"method trace should include the selected HTN method"
	)
	SimAssert.assert_equal(str(decision.get("plan_step", "")), str(primitives[0]),
		"executor step must come from decomposed primitive sequence"
	)

func _test_primitive_precondition_failure_replans() -> void:
	SimAssert.set_context({"test": "precondition_failure"})
	var brain := NpcBrainClass.new(777)

	# Off-shift and socially primed so social assimilation wins first.
	var initial := _tick(brain, 21, {
		"bell_pending_tolls": 0,
	}, true, true)
	var initial_primitives: Array = initial.get("primitive_sequence", [])
	SimAssert.assert_true(initial_primitives.size() > 0,
		"initial decision should produce a primitive sequence"
	)

	# Bell turns on (without nearby player) so SocializeAtHub precondition fails,
	# forcing corrective GOAP replanning by precondition_failure trigger.
	var corrected := _tick(brain, 21, {
		"bell_pending_tolls": 1,
	}, false, true)
	SimAssert.assert_equal(str(corrected.get("trigger", "")), "precondition_failure",
		"primitive precondition failure must trigger corrective GOAP reevaluation"
	)
	SimAssert.assert_true(bool(corrected.get("new_decision", false)),
		"precondition failure path must emit a new decision"
	)
	SimAssert.assert_true(str(corrected.get("goal", "")) != "",
		"corrective reevaluation must still choose a valid goal"
	)

func _tick(brain: NpcBrain, hour: int, world_state: Dictionary, player_nearby: bool, has_friendly_tie: bool) -> Dictionary:
	var cycle_progress: float = float(hour) / 24.0
	return brain.tick(
		0.1,
		cycle_progress,
		Vector2(48, 24),
		Vector2(40, 24),
		Vector2(64, 24),
		7,
		18,
		world_state,
		player_nearby,
		has_friendly_tie
	)
