# GameManager.gd
# Gerencia o estado global do jogo: nível, XP, tempo, upgrades aplicados.
# É um Autoload (singleton) acessível de qualquer cena.
extends Node

# --- Sinais ---
signal xp_changed(current_xp: int, xp_to_next: int)
signal level_up(new_level: int)
signal game_over(survived_time: float)
signal enemy_killed(total_kills: int)
signal temporary_powerup_changed(powerup_id: String, remaining: float)

# --- Estado do Jogo ---
var current_level: int = 1
var current_xp: int = 0
var xp_to_next_level: int = 100
var survived_time: float = 0.0
var is_game_running: bool = false
var total_kills: int = 0

var active_powerups: Dictionary = {}
var powerup_effects: Dictionary = {
	"damage_mult": 1.0,
	"cooldown_mult": 1.0,
	"speed_mult": 1.0,
	"invincible": false,
	"weapon_override": ""
}

# --- Stats do Player (modificadas por upgrades) ---
var player_stats: Dictionary = {
	"max_hp": 100,
	"speed": 200.0,
	"damage": 20.0,
	"attack_range": 120.0,
	"attack_cooldown": 1.5,
	"projectile_count": 1,
	"projectile_speed_mult": 1.0,
	"pierce_count": 0,
	"radial_shot_count": 0,
	"crit_explosion_radius": 0.0,
	"chaos_shot_chance": 0.0,
	"player_scale": 1.0,
	"mutation_power": 0,
	"weapon_mode": "projectile",
	"void_orbitals": 0,
	"quantum_brain": 0,
	"crit_chance": 0.1,  # 10% de chance de crítico
	"crit_multiplier": 2.0,  # Dano crítico = 2x
	"lifesteal": 0.0,  # % de vida roubada por dano
}

# Sistema de combo
var combo_count: int = 0
var combo_timer: float = 0.0
var combo_timeout: float = 3.0  # Combo reseta após 3s sem matar

# Referência ao player (setada pela cena Main)
var player_ref: Node = null

func _has_property(target: Object, property_name: String) -> bool:
	if target == null:
		return false
	for property in target.get_property_list():
		if property.get("name", "") == property_name:
			return true
	return false

func _ready() -> void:
	reset_game()

func reset_game() -> void:
	"""Reseta todos os valores para uma nova partida."""
	current_level = 1
	current_xp = 0
	xp_to_next_level = 100
	survived_time = 0.0
	is_game_running = false
	combo_count = 0
	combo_timer = 0.0
	total_kills = 0
	active_powerups.clear()
	powerup_effects = {
		"damage_mult": 1.0,
		"cooldown_mult": 1.0,
		"speed_mult": 1.0,
		"invincible": false,
		"weapon_override": ""
	}
	player_stats = {
		"max_hp": 100,
		"speed": 200.0,
		"damage": 20.0,
		"attack_range": 120.0,
		"attack_cooldown": 1.5,
		"projectile_count": 1,
		"projectile_speed_mult": 1.0,
		"pierce_count": 0,
		"radial_shot_count": 0,
		"crit_explosion_radius": 0.0,
		"chaos_shot_chance": 0.0,
		"player_scale": 1.0,
		"mutation_power": 0,
		"weapon_mode": "projectile",
		"void_orbitals": 0,
		"quantum_brain": 0,
		"crit_chance": 0.1,
		"crit_multiplier": 2.0,
		"lifesteal": 0.0,
	}

	if MetaProgress:
		MetaProgress.start_run()
		var bonus: Dictionary = MetaProgress.get_meta_bonuses()
		player_stats["max_hp"] += int(bonus.get("max_hp", 0))
		player_stats["damage"] += float(bonus.get("damage", 0.0))
		player_stats["speed"] += float(bonus.get("speed", 0.0))
		player_stats["attack_cooldown"] = max(0.22, player_stats["attack_cooldown"] - float(bonus.get("attack_cooldown_reduction", 0.0)))

	if AchievementSystem:
		AchievementSystem.start_run()

func _process(delta: float) -> void:
	if is_game_running:
		survived_time += delta
		_process_powerups(delta)
		# Atualiza timer de combo
		if combo_count > 0:
			combo_timer -= delta
			if combo_timer <= 0:
				combo_count = 0

func _process_powerups(delta: float) -> void:
	if active_powerups.is_empty():
		return
	var expired: Array[String] = []
	for id in active_powerups.keys():
		active_powerups[id] = max(0.0, float(active_powerups[id]) - delta)
		emit_signal("temporary_powerup_changed", id, float(active_powerups[id]))
		if float(active_powerups[id]) <= 0.0:
			expired.append(id)
	for id in expired:
		active_powerups.erase(id)
	_recalculate_powerup_effects()

