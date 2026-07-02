extends SceneTree

const EXIT_SUCCESS := 0
const EXIT_INVALID_ARGS := 2
const EXIT_RUNTIME_ERROR := 3
const EXIT_DIVERGENCE := 4

func _init() -> void:
	var args := OS.get_cmdline_user_args()
	var parsed := _parse_args(args)
	if not parsed.ok:
		printerr(parsed.error)
		_print_usage()
		quit(EXIT_INVALID_ARGS)
		return

	if parsed.help:
		_print_usage()
		quit(EXIT_SUCCESS)
		return

	var run_result := _run(parsed)
	for line in run_result.messages:
		print(line)

	if not run_result.ok:
		if run_result.has("error"):
			printerr(run_result.error)
		quit(EXIT_RUNTIME_ERROR)
		return

	if run_result.get("diverged", false):
		quit(EXIT_DIVERGENCE)
		return

	quit(EXIT_SUCCESS)

func _parse_args(args: PackedStringArray) -> Dictionary:
	var parsed := {
		"ok": true,
		"help": false,
		"capture": false,
		"input": "",
		"baseline": "",
		"threshold": 0,
	}

	var i := 0
	while i < args.size():
		var arg := String(args[i])
		match arg:
			"--help", "-h":
				parsed.help = true
			"--capture":
				parsed.capture = true
			"--input":
				i += 1
				if i >= args.size():
					return {"ok": false, "error": "Missing value for --input"}
				parsed.input = String(args[i])
			"--baseline":
				i += 1
				if i >= args.size():
					return {"ok": false, "error": "Missing value for --baseline"}
				parsed.baseline = String(args[i])
			"--threshold":
				i += 1
				if i >= args.size():
					return {"ok": false, "error": "Missing value for --threshold"}
				if not String(args[i]).is_valid_int():
					return {"ok": false, "error": "--threshold must be a non-negative integer"}
				parsed.threshold = int(args[i])
				if parsed.threshold < 0:
					return {"ok": false, "error": "--threshold must be >= 0"}
			_:
				return {"ok": false, "error": "Unknown argument: %s" % arg}
		i += 1

	if parsed.help:
		return parsed

	if parsed.input.strip_edges() == "":
		return {"ok": false, "error": "--input is required"}
	if parsed.baseline.strip_edges() == "":
		return {"ok": false, "error": "--baseline is required"}

	return parsed

func _run(parsed: Dictionary) -> Dictionary:
	var input_result := _read_events(parsed.input)
	if not input_result.ok:
		return {
			"ok": false,
			"error": "Failed reading input events (%s): %s" % [parsed.input, input_result.error],
			"messages": [],
		}

	if parsed.capture:
		var capture_result := _write_baseline(parsed.baseline, input_result.raw_lines)
		if not capture_result.ok:
			return {
				"ok": false,
				"error": "Failed writing baseline (%s): %s" % [parsed.baseline, capture_result.error],
				"messages": [],
			}
		return {
			"ok": true,
			"diverged": false,
			"messages": [
				"Capture complete.",
				"Baseline artifact: %s" % parsed.baseline,
				"Events written: %d" % input_result.events.size(),
			],
		}

	var baseline_result := _read_events(parsed.baseline)
	if not baseline_result.ok:
		return {
			"ok": false,
			"error": "Failed reading baseline events (%s): %s" % [parsed.baseline, baseline_result.error],
			"messages": [],
		}

	var comparison := _compare_events(baseline_result.events, input_result.events)
	var divergence_total: int = comparison.added + comparison.removed + comparison.changed
	var diverged := divergence_total > int(parsed.threshold)

	var messages: Array[String] = [
		"Compare complete.",
		"Baseline: %s" % parsed.baseline,
		"Input: %s" % parsed.input,
		"Added events: %d" % comparison.added,
		"Removed events: %d" % comparison.removed,
		"Changed events: %d" % comparison.changed,
		"Total divergence: %d" % divergence_total,
		"Threshold: %d" % int(parsed.threshold),
	]

	if comparison.first_divergence.type != "":
		messages.append(
			"First divergence: type=%s index=%d day=%d hour=%d npc=%s" % [
				comparison.first_divergence.type,
				comparison.first_divergence.index,
				comparison.first_divergence.day,
				comparison.first_divergence.hour,
				comparison.first_divergence.npc_id,
			]
		)
	else:
		messages.append("First divergence: none")

	if diverged:
		messages.append("Result: FAIL (divergence exceeded threshold)")
	else:
		messages.append("Result: PASS")

	return {
		"ok": true,
		"diverged": diverged,
		"messages": messages,
	}

func _read_events(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {
			"ok": false,
			"error": "open error code %d" % FileAccess.get_open_error(),
		}

	var events: Array = []
	var raw_lines: Array[String] = []
	var line_number := 0
	while not file.eof_reached():
		line_number += 1
		var raw_line := file.get_line().strip_edges()
		if raw_line == "":
			continue

		var parsed_json = JSON.parse_string(raw_line)
		if typeof(parsed_json) != TYPE_DICTIONARY:
			file.close()
			return {
				"ok": false,
				"error": "line %d is not a JSON object" % line_number,
			}

		events.append(parsed_json)
		raw_lines.append(raw_line)

	file.close()
	return {
		"ok": true,
		"events": events,
		"raw_lines": raw_lines,
	}

func _write_baseline(path: String, lines: Array[String]) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return {
			"ok": false,
			"error": "open error code %d" % FileAccess.get_open_error(),
		}

	for line in lines:
		file.store_line(line)
	file.close()
	return {"ok": true}

func _compare_events(baseline_events: Array, input_events: Array) -> Dictionary:
	var added := 0
	var removed := 0
	var changed := 0
	var first_divergence := {
		"type": "",
		"index": -1,
		"day": -1,
		"hour": -1,
		"npc_id": "<unknown>",
	}

	var max_count := maxi(baseline_events.size(), input_events.size())
	for idx in range(max_count):
		if idx >= baseline_events.size():
			added += 1
			if first_divergence.type == "":
				first_divergence = _first_divergence_payload("added", idx, input_events[idx])
			continue

		if idx >= input_events.size():
			removed += 1
			if first_divergence.type == "":
				first_divergence = _first_divergence_payload("removed", idx, baseline_events[idx])
			continue

		if not _events_equal(baseline_events[idx], input_events[idx]):
			changed += 1
			if first_divergence.type == "":
				first_divergence = _first_divergence_payload("changed", idx, input_events[idx])

	return {
		"added": added,
		"removed": removed,
		"changed": changed,
		"first_divergence": first_divergence,
	}

func _events_equal(a: Dictionary, b: Dictionary) -> bool:
	if a.size() != b.size():
		return false
	for key in a.keys():
		if not b.has(key):
			return false
		if a[key] != b[key]:
			return false
	return true

func _first_divergence_payload(kind: String, idx: int, event: Dictionary) -> Dictionary:
	return {
		"type": kind,
		"index": idx,
		"day": int(event.get("day", -1)),
		"hour": int(event.get("hour", -1)),
		"npc_id": str(event.get("npc_id", "<unknown>")),
	}

func _print_usage() -> void:
	print("Usage:")
	print("  godot --headless --script scripts/tools/baseline_regression_comparator.gd -- --input <events.ndjson> --baseline <baseline.ndjson> [--threshold <n>]")
	print("  godot --headless --script scripts/tools/baseline_regression_comparator.gd -- --capture --input <events.ndjson> --baseline <named-baseline.ndjson>")