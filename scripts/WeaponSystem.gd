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
	attack_timer.wait_time = GameManager.player_stats["attack_cooldown"]

func _on_attack_timer_timeout() -> void:
	"""Chamado pelo timer: dispara ataques."""
	var enemies: Array = _get_enemies_in_range()
	if enemies.is_empty():
		return
	
	var projectile_count: int = GameManager.player_stats["projectile_count"]
	
	# Ordena inimigos por distância e atira nos mais próximos
	enemies.sort_custom(func(a, b): 
		return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position)
	)
	
	for i in range(min(projectile_count, enemies.size())):
		_fire_at(enemies[i])

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
	var projectile = PROJECTILE_SCENE.instantiate()
	# Adiciona à cena principal para não herdar transformação do player
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = global_position
	
	var direction: Vector2 = (target.global_position - global_position).normalized()
	projectile.setup(direction, GameManager.player_stats["damage"])

func update_cooldown() -> void:
	"""Chamado após upgrades para atualizar o intervalo de ataque."""
	_update_timer()
	# Reinicia o timer com o novo valor
	attack_timer.stop()
	attack_timer.start()
