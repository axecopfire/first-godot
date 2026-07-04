## Smoke tests for GoapPlanner (issue #7 — Bounded GOAP Planner).
##
## Covers all four acceptance criteria:
##   1. Planner runs only on configured triggers.
##   2. Search depth/branching is bounded by config.
##   3. Returns selected intent with candidate HTN root binding.
##   4. Returns safe fallback result when no valid candidate exists.
extends SceneTree

const GoapPlannerClass = preload("res://scripts/ai/goap_planner.gd")
const SimAssert = preload("res://scripts/tools/sim_assert.gd")

# ---------------------------------------------------------------------------
# Shared fixtures
# ---------------------------------------------------------------------------

const _ACTIONS: Array[Dictionary] = [
	{
		"name": "GoToWork",
		"cost": 1.0,
		"pre": {},
		"effects": {"at_work": true, "at_home": false, "at_social_hub": false},
	},
	{
		"name": "GoHome",
		"cost": 1.0,
		"pre": {},
		"effects": {"at_home": true, "at_work": false, "at_social_hub": false},
	},
	{
		"name": "SocializeAtHub",
		"cost": 1.4,
		"pre": {"bell_pending": false},
		"effects": {"at_social_hub": true, "at_home": false, "at_work": false, "recently_socialized": true},
	},
	{
		"name": "WanderLocal",
		"cost": 1.8,
		"pre": {},
		"effects": {"recently_socialized": false},
	},
]

const _BASE_FACTS: Dictionary = {
	"in_work_window": true,
	"bell_pending": false,
	"player_nearby": false,
	"has_friendly_tie": false,
	"at_home": false,
	"at_work": false,
	"at_social_hub": false,
	"recently_socialized": false,
}

func _make_goal(p_name: String, p_desired: Dictionary, p_score: float) -> Dictionary:
	return {"name": p_name, "desired": p_desired, "effective_score": p_score}

# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------

func _initialize() -> void:
	SimAssert.reset()

	_test_trigger_gate()
	_test_depth_bound()
	_test_branching_bound()
	_test_intent_and_htn_root()
	_test_fallback_no_goals()
	_test_fallback_impossible_goal()
	_test_goal_already_satisfied()

	quit(SimAssert.exit_if_failed())

## AC1: Planner runs only on configured triggers.
func _test_trigger_gate() -> void:
	SimAssert.set_context({"test": "trigger_gate"})
	var planner := GoapPlannerClass.new()
	planner.configure({"triggers": ["bell_toll", "hour_change"]})

	SimAssert.assert_true(
		planner.should_replan("bell_toll"),
		"should_replan: bell_toll is a configured trigger"
	)
	SimAssert.assert_true(
		planner.should_replan("hour_change"),
		"should_replan: hour_change is a configured trigger"
	)
	SimAssert.assert_true(
		not planner.should_replan("cooldown_expired"),
		"should_replan: cooldown_expired is NOT in the configured trigger list"
	)
	SimAssert.assert_true(
		not planner.should_replan(""),
		"should_replan: empty string is never a trigger"
	)

## AC2a: Depth bound — max_depth=1 must not return plans longer than 1 step.
func _test_depth_bound() -> void:
	SimAssert.set_context({"test": "depth_bound"})
	var planner := GoapPlannerClass.new()
	planner.configure({"max_depth": 1, "triggers": ["any"]})

	# Goal requires two sequential actions to satisfy if we were to chain them,
	# but with depth=1 only single-action plans are valid.
	var goals: Array[Dictionary] = [
		_make_goal("maintain_role_routine", {"at_work": true}, 5.0),
	]
	var result := planner.plan(_ACTIONS, goals, _BASE_FACTS, "any")

	SimAssert.assert_true(
		result.get("plan", []).size() <= 1,
		"depth_bound: plan length must be <= max_depth=1"
	)

