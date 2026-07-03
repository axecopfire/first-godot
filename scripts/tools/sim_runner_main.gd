## Headless simulation runner entry point for Godot CLI.
##
## This script serves as the MainLoop entry point for `godot --headless --script sim_runner_main.gd`
## It initializes and runs the simulation harness.

extends MainLoop

var sim_runner: Node = null
var should_exit: bool = false
var exit_code: int = 0
var frame_count: int = 0

func _initialize() -> void:
	print("[SimRunnerMain] Initializing MainLoop...")
	# Load and create the simulator
	var SimRunnerClass = preload("res://scripts/tools/sim_runner.gd")
	sim_runner = SimRunnerClass.new()

func _process(delta: float) -> bool:
	# Run simulation on first frame
	if frame_count == 0:
		print("[SimRunnerMain] Starting simulation run...")
		_run_simulation()
	
	frame_count += 1
	
	# Exit after one frame
	return true

func _run_simulation() -> void:
	if sim_runner:
		# Parse arguments
		sim_runner._parse_command_line_arguments()
		
		# Run simulation
		sim_runner._initialize_simulation()
		sim_runner._run_simulation()
		sim_runner._finalize_simulation()
		
		# Check for assertion failures
		var SimAssertClass = preload("res://scripts/tools/sim_assert.gd")
		if SimAssertClass.get_failed_count() > 0:
			exit_code = 1
		else:
			exit_code = 0
		
		print("[SimRunnerMain] Simulation complete, exiting...")
		sim_runner.free()
		sim_runner = null


