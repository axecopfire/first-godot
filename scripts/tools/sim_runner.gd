## Headless day-cycle simulation harness.
##
## Run via: godot --headless --script scripts/tools/sim_runner.gd [OPTIONS]
##
## Options:
##   --seed <seed>              Random seed for reproducibility
##   --day-count <count>        Number of in-game days to simulate
##   --config <path>            JSON config file with roster, world state, etc.
##   --output <path>            Write NDJSON output to file (default: stdout)
##   --interactive              Pause at each decision event
##   --capture <baseline>       Save output to baseline file
##   --compare <baseline>       Compare output against baseline (default)

extends Node

class_name SimRunner

# Preload class definitions for headless context
const WorldStateManagerClass = preload("res://scripts/world/world_state_manager.gd")
const SimAssertClass = preload("res://scripts/tools/sim_assert.gd")
const ScheduleConfigClass = preload("res://scripts/schedule_config.gd")
const NpcBrainClass = preload("res://scripts/npc_brain.gd")

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

var config: Dictionary = {
	"seed": 42,
	"day_count": 1,
	"npc_roster": ["baker", "blacksmith", "herbalist"],
	"world_state": {},
	"output_file": null,  # null means stdout
	"interactive_mode": false,
	"baseline_mode": null,  # "capture" or "compare"
	"baseline_file": null,
}

var output_file: FileAccess = null
var decision_events: Array = []
var frame_count: int = 0
var simulation_running: bool = false

# World components
var world_state: Node = null  # WorldStateManager instance
var npcs: Dictionary = {}

# ---------------------------------------------------------------------------
# Entry Point
# ---------------------------------------------------------------------------

func _ready() -> void:
	print("[SimRunner] Starting headless simulation...")
	_parse_command_line_arguments()
	_initialize_simulation()
	_run_simulation()
	_finalize_simulation()
	if get_tree():
		get_tree().quit(0)

# ---------------------------------------------------------------------------
# Configuration and Setup
# ---------------------------------------------------------------------------

func _parse_command_line_arguments() -> void:
	var args = OS.get_cmdline_args()
	var i = 0
	
	while i < args.size():
		var arg = args[i]
		
		match arg:
			"--seed":
				i += 1
				if i < args.size():
					config.seed = int(args[i])
			"--day-count":
				i += 1
				if i < args.size():
					config.day_count = int(args[i])
			"--config":
				i += 1
				if i < args.size():
					_load_json_config(args[i])
			"--output":
				i += 1
				if i < args.size():
					config.output_file = args[i]
			"--interactive":
				config.interactive_mode = true
			"--capture":
				i += 1
				if i < args.size():
					config.baseline_mode = "capture"
					config.baseline_file = args[i]
			"--compare":
				i += 1
				if i < args.size():
					config.baseline_mode = "compare"
					config.baseline_file = args[i]
			_:
				if arg.begins_with("--"):
					print("[SimRunner] Unknown argument: %s" % arg)
		
		i += 1

