extends Node

signal achievement_unlocked(id: String, title: String)

const SAVE_PATH := "user://achievements.save"

const ACHIEVEMENTS := {
	"first_blood": {
		"title": "Primeiro Sangue",
		"desc": "Derrote 1 inimigo"
	},
	"slayer_200": {
		"title": "Aniquilador",
		"desc": "Derrote 200 inimigos em uma run"
	},
	"survivor_5m": {
		"title": "Sobrevivente",
		"desc": "Sobreviva por 5 minutos"
	},
	"rich_500": {
		"title": "Bolso Cheio",
		"desc": "Acumule 500 de ouro total"
	},
	"mutant_master": {
		"title": "Mutação Máxima",
		"desc": "Alcance 4+ de mutação"
	},
	"elite_hunter": {
		"title": "Caçador de Elite",
		"desc": "Derrote 15 elites"
	}
}

var unlocked: Dictionary = {}
var run_elite_kills: int = 0

func _ready() -> void:
	_load_data()

func start_run() -> void:
	run_elite_kills = 0

func on_enemy_killed(total_kills: int, enemy_kind: String) -> void:
	if total_kills >= 1:
		_unlock("first_blood")
	if total_kills >= 200:
		_unlock("slayer_200")
	if enemy_kind == "elite":
		run_elite_kills += 1
		if run_elite_kills >= 15:
			_unlock("elite_hunter")

func on_game_over(survived_time: float) -> void:
	if survived_time >= 300.0:
		_unlock("survivor_5m")
	if MetaProgress.total_gold >= 500:
		_unlock("rich_500")
	if int(GameManager.player_stats.get("mutation_power", 0)) >= 4:
		_unlock("mutant_master")

func is_unlocked(id: String) -> bool:
	return bool(unlocked.get(id, false))

func get_completion_count() -> int:
	var count: int = 0
	for id in ACHIEVEMENTS.keys():
		if is_unlocked(id):
			count += 1
	return count

func get_total_count() -> int:
	return ACHIEVEMENTS.size()

func _unlock(id: String) -> void:
	if not ACHIEVEMENTS.has(id):
		return
	if is_unlocked(id):
		return
	unlocked[id] = true
	_save_data()
	var title: String = String(ACHIEVEMENTS[id].get("title", id))
	emit_signal("achievement_unlocked", id, title)

	var notifications = get_tree().get_first_node_in_group("notifications")
	if notifications and notifications.has_method("notify_achievement"):
		notifications.notify_achievement("Conquista: %s" % title)
	if AudioManager:
		AudioManager.play_level_up()

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
	var unlocked_data = data.get("unlocked", {})
	if typeof(unlocked_data) == TYPE_DICTIONARY:
		unlocked = unlocked_data

func _save_data() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return
	var data := {
		"unlocked": unlocked
	}
	file.store_string(JSON.stringify(data))