## AC2b: Branching bound — max_branching=1 must still find a valid 1-step plan
##        when a direct action exists (cheapest action is selected).
func _test_branching_bound() -> void:
	SimAssert.set_context({"test": "branching_bound"})
	var planner := GoapPlannerClass.new()
	planner.configure({"max_depth": 3, "max_branching": 1, "triggers": ["any"]})

	var goals: Array[Dictionary] = [
		_make_goal("maintain_role_routine", {"at_work": true}, 5.0),
	]
	var result := planner.plan(_ACTIONS, goals, _BASE_FACTS, "any")

	SimAssert.assert_true(
		not result.get("is_fallback", true),
		"branching_bound: a direct GoToWork plan must still be found with branching=1"
	)
	SimAssert.assert_equal(
		result.get("plan", []).size(),
		1,
		"branching_bound: single-step GoToWork plan expected"
	)

## AC3: Returns selected intent with candidate HTN root binding.
func _test_intent_and_htn_root() -> void:
	SimAssert.set_context({"test": "intent_and_htn_root"})
	var planner := GoapPlannerClass.new()
	planner.configure({"triggers": ["any"]})

	var goals: Array[Dictionary] = [
		_make_goal("maintain_role_routine", {"at_work": true}, 5.0),
		_make_goal("maintain_rest_routine", {"at_home": true}, 2.0),
	]
	var result := planner.plan(_ACTIONS, goals, _BASE_FACTS, "any")

	SimAssert.assert_equal(result.get("intent", ""), "maintain_role_routine",
		"intent: highest-scored goal must be selected"
	)
	SimAssert.assert_equal(result.get("htn_root", ""), "HTNGoToWork",
		"htn_root: maintain_role_routine must bind to HTNGoToWork"
	)
	SimAssert.assert_true(
		result.has("plan"),
		"result must always carry a plan key"
	)
	SimAssert.assert_true(
		result.has("trigger"),
		"result must always carry a trigger key"
	)

## AC4a: Safe fallback when no goals are provided.
func _test_fallback_no_goals() -> void:
	SimAssert.set_context({"test": "fallback_no_goals"})
	var planner := GoapPlannerClass.new()
	planner.configure({"triggers": ["any"]})

	var result := planner.plan(_ACTIONS, [], _BASE_FACTS, "any")

	SimAssert.assert_true(
		result.get("is_fallback", false),
		"fallback: is_fallback must be true when no goals are provided"
	)
	SimAssert.assert_true(
		result.get("intent", "") != "",
		"fallback: intent must never be empty even in fallback"
	)
	SimAssert.assert_true(
		result.get("htn_root", "") != "",
		"fallback: htn_root must never be empty even in fallback"
	)

## AC4b: Safe fallback when goal cannot be achieved within bounds.
func _test_fallback_impossible_goal() -> void:
	SimAssert.set_context({"test": "fallback_impossible_goal"})
	var planner := GoapPlannerClass.new()
	# max_depth=0 makes any non-trivially-satisfied goal impossible.
	planner.configure({"max_depth": 0, "triggers": ["any"]})

	var goals: Array[Dictionary] = [
		_make_goal("maintain_role_routine", {"at_work": true}, 5.0),
	]
	# Facts do NOT satisfy desired {"at_work":true}.
	var result := planner.plan(_ACTIONS, goals, _BASE_FACTS, "any")

	SimAssert.assert_true(
		result.get("is_fallback", false),
		"fallback_impossible: is_fallback must be true when goal is unreachable within depth=0"
	)

## Goal already satisfied — plan array must be empty but is_fallback must be false.
func _test_goal_already_satisfied() -> void:
	SimAssert.set_context({"test": "goal_already_satisfied"})
	var planner := GoapPlannerClass.new()
	planner.configure({"triggers": ["any"]})

	var goals: Array[Dictionary] = [
		_make_goal("maintain_role_routine", {"at_work": true}, 5.0),
	]
	var at_work_facts := _BASE_FACTS.duplicate()
	at_work_facts["at_work"] = true

	var result := planner.plan(_ACTIONS, goals, at_work_facts, "any")

	SimAssert.assert_true(
		not result.get("is_fallback", true),
		"satisfied_goal: is_fallback must be false when goal is already met"
	)
	SimAssert.assert_equal(
		result.get("plan", ["non-empty"]).size(),
		0,
		"satisfied_goal: plan must be empty when goal is already satisfied"
	)
	SimAssert.assert_equal(
		result.get("intent", ""),
		"maintain_role_routine",
		"satisfied_goal: intent must still be set correctly"
	)
