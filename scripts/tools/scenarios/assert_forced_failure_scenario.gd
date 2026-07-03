## Intentional failing scenario used to validate non-zero assertion exits.

extends RefCounted

const SimAssert = preload("res://scripts/tools/sim_assert.gd")

func on_complete(_runner: Node, _assert_class) -> void:
	SimAssert.assert_equal("expected", "actual", "Forced failure for smoke checks")
