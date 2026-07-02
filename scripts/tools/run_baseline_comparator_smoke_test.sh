#!/usr/bin/env bash

set -euo pipefail

GODOT_PATH="${GODOT_PATH:-/Applications/Godot.app/Contents/MacOS/Godot}"
THRESHOLD="${1:-1}"

if [[ ! -x "$GODOT_PATH" ]]; then
  echo "Error: Godot executable not found at $GODOT_PATH"
  echo "Set GODOT_PATH to your Godot binary path and try again."
  exit 1
fi

WORK_DIR="$(mktemp -d)"
BASE_EVENTS="$WORK_DIR/events_base.ndjson"
NEW_EVENTS="$WORK_DIR/events_new.ndjson"
BASELINE_FILE="$WORK_DIR/a2-baseline.ndjson"

cleanup() {
  rm -rf "$WORK_DIR"
}
trap cleanup EXIT

cat >"$BASE_EVENTS" <<'EOF'
{"npc_id":"Amina","profession":"Baker","day":1,"hour":8,"active_goal":"work","routine":"go_to_work","trigger":"day_start","rationale":"schedule_window"}
{"npc_id":"Yusuf","profession":"Merchant","day":1,"hour":9,"active_goal":"trade","routine":"stay_market","trigger":"cooldown_expired","rationale":"keep_presence"}
EOF

cat >"$NEW_EVENTS" <<'EOF'
{"npc_id":"Amina","profession":"Baker","day":1,"hour":8,"active_goal":"work","routine":"go_to_work","trigger":"day_start","rationale":"schedule_window"}
{"npc_id":"Yusuf","profession":"Merchant","day":1,"hour":10,"active_goal":"trade","routine":"stay_market","trigger":"cooldown_expired","rationale":"keep_presence"}
{"npc_id":"Nura","profession":"Clerk","day":1,"hour":11,"active_goal":"patrol_info","routine":"observe","trigger":"event","rationale":"new_task"}
EOF

echo "Running capture mode..."
"$GODOT_PATH" --headless --path "$PWD" --script scripts/tools/baseline_regression_comparator.gd -- \
  --capture --input "$BASE_EVENTS" --baseline "$BASELINE_FILE"

echo
echo "Running compare mode (threshold=$THRESHOLD)..."
set +e
"$GODOT_PATH" --headless --path "$PWD" --script scripts/tools/baseline_regression_comparator.gd -- \
  --input "$NEW_EVENTS" --baseline "$BASELINE_FILE" --threshold "$THRESHOLD"
COMPARE_EXIT=$?
set -e

echo
echo "Compare exit code: $COMPARE_EXIT"
if [[ "$COMPARE_EXIT" -eq 4 ]]; then
  echo "Expected result: divergence exceeded threshold."
else
  echo "Unexpected result: expected exit code 4 for this fixture."
fi
