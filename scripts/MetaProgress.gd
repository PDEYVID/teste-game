extends Node

signal gold_changed(run_gold: int, total_gold: int)
signal meta_level_changed(new_level: int)

const SAVE_PATH := "user://meta_progress.save"

var total_gold: int = 0
var run_gold: int = 0
var last_run_gold: int = 0
var meta_level: int = 0

func _ready() -> void:
	_load_data()

func start_run() -> void:
	run_gold = 0
	emit_signal("gold_changed", run_gold, total_gold)

func add_run_gold(amount: int) -> void:
	if amount <= 0:
		return
	run_gold += amount
	emit_signal("gold_changed", run_gold, total_gold)

func finalize_run() -> void:
	last_run_gold = run_gold
	if run_gold > 0:
		total_gold += run_gold
	run_gold = 0
	_recalculate_meta_level()
	_save_data()
	emit_signal("gold_changed", run_gold, total_gold)

func get_meta_bonuses() -> Dictionary:
	return {
		"max_hp": meta_level * 4,
		"damage": float(meta_level) * 1.6,
		"speed": float(meta_level) * 2.8,
		"attack_cooldown_reduction": float(meta_level) * 0.015
	}

func _recalculate_meta_level() -> void:
	var new_level: int = int(total_gold / 220)
	if new_level != meta_level:
		meta_level = new_level
		emit_signal("meta_level_changed", meta_level)

func _load_data() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	var data: Dictionary = parsed
	total_gold = int(data.get("total_gold", 0))
	meta_level = int(data.get("meta_level", 0))
	run_gold = 0

func _save_data() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return
	var data := {
		"total_gold": total_gold,
		"meta_level": meta_level
	}
	file.store_string(JSON.stringify(data))
