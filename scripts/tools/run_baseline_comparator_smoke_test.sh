#!/usr/bin/env bash

set -euo pipefail

THRESHOLD="${1:-1}"

ARTIFACTS_ROOT="$PWD/.artifacts/baseline-comparator"
RUN_ID="$(date +%Y%m%d-%H%M%S)"
WORK_DIR="$ARTIFACTS_ROOT/$RUN_ID"
BASE_EVENTS="$WORK_DIR/input-events-base.ndjson"
NEW_EVENTS="$WORK_DIR/input-events-new.ndjson"
BASELINE_FILE="$WORK_DIR/baseline.ndjson"
CAPTURE_LOG="$WORK_DIR/capture.log"
COMPARE_LOG="$WORK_DIR/compare.log"
EXIT_CODE_FILE="$WORK_DIR/compare-exit-code.txt"

mkdir -p "$WORK_DIR"

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
set +e
godot --headless --path "$PWD" --script scripts/tools/baseline_regression_comparator.gd -- \
  --capture --input "$BASE_EVENTS" --baseline "$BASELINE_FILE" 2>&1 | tee "$CAPTURE_LOG"
CAPTURE_EXIT=${PIPESTATUS[0]}
set -e

if [[ "$CAPTURE_EXIT" -ne 0 ]]; then
  echo
  echo "Capture failed with exit code: $CAPTURE_EXIT"
  echo "See capture log: $CAPTURE_LOG"
  exit "$CAPTURE_EXIT"
fi

echo
echo "Running compare mode (threshold=$THRESHOLD)..."
set +e
godot --headless --path "$PWD" --script scripts/tools/baseline_regression_comparator.gd -- \
  --input "$NEW_EVENTS" --baseline "$BASELINE_FILE" --threshold "$THRESHOLD" 2>&1 | tee "$COMPARE_LOG"
COMPARE_EXIT=${PIPESTATUS[0]}
set -e

echo "$COMPARE_EXIT" > "$EXIT_CODE_FILE"

echo
echo "Compare exit code: $COMPARE_EXIT"
if [[ "$COMPARE_EXIT" -eq 4 ]]; then
  echo "Expected result: divergence exceeded threshold."
else
  echo "Unexpected result: expected exit code 4 for this fixture."
fi

echo
echo "Artifacts directory: $WORK_DIR"
echo "- Base input: $BASE_EVENTS"
echo "- New input: $NEW_EVENTS"
echo "- Baseline: $BASELINE_FILE"
echo "- Capture log: $CAPTURE_LOG"
echo "- Compare log: $COMPARE_LOG"
echo "- Compare exit code: $EXIT_CODE_FILE"
