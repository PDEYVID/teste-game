# EnemySpawner.gd
# Gerencia o spawn de inimigos em ondas infinitas.
# A dificuldade escala com o tempo de jogo.
extends Node2D

# Cena do inimigo
const ENEMY_SCENE = preload("res://scenes/Enemy.tscn")

# --- Configuração de Spawn ---
var base_spawn_interval: float = 2.0
var min_spawn_interval: float = 0.4
var spawn_interval: float = 2.0
var enemies_per_wave: int = 1
var spawn_radius: float = 600.0  # Distância do player onde os inimigos surgem

@onready var spawn_timer: Timer = $SpawnTimer

# Referência ao player
var player: Node2D = null

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()

func _process(_delta: float) -> void:
	# Escala a dificuldade com o tempo sobrevivido
	_update_difficulty()

func _update_difficulty() -> void:
	"""Aumenta a frequência e quantidade de inimigos com o tempo."""
	var time: float = GameManager.survived_time
	
	# A cada 30 segundos, reduz o intervalo de spawn
	var new_interval: float = max(min_spawn_interval, base_spawn_interval - (time / 30.0) * 0.3)
	if abs(new_interval - spawn_interval) > 0.05:
		spawn_interval = new_interval
		spawn_timer.wait_time = spawn_interval
	
	# Aumenta inimigos por onda a cada minuto
	enemies_per_wave = 1 + int(time / 60.0)

func _on_spawn_timer_timeout() -> void:
	"""Spawna uma onda de inimigos ao redor do player."""
	if not GameManager.is_game_running:
		return
	if player == null or not is_instance_valid(player):
		return
	
	for i in range(enemies_per_wave):
		_spawn_enemy()

func _spawn_enemy() -> void:
	"""Spawna um inimigo em posição aleatória ao redor do player."""
	# Posição aleatória em círculo ao redor do player
	var angle: float = randf() * TAU
	var spawn_pos: Vector2 = player.global_position + Vector2(
		cos(angle) * spawn_radius,
		sin(angle) * spawn_radius
	)
	
	var enemy = ENEMY_SCENE.instantiate()
	get_tree().current_scene.add_child(enemy)
	enemy.global_position = spawn_pos
	
	# Escala os stats do inimigo com o tempo (dificuldade progressiva)
	var time: float = GameManager.survived_time
	var difficulty_mult: float = 1.0 + (time / 60.0) * 0.5
	
	# Determina tipo de inimigo baseado em probabilidade
	var enemy_type: String = _get_random_enemy_type(time)
	
	var hp: int
	var spd: float
	var dmg: int
	var xp: int
	
	match enemy_type:
		"fast":
			# Inimigo rápido: menos HP, mais velocidade
			hp = int(20 * difficulty_mult)
			spd = 140.0 + (time / 60.0) * 15.0
			dmg = int(8 * difficulty_mult)
			xp = int(15 * difficulty_mult)
			enemy.sprite.texture = SpriteGenerator.get_enemy_fast_texture()
			enemy.hp_bar_fill.color = Color(0.1, 0.7, 0.8)
		"tank":
			# Inimigo tanque: muito HP, lento
			hp = int(60 * difficulty_mult)
			spd = 50.0 + (time / 60.0) * 5.0
			dmg = int(15 * difficulty_mult)
			xp = int(30 * difficulty_mult)
			enemy.sprite.texture = SpriteGenerator.get_enemy_tank_texture()
			enemy.hp_bar_fill.color = Color(0.8, 0.4, 0.1)
		"boss":
			# Boss: stats épicos
			hp = int(200 * difficulty_mult)
			spd = 60.0 + (time / 60.0) * 8.0
			dmg = int(25 * difficulty_mult)
			xp = int(100 * difficulty_mult)
			enemy.sprite.texture = SpriteGenerator.get_enemy_boss_texture()
			enemy.hp_bar_fill.color = Color(0.8, 0.3, 0.9)
			enemy.sprite.scale *= 1.5  # Boss é maior
		_:  # "normal"
			# Inimigo padrão
			hp = int(30 * difficulty_mult)
			spd = 80.0 + (time / 60.0) * 10.0
			dmg = int(10 * difficulty_mult)
			xp = int(20 * difficulty_mult)
	
	enemy.setup(hp, spd, dmg, xp)

func _get_random_enemy_type(time: float) -> String:
	"""Determina tipo de inimigo baseado em probabilidade e tempo."""
	var rand: float = randf()
	
	# Boss aparece a cada 2 minutos
	if int(time) % 120 == 0 and int(time) > 0 and rand < 0.05:
		return "boss"
	
	# Após 1 minuto, começa a spawnar variações
	if time < 60:
		return "normal"
	
	# Probabilidades ajustadas com o tempo
	if rand < 0.25:
		return "fast"
	elif rand < 0.45:
		return "tank"
	else:
		return "normal"
