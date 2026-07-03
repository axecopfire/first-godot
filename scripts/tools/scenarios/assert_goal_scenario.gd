## Example assertion scenario for the headless runner.
## Loaded via: --assert-script res://scripts/tools/scenarios/assert_goal_scenario.gd

extends RefCounted

const SimAssert = preload("res://scripts/tools/sim_assert.gd")

func on_decision(event: Dictionary, _runner: Node, _assert_class) -> void:
	if event.get("npc_id", "") == "baker_1" and event.get("hour", 0) >= 6 and event.get("hour", 0) <= 16:
		SimAssert.assert_npc_goal(
			event.get("npc_id", ""),
			"work",
			event.get("active_goal", ""),
			"Baker should prefer work goals during daytime decision points"
		)

func on_complete(_runner: Node, _assert_class) -> void:
	# Confirms scenario can import and call SimAssert directly.
	SimAssert.assert_true(true, "Assertion scenario executed")
