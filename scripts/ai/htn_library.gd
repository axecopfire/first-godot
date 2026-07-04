## HtnLibrary provides authored HTN task/method libraries and deterministic
## decomposition into primitive executor actions.
class_name HtnLibrary
extends RefCounted

const ROOT_WORKDAY := "PerformWorkday"
const ROOT_RESTDAY := "PerformRestDay"
const ROOT_SOCIAL := "PerformSocialWindow"

const _MAX_RECURSION_DEPTH := 16

const _PRIMITIVE_ACTIONS: Array[String] = [
	"GoToWork",
	"GoHome",
	"SocializeAtHub",
	"WanderLocal",
]

var _methods_by_task: Dictionary = {}

func _init() -> void:
	_methods_by_task = _build_default_library()

func get_root_tasks() -> Array[String]:
	return [ROOT_WORKDAY, ROOT_RESTDAY, ROOT_SOCIAL]

func get_primitive_actions() -> Array[String]:
	return _PRIMITIVE_ACTIONS.duplicate()

func get_compound_tasks() -> Array[String]:
	var names: Array[String] = []
	for key in _methods_by_task.keys():
		names.append(str(key))
	names.sort()
	return names

func methods_for_task(task_name: String) -> Array[Dictionary]:
	var raw_methods: Array = _methods_by_task.get(task_name, [])
	var methods: Array[Dictionary] = []
	for method in raw_methods:
		methods.append(method)
	return methods.duplicate(true)

func root_for_intent(intent: String) -> String:
	match intent:
		"maintain_role_routine":
			return ROOT_WORKDAY
		"maintain_rest_routine":
			return ROOT_RESTDAY
		"maintain_social_assimilation":
			return ROOT_SOCIAL
		_:
			return ROOT_RESTDAY

func validate_library() -> Dictionary:
	var issues: Array[String] = []
	for task_name in _methods_by_task.keys():
		var methods := methods_for_task(str(task_name))
		if methods.size() < 2:
			issues.append("Task '%s' must have at least two methods" % task_name)
		var fallback_count := 0
		for method in methods:
			if bool(method.get("is_fallback", false)):
				fallback_count += 1
		if fallback_count < 1:
			issues.append("Task '%s' must define a fallback method" % task_name)

	return {
		"ok": issues.is_empty(),
		"issues": issues,
	}

func decompose(root_task: String, context: Dictionary) -> Dictionary:
	var primitives: Array[String] = []
	var method_trace: Array[Dictionary] = []
	var success := _decompose_task(root_task, context, primitives, method_trace, 0)
	return {
		"root": root_task,
		"success": success,
		"primitive_sequence": primitives,
		"method_trace": method_trace,
	}

func _decompose_task(
	task_name: String,
	context: Dictionary,
	primitives: Array[String],
	method_trace: Array[Dictionary],
	depth: int
) -> bool:
	if depth > _MAX_RECURSION_DEPTH:
		return false

	if task_name in _PRIMITIVE_ACTIONS:
		primitives.append(task_name)
		return true

	var methods := methods_for_task(task_name)
	if methods.is_empty():
		return false

	for method in methods:
		if not _method_applies(method, context):
			continue

		var primitive_checkpoint := primitives.size()
		var trace_checkpoint := method_trace.size()
		method_trace.append({
			"task": task_name,
			"method": str(method.get("name", "")),
		})

		var subtasks_raw: Array = method.get("subtasks", [])
		var all_subtasks_ok := true
		for subtask in subtasks_raw:
			if not _decompose_task(subtask, context, primitives, method_trace, depth + 1):
				all_subtasks_ok = false
				break

		if all_subtasks_ok:
			return true

		primitives.resize(primitive_checkpoint)
		method_trace.resize(trace_checkpoint)

	return false

