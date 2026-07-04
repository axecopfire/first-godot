## GoapPlanner — standalone bounded GOAP planner triggered by explicit events.
##
## Planning is gated by a configurable trigger list so per-tick planning cost is
## avoided.  The BFS search is double-bounded: a depth cap prevents runaway plan
## lengths and a branching cap limits the node fan-out at each level.
##
## ## Configuration
## Pass a Dictionary to configure():
##   max_depth:    int            — max plan steps (default 3)
##   max_branching: int           — max actions expanded per node (default 8)
##   triggers:     Array[String]  — trigger names that activate replanning
##
## ## Result schema (returned by plan())
##   intent:      String        — selected goal name
##   htn_root:    String        — candidate HTN root task binding
##   plan:        Array[String] — ordered action names (may be empty when goal is
##                                already satisfied)
##   is_fallback: bool          — true when no valid plan; safe defaults applied
##   trigger:     String        — the trigger that initiated this plan
class_name GoapPlanner
extends RefCounted

const DEFAULT_MAX_DEPTH := 3
const DEFAULT_MAX_BRANCHING := 8

const FALLBACK_INTENT := "maintain_rest_routine"
const FALLBACK_HTN_ROOT := "HTNGoHome"

## Maps goal intent names to their candidate HTN root task names.
const _INTENT_TO_HTN_ROOT: Dictionary = {
	"maintain_role_routine":       "HTNGoToWork",
	"maintain_rest_routine":       "HTNGoHome",
	"maintain_social_assimilation": "HTNSocializeAtHub",
	"avoid_attention_spike":       "HTNSeekSafety",
}

var _max_depth: int = DEFAULT_MAX_DEPTH
var _max_branching: int = DEFAULT_MAX_BRANCHING
var _triggers: Array[String] = []

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

## Apply planner configuration.  Safe to call multiple times; each call fully
## replaces the previous configuration.
func configure(config: Dictionary) -> void:
	_max_depth = int(config.get("max_depth", DEFAULT_MAX_DEPTH))
	_max_branching = int(config.get("max_branching", DEFAULT_MAX_BRANCHING))
	var raw_triggers = config.get("triggers", ["cooldown_expired"])
	_triggers = []
	for t in raw_triggers:
		_triggers.append(str(t))

# ---------------------------------------------------------------------------
# Trigger gate
# ---------------------------------------------------------------------------

## Returns true when trigger_name is in the configured triggers list, meaning
## the planner should be invoked for this event.
func should_replan(trigger_name: String) -> bool:
	return trigger_name in _triggers

# ---------------------------------------------------------------------------
# Planning entry point
# ---------------------------------------------------------------------------

## Run bounded GOAP planning and return a result Dictionary.
##
## actions:       Array[Dictionary] — available GOAP actions (name, cost, pre, effects)
## goals:         Array[Dictionary] — scored goal candidates; must each carry
##                                    name, desired, and effective_score fields
## initial_facts: Dictionary        — current world-state facts
## trigger:       String            — the trigger that caused this planning call
##
## Returns a result dictionary (see class docstring for schema).
func plan(
	actions: Array[Dictionary],
	goals: Array[Dictionary],
	initial_facts: Dictionary,
	trigger: String
) -> Dictionary:
	var selected_goal := _select_best_goal(goals)
	if selected_goal.is_empty():
		return _fallback_result(trigger)

	var intent := str(selected_goal.get("name", FALLBACK_INTENT))
	var desired: Dictionary = selected_goal.get("desired", {})

	# Goal already satisfied — no plan steps needed.
	if _goal_is_satisfied(initial_facts, desired):
		return {
			"intent": intent,
			"htn_root": _intent_to_htn_root(intent),
			"plan": [],
			"is_fallback": false,
			"trigger": trigger,
		}

	var plan_steps := _plan_for_goal(actions, initial_facts, desired)
	if plan_steps.is_empty():
		return _fallback_result(trigger)

	return {
		"intent": intent,
		"htn_root": _intent_to_htn_root(intent),
		"plan": plan_steps,
		"is_fallback": false,
		"trigger": trigger,
	}

# ---------------------------------------------------------------------------
# Internal — goal selection
# ---------------------------------------------------------------------------