func _load_json_config(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		print("[SimRunner] ERROR: Could not open config file: %s" % path)
		return
	
	var json = JSON.parse_string(file.get_as_text())
	if json is Dictionary:
		config.merge(json, true)
		print("[SimRunner] Loaded config from %s" % path)
	else:
		print("[SimRunner] ERROR: Invalid JSON in config file: %s" % path)

func _setup_output_stream() -> void:
	if config.output_file:
		var file = FileAccess.open(config.output_file, FileAccess.WRITE)
		if file:
			output_file = file
			print("[SimRunner] Writing output to: %s" % config.output_file)
		else:
			print("[SimRunner] WARNING: Could not open output file, using stdout")
	# If no file, we write to stdout via print()

# ---------------------------------------------------------------------------
# Simulation Control
# ---------------------------------------------------------------------------

func _initialize_simulation() -> void:
	print("[SimRunner] Initializing simulation with seed: %d" % config.seed)
	_setup_output_stream()
	
	seed(config.seed)
	
	# Create world state
	world_state = WorldStateManagerClass.new()
	print("[SimRunner] WorldStateManager created")
	
	# Stub spatial services
	_stub_spatial_services()
	
	# Create and configure NPCs
	_spawn_npcs_for_simulation()
	
	# Apply initial world state overrides
	if config.world_state.has("day_number"):
		world_state.day_number = config.world_state.day_number
	if config.world_state.has("start_hour"):
		world_state.set_time_to_hour(config.world_state.start_hour)
	
	print("[SimRunner] Simulation initialized with %d NPCs" % npcs.size())

func _spawn_npcs_for_simulation() -> void:
	var social_hub_pos = Vector2(10, 10)  # Default; can be overridden
	
	for profession in config.npc_roster:
		var npc_id = "%s_%d" % [profession, npcs.size() + 1]
		var brain = NpcBrainClass.new(config.seed + npcs.size())
		var work_hours = ScheduleConfigClass.get_npc_work_hours(profession)
		
		npcs[npc_id] = {
			"id": npc_id,
			"profession": profession,
			"brain": brain,
			"position": social_hub_pos,  # Start at social hub
			"home_position": Vector2(5, 5),
			"work_position": Vector2(15, 15),
			"morning_hour": work_hours.morning_hour,
			"evening_hour": work_hours.evening_hour,
			"last_decision": {},
			"decision_history": [],
		}
		print("[SimRunner] Spawned NPC: %s (%s)" % [npc_id, profession])

func _stub_spatial_services() -> void:
	# Stub out spatial queries and movement so NPCs don't need a scene tree.
	# This allows npc_brain.gd and schedule_config.gd to import and run.
	print("[SimRunner] Stubbing spatial services...")
	
	# TODO: Add stubs for Physics2D.space_state queries, path finding, etc.

func _run_simulation() -> void:
	simulation_running = true
	print("[SimRunner] Starting simulation for %d day(s)..." % config.day_count)
	
	var total_seconds = config.day_count * world_state.DAY_DURATION_SECONDS
	var elapsed = 0.0
	var frame_delta = 0.016  # ~60 fps
	
	while elapsed < total_seconds and simulation_running:
		elapsed += frame_delta
		frame_count += 1
		_tick_frame(frame_delta)
	
	print("[SimRunner] Simulation complete: %d frames, %.1f seconds simulated" % [frame_count, elapsed])

func _tick_frame(delta: float) -> void:
	# Advance world state
	world_state.tick(delta)
	
	# Update each NPC
	for npc_id in npcs:
		var npc_data = npcs[npc_id]
		_update_npc_brain(npc_data)

func _update_npc_brain(npc_brain) -> void:
	# Call the brain's decision loop and capture decision events.
	var npc_data = npc_brain
	var cycle_progress = world_state.get_cycle_progress()
	var current_hour = world_state.get_current_hour()
	
	var decision = npc_data.brain.tick(
		0.016,  # delta (60 fps)
		cycle_progress,
		npc_data.position,
		npc_data.home_position,
		npc_data.work_position,
		npc_data.morning_hour,
		npc_data.evening_hour,
		world_state.get_world_state(Vector2(10, 10)),
		false,  # is_player_nearby
		false   # has_friendly_tie
	)
	
	# Emit decision event if this is a new decision
	if decision.get("new_decision", false):
		var event = {
			"day": world_state.day_number,
			"hour": current_hour,
			"npc_id": npc_data.id,
			"profession": npc_data.profession,
			"active_goal": decision.get("goal", ""),
			"trigger": decision.get("trigger", ""),
			"action": decision.get("action", ""),
			"reason": decision.get("reason", ""),
			"goal_score": 0.0,  # TODO: Extract from brain if available
			"challenger_score": 0.0,  # TODO: Extract from brain if available
		}
		emit_decision_event(event)
		npc_data.last_decision = decision
		npc_data.decision_history.append(event)

func _finalize_simulation() -> void:
	print("[SimRunner] Finalizing simulation...")
	
	if config.baseline_mode == "capture":
		_save_baseline(config.baseline_file)
		print("[SimRunner] Baseline captured to: %s" % config.baseline_file)
	elif config.baseline_mode == "compare":
		_compare_baseline(config.baseline_file)
	
	# Flush and close output
	if output_file:
		output_file.close()
		output_file = null
	
	# Clear NPC references so RefCounted brains are released
	npcs.clear()
	
	# Free world state node (extends Node, requires explicit free in headless)
	if world_state and is_instance_valid(world_state):
		world_state.free()
		world_state = null

# ---------------------------------------------------------------------------
# Decision Event Handling (NDJSON)
# ---------------------------------------------------------------------------

func emit_decision_event(event: Dictionary) -> void:
	## Emit a decision event as NDJSON.
	## Expected fields:
	##   - day: int
	##   - hour: int
	##   - npc_id: string
	##   - profession: string
	##   - active_goal: string
	##   - trigger: string
	##   - htn_root: string (optional)
	##   - method: string (optional)
	##   - primitive_sequence: array (optional)
	##   - goal_score: float
	##   - challenger_score: float
	##   - hysteresis_decision: bool
	
	var ndjson = JSON.stringify(event)
	decision_events.append(event)
	
	if output_file:
		output_file.store_line(ndjson)
	else:
		print(ndjson)
	
	if config.interactive_mode:
		_print_decision_summary(event)
		_wait_for_input()

func _print_decision_summary(event: Dictionary) -> void:
	var summary = "[Day %d, Hour %d] NPC: %s (%s)\n" % [
		event.day,
		event.hour,
		event.npc_id,
		event.profession
	]
	summary += "  Goal: %s | Score: %.2f vs %.2f | Trigger: %s\n" % [
		event.active_goal,
		event.goal_score,
		event.challenger_score,
		event.trigger
	]
	
	if event.has("method"):
		summary += "  HTN Method: %s\n" % event.method
	if event.has("primitive_sequence"):
		summary += "  Primitives: %s\n" % str(event.primitive_sequence)
	
	print(summary)

func _wait_for_input() -> void:
	print("  [Press Enter to continue...]")
	# In a headless context, we can read stdin
	var line = ""
	# TODO: Implement non-blocking stdin read or use OS.get_process_result()

# ---------------------------------------------------------------------------
# Baseline Capture and Comparison
# ---------------------------------------------------------------------------

func _save_baseline(path: String) -> void:
	var baseline_data = {
		"metadata": {
			"version": 1,
			"seed": config.seed,
			"day_count": config.day_count,
			"npc_roster": config.npc_roster,
			"event_count": decision_events.size(),
		},
		"events": decision_events,
	}
	
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_var(baseline_data)
		print("[SimRunner] Saved baseline: %d events" % decision_events.size())

func _compare_baseline(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		print("[SimRunner] ERROR: Baseline file not found: %s" % path)
		return
	
	var baseline_data = file.get_var()
	var baseline_events = baseline_data.get("events", [])
	
	if baseline_events.size() != decision_events.size():
		print("[SimRunner] DIVERGENCE: Event count mismatch: %d vs %d" % [decision_events.size(), baseline_events.size()])
		return
	
	for i in range(decision_events.size()):
		var current = decision_events[i]
		var expected = baseline_events[i]
		
		if _dict_differs(current, expected):
			print("[SimRunner] DIVERGENCE at event %d:" % i)
			_print_dict_diff(current, expected)

func _dict_differs(a: Dictionary, b: Dictionary) -> bool:
	for key in a:
		if a[key] != b.get(key):
			return true
	for key in b:
		if not a.has(key):
			return true
	return false

func _print_dict_diff(current: Dictionary, expected: Dictionary) -> void:
	var diff = []
	for key in expected:
		if expected[key] != current.get(key):
			diff.append("  %s: %s -> %s" % [key, expected[key], current.get(key)])
	for key in current:
		if not expected.has(key):
			diff.append("  %s: (new) %s" % [key, current[key]])
	
	if diff.size() > 0:
		print("\n".join(diff))

