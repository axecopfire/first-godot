extends SceneTree

const NpcBrainClass = preload("res://scripts/npc_brain.gd")
const SimAssert = preload("res://scripts/tools/sim_assert.gd")

func _initialize() -> void:
	SimAssert.reset()

	var brain = NpcBrainClass.new(42)
	var daytime_facts = {
		"in_work_window": true,
		"bell_pending": false,
		"player_nearby": true,
		"has_friendly_tie": true,
		"at_home": false,
		"at_work": false,
		"at_social_hub": false,
		"recently_socialized": false,
	}

	var catalog: Array[Dictionary] = brain._build_goap_goal_catalog(daytime_facts)
	for goal in catalog:
		for key in ["base", "urgency", "social", "economic", "cooldown", "switch_penalty", "hysteresis"]:
			SimAssert.assert_true(goal.has(key), "Goal '%s' is missing required field '%s'" % [goal.get("name", ""), key])

	brain._goap_current_goal = "maintain_role_routine"
	var soft_choice: Dictionary = brain._select_goal(daytime_facts, false)
	SimAssert.assert_equal(soft_choice.get("name", ""), "maintain_role_routine", "Soft reevaluation should retain the current role goal under hysteresis")
	SimAssert.assert_true(brain._last_hysteresis_retained, "Soft reevaluation should record a hysteresis hold when the challenger is close")

	var spike_facts = daytime_facts.duplicate()
	spike_facts["bell_pending"] = true
	var hard_choice: Dictionary = brain._select_goal(spike_facts, true)
	SimAssert.assert_equal(hard_choice.get("name", ""), "avoid_attention_spike", "Hard reevaluation should bypass commitment protection during an attention spike")

	brain._goap_current_goal = ""
	var first_pick: Dictionary = brain._select_goal(daytime_facts, false)
	var second_pick: Dictionary = brain._select_goal(daytime_facts, false)
	SimAssert.assert_equal(first_pick.get("name", ""), second_pick.get("name", ""), "Goal selection should be deterministic for fixed input")

	quit(SimAssert.exit_if_failed())