func _select_best_goal(goals: Array[Dictionary]) -> Dictionary:
	if goals.is_empty():
		return {}
	var best: Dictionary = {}
	var best_score := -INF
	for goal in goals:
		var score := float(goal.get("effective_score", float(goal.get("score", -INF))))
		if score > best_score:
			best_score = score
			best = goal
	return best

# ---------------------------------------------------------------------------
# Internal — bounded BFS planner
# ---------------------------------------------------------------------------

func _plan_for_goal(
	actions: Array[Dictionary],
	initial_facts: Dictionary,
	desired: Dictionary
) -> Array[String]:
	var open_list: Array[Dictionary] = [{
		"facts": initial_facts,
		"cost": 0.0,
		"steps": PackedStringArray(),
	}]
	var visited: Dictionary = {}
	var best_plan: Array[String] = []
	var best_cost := INF

	while not open_list.is_empty():
		_sort_open_list(open_list)
		var node: Dictionary = open_list.pop_front()
		var node_facts: Dictionary = node.get("facts", {})
		var node_cost: float = float(node.get("cost", INF))
		var node_steps: PackedStringArray = node.get("steps", PackedStringArray())

		if node_steps.size() > _max_depth:
			continue

		if _goal_is_satisfied(node_facts, desired):
			if node_cost < best_cost:
				best_cost = node_cost
				best_plan = _packed_to_typed(node_steps)
			continue

		if node_cost >= best_cost:
			continue

		# Branching bound: only expand the cheapest _max_branching applicable actions.
		var applicable := _get_applicable_actions(actions, node_facts)
		var branch_count := 0
		for action in applicable:
			if branch_count >= _max_branching:
				break
			branch_count += 1

			var next_facts := _apply_effects(node_facts, action.get("effects", {}))
			var next_steps := node_steps.duplicate()
			next_steps.append(str(action.get("name", "")))
			var next_cost := node_cost + float(action.get("cost", 1.0))
			var signature := _world_signature(next_facts) + "|" + ",".join(next_steps)

			if visited.has(signature) and float(visited[signature]) <= next_cost:
				continue

			visited[signature] = next_cost
			open_list.append({
				"facts": next_facts,
				"cost": next_cost,
				"steps": next_steps,
			})

	return best_plan

func _get_applicable_actions(actions: Array[Dictionary], facts: Dictionary) -> Array[Dictionary]:
	var applicable: Array[Dictionary] = []
	for action in actions:
		if _matches_conditions(facts, action.get("pre", {})):
			applicable.append(action)
	applicable.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a.get("cost", 1.0)) < float(b.get("cost", 1.0))
	)
	return applicable

func _sort_open_list(open_list: Array[Dictionary]) -> void:
	open_list.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var ca := float(a.get("cost", INF))
		var cb := float(b.get("cost", INF))
		if ca == cb:
			var sa: PackedStringArray = a.get("steps", PackedStringArray())
			var sb: PackedStringArray = b.get("steps", PackedStringArray())
			return sa.size() < sb.size()
		return ca < cb
	)

# ---------------------------------------------------------------------------
# Internal — helpers
# ---------------------------------------------------------------------------

func _goal_is_satisfied(facts: Dictionary, desired: Dictionary) -> bool:
	return _matches_conditions(facts, desired)

func _matches_conditions(facts: Dictionary, conditions: Dictionary) -> bool:
	for key in conditions.keys():
		if facts.get(key, null) != conditions[key]:
			return false
	return true

func _apply_effects(facts: Dictionary, effects: Dictionary) -> Dictionary:
	var merged := facts.duplicate()
	for key in effects.keys():
		merged[key] = effects[key]
	return merged

func _world_signature(facts: Dictionary) -> String:
	var keys := facts.keys()
	keys.sort()
	var parts := PackedStringArray()
	for key in keys:
		parts.append("%s=%s" % [str(key), str(facts[key])])
	return "|".join(parts)

func _packed_to_typed(steps: PackedStringArray) -> Array[String]:
	var out: Array[String] = []
	for s in steps:
		out.append(s)
	return out

func _intent_to_htn_root(intent: String) -> String:
	return _INTENT_TO_HTN_ROOT.get(intent, FALLBACK_HTN_ROOT)

func _fallback_result(trigger: String) -> Dictionary:
	return {
		"intent": FALLBACK_INTENT,
		"htn_root": FALLBACK_HTN_ROOT,
		"plan": [],
		"is_fallback": true,
		"trigger": trigger,
	}
