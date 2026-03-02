# WeaponSystem.gd
# Sistema de ataque automático do player.
# Encontra o inimigo mais próximo e dispara projéteis em intervalo fixo.
# Separado do Player.gd para manter responsabilidades claras.
extends Node2D

# --- Referências ---
@onready var attack_timer: Timer = $AttackTimer
@onready var attack_area: Area2D = $AttackArea

# Cena do projétil
const PROJECTILE_SCENE = preload("res://scenes/Projectile.tscn")

func _ready() -> void:
	# Configura o timer com o cooldown do GameManager
	_update_timer()
	attack_timer.timeout.connect(_on_attack_timer_timeout)

func _update_timer() -> void:
	"""Atualiza o intervalo de ataque baseado nos stats atuais."""
	attack_timer.wait_time = GameManager.get_effective_cooldown()

func _on_attack_timer_timeout() -> void:
	"""Chamado pelo timer: dispara ataques."""
	attack_timer.wait_time = GameManager.get_effective_cooldown()
	var enemies: Array = _get_enemies_in_range()
	var radial_shot_count: int = int(GameManager.player_stats.get("radial_shot_count", 0))
	if enemies.is_empty() and radial_shot_count <= 0 and GameManager.get_current_weapon_mode() != "magic":
		return

	var weapon_mode: String = GameManager.get_current_weapon_mode()
	if weapon_mode == "sword":
		_sword_attack(enemies)
		return
	if weapon_mode == "magic":
		_magic_attack(enemies)
		return
	
	var projectile_count: int = GameManager.player_stats["projectile_count"]
	
	# Ordena inimigos por distância e atira nos mais próximos
	if not enemies.is_empty():
		enemies.sort_custom(func(a, b): 
			return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position)
		)

		for i in range(min(projectile_count, enemies.size())):
			_fire_at(enemies[i])

	if radial_shot_count > 0:
		_fire_radial(radial_shot_count)

	var quantum_brain: int = int(GameManager.player_stats.get("quantum_brain", 0))
	if quantum_brain > 0 and not enemies.is_empty():
		_fire_quantum_spread(enemies[0], quantum_brain)

func _get_enemies_in_range() -> Array:
	"""Retorna todos os inimigos dentro do raio de ataque."""
	# Atualiza o raio da área de ataque
	var circle_shape = attack_area.get_node("CollisionShape2D").shape
	circle_shape.radius = GameManager.player_stats["attack_range"]
	
	var bodies: Array = attack_area.get_overlapping_bodies()
	var enemies: Array = []
	for body in bodies:
		if body.is_in_group("enemies"):
			enemies.append(body)
	return enemies

func _fire_at(target: Node2D) -> void:
	"""Instancia um projétil apontado para o alvo."""
	if AudioManager:
		AudioManager.play_shoot()
	var base_direction: Vector2 = (target.global_position - global_position).normalized()
	_spawn_projectile(base_direction)

	var chaos_chance: float = float(GameManager.player_stats.get("chaos_shot_chance", 0.0))
	if chaos_chance > 0.0 and randf() < chaos_chance:
		for i in range(2):
			var random_dir := base_direction.rotated(randf_range(-0.8, 0.8)).normalized()
			_spawn_projectile(random_dir)

func _spawn_projectile(direction: Vector2) -> void:
	var projectile = PROJECTILE_SCENE.instantiate()
	# Adiciona à cena principal para não herdar transformação do player
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = global_position
	projectile.setup(direction, GameManager.get_effective_damage())

func _fire_radial(count: int) -> void:
	if count <= 0:
		return
	for i in range(count):
		var angle := (TAU / float(count)) * float(i)
		var direction := Vector2(cos(angle), sin(angle))
		_spawn_projectile(direction)

func _fire_quantum_spread(target: Node2D, power: int) -> void:
	var base_direction: Vector2 = (target.global_position - global_position).normalized()
	var count: int = 1 + power
	for i in range(count):
		var angle_offset: float = randf_range(-1.1, 1.1) * (0.5 + power * 0.12)
		var quantum_dir := base_direction.rotated(angle_offset).normalized()
		_spawn_projectile(quantum_dir)

func _sword_attack(enemies: Array) -> void:
	if AudioManager:
		AudioManager.play_shoot()
	var radius: float = 96.0
	var sword_damage: int = int(GameManager.get_effective_damage() * 1.5)

	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		if enemy.global_position.distance_to(global_position) <= radius and enemy.has_method("take_damage"):
			var result: Dictionary = GameManager.calculate_damage(sword_damage)
			enemy.take_damage(int(result["damage"]), result["is_crit"])
			GameManager.apply_lifesteal(float(result["damage"]))

	var slash = Line2D.new()
	slash.width = 6.0
	slash.default_color = Color(0.95, 0.95, 1.2, 0.9)
	slash.points = PackedVector2Array([Vector2(-26, -14), Vector2(0, 0), Vector2(26, 14)])
	add_child(slash)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(slash, "rotation", slash.rotation + 1.8, 0.12)
	tween.tween_property(slash, "modulate:a", 0.0, 0.12)
	tween.tween_callback(slash.queue_free)

func _magic_attack(enemies: Array) -> void:
	if AudioManager:
		AudioManager.play_shoot()
	var bursts: int = 6 + int(GameManager.player_stats.get("quantum_brain", 0))
	for i in range(bursts):
		var angle: float = (TAU / float(bursts)) * float(i)
		var dir := Vector2(cos(angle), sin(angle))
		_spawn_projectile(dir)

	if not enemies.is_empty():
		var center_enemy = enemies[0]
		if is_instance_valid(center_enemy):
			for j in range(3):
				var arc_dir: Vector2 = (center_enemy.global_position - global_position).normalized().rotated(randf_range(-0.6, 0.6))
				_spawn_projectile(arc_dir)

func update_cooldown() -> void:
	"""Chamado após upgrades para atualizar o intervalo de ataque."""
	_update_timer()
	# Reinicia o timer com o novo valor
	attack_timer.stop()
	attack_timer.start()