func add_xp(amount: int) -> void:
	"""Adiciona XP e verifica se houve level up."""
	# Bonus de combo
	var bonus_mult: float = 1.0 + (combo_count * 0.05)  # +5% por combo
	var final_amount: int = int(amount * bonus_mult)
	
	current_xp += final_amount
	emit_signal("xp_changed", current_xp, xp_to_next_level)
	
	# Incrementa combo
	combo_count += 1
	combo_timer = combo_timeout
	
	if current_xp >= xp_to_next_level:
		_level_up()

func _level_up() -> void:
	"""Processa o level up do player."""
	current_xp -= xp_to_next_level
	current_level += 1
	# XP necessário cresce 20% por nível
	xp_to_next_level = int(xp_to_next_level * 1.2)
	
	# Efeito visual de level up
	if player_ref:
		PixelEffects.spawn_level_up_effect(player_ref.global_position)
	if AudioManager:
		AudioManager.play_level_up()
	
	emit_signal("level_up", current_level)
	emit_signal("xp_changed", current_xp, xp_to_next_level)

func trigger_game_over() -> void:
	"""Dispara o evento de game over."""
	is_game_running = false
	if MetaProgress:
		MetaProgress.finalize_run()
	if AchievementSystem:
		AchievementSystem.on_game_over(survived_time)
	if AudioManager:
		AudioManager.play_game_over()
	emit_signal("game_over", survived_time)

func register_enemy_kill(xp_reward: int, enemy_kind: String = "normal") -> void:
	total_kills += 1
	emit_signal("enemy_killed", total_kills)
	add_xp(xp_reward)

	if MetaProgress:
		var gold_gain: int = 4
		match enemy_kind:
			"fast":
				gold_gain = 5
			"tank":
				gold_gain = 7
			"elite":
				gold_gain = 14
			"warlock":
				gold_gain = 16
			"boss":
				gold_gain = 40
		MetaProgress.add_run_gold(gold_gain)

	if AchievementSystem:
		AchievementSystem.on_enemy_killed(total_kills, enemy_kind)

func apply_temporary_powerup(powerup_id: String, duration: float) -> void:
	if duration <= 0.0:
		return
	active_powerups[powerup_id] = max(duration, float(active_powerups.get(powerup_id, 0.0)))
	_recalculate_powerup_effects()
	emit_signal("temporary_powerup_changed", powerup_id, float(active_powerups[powerup_id]))

	var notifications = get_tree().get_first_node_in_group("notifications")
	if notifications and notifications.has_method("show_notification"):
		var title := "POWER-UP"
		match powerup_id:
			"frenzy":
				title = "FRENESI DE ATAQUE"
			"shield":
				title = "ESCUDO ARCANO"
			"haste":
				title = "VELOCIDADE SOMBRIA"
			"sword_mode":
				title = "ESPADA ETÉREA"
			"magic_mode":
				title = "TEMPESTADE MÁGICA"
		notifications.show_notification(title, "⚡", Color(0.55, 0.95, 1.0), 1.8)

func _recalculate_powerup_effects() -> void:
	powerup_effects = {
		"damage_mult": 1.0,
		"cooldown_mult": 1.0,
		"speed_mult": 1.0,
		"invincible": false,
		"weapon_override": ""
	}

	if active_powerups.has("frenzy"):
		powerup_effects["damage_mult"] = 1.45
		powerup_effects["cooldown_mult"] = 0.6
	if active_powerups.has("haste"):
		powerup_effects["speed_mult"] = 1.5
	if active_powerups.has("shield"):
		powerup_effects["invincible"] = true
	if active_powerups.has("sword_mode"):
		powerup_effects["weapon_override"] = "sword"
	elif active_powerups.has("magic_mode"):
		powerup_effects["weapon_override"] = "magic"

func get_effective_damage() -> float:
	return float(player_stats["damage"]) * float(powerup_effects.get("damage_mult", 1.0))

func get_effective_cooldown() -> float:
	return max(0.12, float(player_stats["attack_cooldown"]) * float(powerup_effects.get("cooldown_mult", 1.0)))

func get_effective_speed() -> float:
	return float(player_stats["speed"]) * float(powerup_effects.get("speed_mult", 1.0))

func is_temp_invincible() -> bool:
	return bool(powerup_effects.get("invincible", false))

func get_current_weapon_mode() -> String:
	var override_mode: String = String(powerup_effects.get("weapon_override", ""))
	if not override_mode.is_empty():
		return override_mode
	return String(player_stats.get("weapon_mode", "projectile"))

