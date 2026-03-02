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
var _shift_was_pressed: bool = false

# --- Animação de bobbing (balanço idle) ---
var _bob_time: float = 0.0
var _base_y: float = 0.0
var _mutation_stage: int = 0
var _orbital_angle: float = 0.0
var _orbital_tick: float = 0.0
var _orbital_nodes: Array[Sprite2D] = []
var _mutation_fx_root: Node2D

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
	_mutation_fx_root = Node2D.new()
	_mutation_fx_root.name = "MutationFX"
	add_child(_mutation_fx_root)
	update_stats()

func _apply_mutation_visuals() -> void:
	if not sprite:
		return
	var mutation_power: int = int(GameManager.player_stats.get("mutation_power", 0))
	var stage: int = clamp(mutation_power, 0, 3)
	if stage != _mutation_stage:
		_mutation_stage = stage
		if stage == 0:
			sprite.texture = SpriteGenerator.get_player_texture()
		else:
			sprite.texture = SpriteGenerator.get_player_mutation_texture(stage)
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	var scale_mult: float = float(GameManager.player_stats.get("player_scale", 1.0))
	var sign_x: float = -1.0 if sprite.scale.x < 0 else 1.0
	sprite.scale = Vector2(abs(scale_mult) * sign_x, abs(scale_mult))

	if mutation_power >= 4:
		sprite.modulate = Color(1.35, 0.72, 1.45)
	elif mutation_power >= 2:
		sprite.modulate = Color(1.2, 0.9, 1.35)
	else:
		sprite.modulate = Color.WHITE

	_update_orbital_visuals(0.0)

func update_stats() -> void:
	"""Sincroniza os stats locais com o GameManager (chamado após upgrades)."""
	max_hp = GameManager.player_stats["max_hp"]
	speed = GameManager.get_effective_speed()
	current_hp = min(current_hp, max_hp)
	if weapon_system and weapon_system.has_method("update_cooldown"):
		weapon_system.update_cooldown()
	_apply_mutation_visuals()
	emit_signal("hp_changed", current_hp, max_hp)

func _physics_process(delta: float) -> void:
	speed = GameManager.get_effective_speed()
	_handle_dash_input()
	_handle_dash(delta)
	if not is_dashing:
		_handle_movement(delta)
	_handle_invincibility(delta)
	_handle_bob_animation(delta)
	_update_orbital_visuals(delta)
	_process_orbital_damage(delta)

func _update_orbital_visuals(delta: float) -> void:
	if not _mutation_fx_root:
		return
	var orbit_count: int = int(GameManager.player_stats.get("void_orbitals", 0))
	if orbit_count <= 0:
		for node in _orbital_nodes:
			if is_instance_valid(node):
				node.queue_free()
		_orbital_nodes.clear()
		return

	while _orbital_nodes.size() < orbit_count:
		var orb := Sprite2D.new()
		orb.texture = SpriteGenerator.get_projectile_texture()
		orb.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		orb.modulate = Color(0.6, 1.0, 1.4, 0.92)
		_mutation_fx_root.add_child(orb)
		_orbital_nodes.append(orb)

	while _orbital_nodes.size() > orbit_count:
		var last = _orbital_nodes.pop_back()
		if is_instance_valid(last):
			last.queue_free()

	_orbital_angle += delta * (2.4 + orbit_count * 0.35)
	var radius: float = 30.0 + float(orbit_count) * 6.0
	for i in range(_orbital_nodes.size()):
		var orb = _orbital_nodes[i]
		if not is_instance_valid(orb):
			continue
		var angle: float = _orbital_angle + (TAU / float(max(1, orbit_count))) * float(i)
		orb.position = Vector2(cos(angle), sin(angle)) * radius + Vector2(0, -4)
		orb.rotation = angle

func _process_orbital_damage(delta: float) -> void:
	var orbit_count: int = int(GameManager.player_stats.get("void_orbitals", 0))
	if orbit_count <= 0:
		return
	_orbital_tick -= delta
	if _orbital_tick > 0.0:
		return
	_orbital_tick = 0.28
	var radius: float = 70.0 + orbit_count * 20.0
	var base_damage: int = 5 + orbit_count * 4
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy):
			continue
		if enemy.global_position.distance_to(global_position) <= radius and enemy.has_method("take_damage"):
			enemy.take_damage(base_damage, false)

func _handle_dash_input() -> void:
	"""Detecta input de dash (Shift ou Espaço)."""
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= get_physics_process_delta_time()
		_shift_was_pressed = Input.is_physical_key_pressed(KEY_SHIFT)
		return
	
	var shift_pressed_now: bool = Input.is_physical_key_pressed(KEY_SHIFT)
	var shift_just_pressed: bool = shift_pressed_now and not _shift_was_pressed
	var dash_pressed: bool = Input.is_action_just_pressed("ui_accept") or shift_just_pressed

	if dash_pressed:
		var direction: Vector2 = Vector2.ZERO
		direction.x = Input.get_axis("move_left", "move_right")
		direction.y = Input.get_axis("move_up", "move_down")
		
		if direction.length() > 0:
			is_dashing = true
			dash_timer = dash_duration
			dash_direction = direction.normalized()
			dash_cooldown_timer = dash_cooldown
			is_invincible = true
			if AudioManager:
				AudioManager.play_dash()
			# Efeito visual de dash
			sprite.modulate = Color(0.5, 0.8, 1.0, 0.7)

	_shift_was_pressed = shift_pressed_now

func _handle_dash(delta: float) -> void:
	"""Executa o dash."""
	if not is_dashing:
		return
	
	dash_timer -= delta
	if dash_timer <= 0:
		is_dashing = false
		is_invincible = false
		_apply_mutation_visuals()
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
			_apply_mutation_visuals()

func take_damage(amount: int) -> void:
	"""Aplica dano ao player, respeitando i-frames."""
	if is_invincible or GameManager.is_temp_invincible():
		return
	
	current_hp -= amount
	emit_signal("hp_changed", current_hp, max_hp)
	if AudioManager:
		AudioManager.play_player_hit()
	
	# Efeito visual de dano
	PixelEffects.spawn_damage_number(global_position + Vector2(0, -30), amount, false)
	
	is_invincible = true
	invincibility_timer = invincibility_duration
	
	# Flash vermelho no sprite
	sprite.modulate = Color(1, 0.2, 0.2)
	await get_tree().create_timer(0.1).timeout
	if is_instance_valid(self):
		_apply_mutation_visuals()
	
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
		_apply_mutation_visuals()

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
