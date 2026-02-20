# Player.gd
# Controla o personagem do jogador: movimento 8 direções, HP, morte.
# Usa sprite pixel art gerado pelo SpriteGenerator.
extends CharacterBody2D

# --- Sinais ---
signal hp_changed(current_hp: int, max_hp: int)
signal player_died

# --- Stats (lidas do GameManager) ---
var max_hp: int = 100
var current_hp: int = 100
var speed: float = 200.0

# --- Invencibilidade após tomar dano (i-frames) ---
var is_invincible: bool = false
var invincibility_duration: float = 0.5
var invincibility_timer: float = 0.0

# --- Sistema de Dash ---
var dash_speed: float = 600.0
var dash_duration: float = 0.2
var dash_cooldown: float = 1.0
var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO

# --- Animação de bobbing (balanço idle) ---
var _bob_time: float = 0.0
var _base_y: float = 0.0

# --- Referências de nós ---
@onready var sprite: Sprite2D = $Sprite2D
@onready var weapon_system: Node = $WeaponSystem
@onready var shadow: ColorRect = $Shadow

func _ready() -> void:
	add_to_group("player")
	GameManager.player_ref = self
	
	# Aplica o sprite pixel art gerado
	if sprite:
		sprite.texture = SpriteGenerator.get_player_texture()
		# Garante renderização pixel art (sem filtro/blur)
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		sprite.visible = true
		sprite.modulate = Color.WHITE
	
	_base_y = sprite.position.y if sprite else 0.0
	update_stats()

func update_stats() -> void:
	"""Sincroniza os stats locais com o GameManager (chamado após upgrades)."""
	max_hp = GameManager.player_stats["max_hp"]
	speed = GameManager.player_stats["speed"]
	current_hp = min(current_hp, max_hp)
	emit_signal("hp_changed", current_hp, max_hp)

func _physics_process(delta: float) -> void:
	_handle_dash_input()
	_handle_dash(delta)
	if not is_dashing:
		_handle_movement(delta)
	_handle_invincibility(delta)
	_handle_bob_animation(delta)

func _handle_dash_input() -> void:
	"""Detecta input de dash (Shift ou Espaço)."""
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= get_physics_process_delta_time()
		return
	
	if Input.is_action_just_pressed("ui_accept") or Input.is_key_pressed(KEY_SHIFT):
		var direction: Vector2 = Vector2.ZERO
		direction.x = Input.get_axis("move_left", "move_right")
		direction.y = Input.get_axis("move_up", "move_down")
		
		if direction.length() > 0:
			is_dashing = true
			dash_timer = dash_duration
			dash_direction = direction.normalized()
			dash_cooldown_timer = dash_cooldown
			is_invincible = true
			# Efeito visual de dash
			sprite.modulate = Color(0.5, 0.8, 1.0, 0.7)

func _handle_dash(delta: float) -> void:
	"""Executa o dash."""
	if not is_dashing:
		return
	
	dash_timer -= delta
	if dash_timer <= 0:
		is_dashing = false
		is_invincible = false
		sprite.modulate = Color.WHITE
		return
	
	velocity = dash_direction * dash_speed
	move_and_slide()

func _handle_movement(delta: float) -> void:
	"""Lê o input e move o player em 8 direções com normalização."""
	var direction: Vector2 = Vector2.ZERO
	direction.x = Input.get_axis("move_left", "move_right")
	direction.y = Input.get_axis("move_up", "move_down")
	
	if direction.length() > 0:
		direction = direction.normalized()
		# Vira o sprite na direção horizontal
		if direction.x != 0:
			sprite.scale.x = sign(direction.x) * abs(sprite.scale.x)
	
	velocity = direction * speed
	move_and_slide()

func _handle_bob_animation(delta: float) -> void:
	"""Animação de balanço suave (idle bob) — dá vida ao sprite."""
	_bob_time += delta * 3.5
	# Oscila levemente para cima e para baixo
	sprite.position.y = _base_y + sin(_bob_time) * 1.5
	# Leve rotação de balanço
	sprite.rotation = sin(_bob_time * 0.7) * 0.04

func _handle_invincibility(delta: float) -> void:
	"""Gerencia o timer de invencibilidade e o efeito visual de piscar."""
	if is_invincible:
		invincibility_timer -= delta
		# Pisca alternando visibilidade
		sprite.visible = int(invincibility_timer * 10) % 2 == 0
		if invincibility_timer <= 0:
			is_invincible = false
			sprite.visible = true
			sprite.modulate = Color.WHITE

func take_damage(amount: int) -> void:
	"""Aplica dano ao player, respeitando i-frames."""
	if is_invincible:
		return
	
	current_hp -= amount
	emit_signal("hp_changed", current_hp, max_hp)
	
	# Efeito visual de dano
	PixelEffects.spawn_damage_number(global_position + Vector2(0, -30), amount, false)
	
	is_invincible = true
	invincibility_timer = invincibility_duration
	
	# Flash vermelho no sprite
	sprite.modulate = Color(1, 0.2, 0.2)
	await get_tree().create_timer(0.1).timeout
	if is_instance_valid(self):
		sprite.modulate = Color.WHITE
	
	if current_hp <= 0:
		_die()

func heal(amount: int) -> void:
	"""Cura o player, sem exceder o HP máximo."""
	current_hp = min(current_hp + amount, max_hp)
	emit_signal("hp_changed", current_hp, max_hp)
	# Flash verde de cura
	sprite.modulate = Color(0.3, 1.0, 0.3)
	await get_tree().create_timer(0.15).timeout
	if is_instance_valid(self):
		sprite.modulate = Color.WHITE

func _die() -> void:
	"""Mata o player e notifica o GameManager."""
	emit_signal("player_died")
	GameManager.trigger_game_over()
	set_physics_process(false)
	set_process(false)
	sprite.visible = false
	shadow.visible = false
	if weapon_system:
		weapon_system.set_process(false)