func _method_applies(method: Dictionary, context: Dictionary) -> bool:
	if bool(method.get("is_fallback", false)):
		return true

	var conditions: Dictionary = method.get("conditions", {})
	for key in conditions.keys():
		if context.get(key, null) != conditions[key]:
			return false
	return true

func _build_default_library() -> Dictionary:
	return {
		ROOT_WORKDAY: [
			{
				"name": "work_in_window",
				"conditions": {"in_work_window": true},
				"subtasks": ["EnsureAtWork", "DoWorkBlock"],
			},
			{
				"name": "recover_after_shift",
				"conditions": {"in_work_window": false},
				"subtasks": ["EnsureAtHome", "RestAtHome"],
			},
			{
				"name": "fallback_workday",
				"is_fallback": true,
				"subtasks": ["WanderLocal"],
			},
		],
		ROOT_RESTDAY: [
			{
				"name": "rest_off_shift",
				"conditions": {"in_work_window": false},
				"subtasks": ["EnsureAtHome", "RestAtHome"],
			},
			{
				"name": "seek_shelter_on_bell",
				"conditions": {"bell_pending": true},
				"subtasks": ["EnsureAtHome", "RestAtHome"],
			},
			{
				"name": "fallback_restday",
				"is_fallback": true,
				"subtasks": ["WanderLocal"],
			},
		],
		ROOT_SOCIAL: [
			{
				"name": "socialize_with_player_present",
				"conditions": {"bell_pending": false, "player_nearby": true},
				"subtasks": ["EnsureAtSocialHub", "SocializeAtHub"],
			},
			{
				"name": "socialize_with_friendly_tie",
				"conditions": {"bell_pending": false, "has_friendly_tie": true},
				"subtasks": ["EnsureAtSocialHub", "SocializeAtHub"],
			},
			{
				"name": "fallback_social_window",
				"is_fallback": true,
				"subtasks": ["WanderLocal"],
			},
		],
		"EnsureAtWork": [
			{
				"name": "already_at_work",
				"conditions": {"at_work": true},
				"subtasks": [],
			},
			{
				"name": "travel_to_work",
				"conditions": {"at_work": false},
				"subtasks": ["GoToWork"],
			},
			{
				"name": "fallback_ensure_work",
				"is_fallback": true,
				"subtasks": ["WanderLocal"],
			},
		],
		"DoWorkBlock": [
			{
				"name": "work_while_safe",
				"conditions": {"bell_pending": false},
				"subtasks": ["WanderLocal"],
			},
			{
				"name": "leave_work_when_bell",
				"conditions": {"bell_pending": true},
				"subtasks": ["GoHome"],
			},
			{
				"name": "fallback_work_block",
				"is_fallback": true,
				"subtasks": ["WanderLocal"],
			},
		],
		"EnsureAtHome": [
			{
				"name": "already_at_home",
				"conditions": {"at_home": true},
				"subtasks": [],
			},
			{
				"name": "travel_home",
				"conditions": {"at_home": false},
				"subtasks": ["GoHome"],
			},
			{
				"name": "fallback_ensure_home",
				"is_fallback": true,
				"subtasks": ["WanderLocal"],
			},
		],
		"RestAtHome": [
			{
				"name": "stay_resting",
				"conditions": {"at_home": true},
				"subtasks": [],
			},
			{
				"name": "return_then_rest",
				"conditions": {"at_home": false},
				"subtasks": ["GoHome"],
			},
			{
				"name": "fallback_rest_at_home",
				"is_fallback": true,
				"subtasks": ["WanderLocal"],
			},
		],
		"EnsureAtSocialHub": [
			{
				"name": "already_at_hub",
				"conditions": {"at_social_hub": true},
				"subtasks": [],
			},
			{
				"name": "travel_to_hub",
				"conditions": {"at_social_hub": false},
				"subtasks": ["SocializeAtHub"],
			},
			{
				"name": "fallback_ensure_hub",
				"is_fallback": true,
				"subtasks": ["WanderLocal"],
			},
		],
	}