func apply_upgrade(upgrade_id: String) -> void:
	"""Aplica um upgrade ao player stats."""
	match upgrade_id:
		"damage_up":
			player_stats["damage"] += 10.0
		"speed_up":
			player_stats["speed"] += 30.0
		"range_up":
			player_stats["attack_range"] += 30.0
		"cooldown_down":
			player_stats["attack_cooldown"] = max(0.3, player_stats["attack_cooldown"] - 0.2)
		"hp_up":
			player_stats["max_hp"] += 25
			# Cura o player ao ganhar mais HP máximo
			if player_ref and player_ref.has_method("heal"):
				player_ref.heal(25)
		"multishot":
			player_stats["projectile_count"] += 1
		"crit_up":
			player_stats["crit_chance"] = min(0.75, player_stats["crit_chance"] + 0.1)
		"crit_damage_up":
			player_stats["crit_multiplier"] += 0.5
		"lifesteal_up":
			player_stats["lifesteal"] = min(0.5, player_stats["lifesteal"] + 0.1)
		"dash_upgrade":
			if player_ref and _has_property(player_ref, "dash_cooldown"):
				player_ref.dash_cooldown = max(0.3, player_ref.dash_cooldown - 0.3)
		"arcane_nova":
			player_stats["radial_shot_count"] += 4
		"pierce_rounds":
			player_stats["pierce_count"] += 1
		"crit_explosion":
			player_stats["crit_explosion_radius"] = min(140.0, player_stats["crit_explosion_radius"] + 35.0)
		"hyper_projectile":
			player_stats["projectile_speed_mult"] = min(3.0, player_stats["projectile_speed_mult"] + 0.65)
			player_stats["attack_range"] += 20.0
		"mutant_horns":
			player_stats["damage"] += 14.0
			player_stats["crit_chance"] = min(0.9, player_stats["crit_chance"] + 0.12)
			player_stats["mutation_power"] += 1
		"demon_baby":
			player_stats["chaos_shot_chance"] = min(0.7, player_stats["chaos_shot_chance"] + 0.22)
			player_stats["projectile_speed_mult"] += 0.2
			player_stats["mutation_power"] += 1
		"giant_form":
			player_stats["max_hp"] += 45
			player_stats["damage"] += 10.0
			player_stats["speed"] = max(130.0, player_stats["speed"] - 18.0)
			player_stats["player_scale"] = min(1.35, player_stats["player_scale"] + 0.12)
			player_stats["mutation_power"] += 1
		"tiny_terror":
			player_stats["speed"] += 35.0
			player_stats["attack_cooldown"] = max(0.2, player_stats["attack_cooldown"] - 0.08)
			player_stats["player_scale"] = max(0.72, player_stats["player_scale"] - 0.1)
			player_stats["mutation_power"] += 1
		"void_orbit":
			player_stats["void_orbitals"] += 2
			player_stats["mutation_power"] += 1
		"quantum_brain":
			player_stats["quantum_brain"] += 1
			player_stats["chaos_shot_chance"] = min(0.85, player_stats["chaos_shot_chance"] + 0.15)
			player_stats["attack_cooldown"] = max(0.2, player_stats["attack_cooldown"] - 0.1)
			player_stats["crit_explosion_radius"] += 20.0
			player_stats["mutation_power"] += 1
		"weapon_sword":
			player_stats["weapon_mode"] = "sword"
		"weapon_magic":
			player_stats["weapon_mode"] = "magic"
	
	# Notifica o player para atualizar seus stats
	if player_ref and player_ref.has_method("update_stats"):
		player_ref.update_stats()

func calculate_damage(base_damage: float) -> Dictionary:
	"""Calcula dano com chance de crítico."""
	var is_crit: bool = randf() < player_stats["crit_chance"]
	var final_damage: float = base_damage
	
	if is_crit:
		final_damage *= player_stats["crit_multiplier"]
	
	return {"damage": final_damage, "is_crit": is_crit}

func apply_lifesteal(damage: float) -> void:
	"""Aplica roubo de vida baseado no dano causado."""
	if player_stats["lifesteal"] > 0 and player_ref and player_ref.has_method("heal"):
		var heal_amount: int = int(damage * player_stats["lifesteal"])
		if heal_amount > 0:
			player_ref.heal(heal_amount)

func get_survived_time_string() -> String:
	"""Retorna o tempo sobrevivido formatado como MM:SS."""
	var minutes: int = int(survived_time) / 60
	var seconds: int = int(survived_time) % 60
	return "%02d:%02d" % [minutes, seconds]
