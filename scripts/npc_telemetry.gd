## NpcTelemetry
## AutoLoad singleton that writes NPC decision events to an NDJSON file.
## One JSON object per line; each line is a complete, self-describing event.
##
## Output path: user://npc_decisions.ndjson
## Flush behavior: immediate per-event (safe for crash-recovery and streaming).
extends Node

const OUTPUT_PATH := "user://npc_decisions.ndjson"

var _file: FileAccess = null
var _enabled := true

func _ready() -> void:
	_file = FileAccess.open(OUTPUT_PATH, FileAccess.WRITE)
	if _file == null:
		push_warning("NpcTelemetry: could not open %s for writing (error %d)" % [
			OUTPUT_PATH, FileAccess.get_open_error()
		])
		_enabled = false

## Append one decision event as an NDJSON line.
## Expected keys: npc_id, profession, day, hour, active_goal, routine, trigger, rationale.
func log_decision(event: Dictionary) -> void:
	if not _enabled or _file == null:
		return
	_file.store_line(JSON.stringify(event))
	_file.flush()

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		_close()

func _close() -> void:
	if _file != null:
		_file.flush()
		_file.close()
		_file = null
