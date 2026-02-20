# Enemy.gd
extends CharacterBody2D

var max_hp: int = 30
var current_hp: int = 30
var speed: float = 80.0
var damage: int = 10
var xp_reward: int = 20
var contact_damage_cooldown: float = 0.5 # Reduzi um pouco para sentir mais impacto
var contact_timer: float = 0.0

var _bob_time: float = 0.0
var _base_y: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var hp_bar_bg: ColorRect = $HPBarBG
@onready var hp_bar_fill: ColorRect = $HPBarBG/Fill
@onready var shadow: ColorRect = $Shadow

var player: Node2D = null

func _ready() -> void:
	add_to_group("enemies")
	# Garante que pegamos o player mesmo se ele demorar um frame para carregar
	player = get_tree().get_first_node_in_group("player")
	
	if sprite:
		# Verifique se SpriteGenerator existe no seu projeto globalmente
		sprite.texture = SpriteGenerator.get_enemy_texture()
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		_base_y = sprite.position.y
	
	_bob_time = randf() * TAU
	_update_hp_bar()

func setup(hp: int, spd: float, dmg: int, xp: int) -> void:
	max_hp = hp
	current_hp = hp
	speed = spd
	damage = dmg
	xp_reward = xp
	_update_hp_bar()

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
		return
	
	_move_towards_player(delta)
	_handle_bob_animation(delta)
	_handle_contact_damage(delta)

func _move_towards_player(_delta: float) -> void:
	var direction: Vector2 = global_position.direction_to(player.global_position)
	velocity = direction * speed
	move_and_slide()
	
	if direction.x != 0 and sprite:
		# Corrigido para não inverter o sprite repetidamente se já estiver na direção certa
		sprite.flip_h = direction.x < 0

func _handle_bob_animation(delta: float) -> void:
	if not sprite: return
	_bob_time += delta * 4.0
	sprite.position.y = _base_y + sin(_bob_time) * 1.5
	sprite.rotation = sin(_bob_time * 0.8) * 0.05

func _handle_contact_damage(delta: float) -> void:
	if contact_timer > 0:
		contact_timer -= delta
		return
	
	# Usando a colisão do move_and_slide é mais eficiente que checar distância toda vez
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider and collider.is_in_group("player"):
			if collider.has_method("take_damage"):
				collider.take_damage(damage)
				contact_timer = contact_damage_cooldown
				# Knockback leve no inimigo ao bater
				velocity = -velocity * 0.5 
				break

func take_damage(amount: int, is_crit: bool = false) -> void:
	current_hp -= amount
	_update_hp_bar()
	
	# Efeitos Visuais
	if is_crit:
		PixelEffects.spawn_damage_number(global_position + Vector2(0, -20), amount, true)
		_flash_sprite(Color(2.0, 0.5, 0.5), 1.2)
	else:
		PixelEffects.spawn_damage_number(global_position + Vector2(0, -20), amount, false)
		_flash_sprite(Color(1.5, 1.5, 1.5), 1.1)
	
	if current_hp <= 0:
		_die()

# Função auxiliar para evitar erros de 'await' se o inimigo morrer
func _flash_sprite(color: Color, scale_mult: float) -> void:
	if not sprite: return
	sprite.modulate = color
	var original_scale = sprite.scale
	sprite.scale.y *= 0.8
	
	await get_tree().create_timer(0.08).timeout
	
	if is_instance_valid(sprite):
		sprite.modulate = Color.WHITE
		sprite.scale.y = original_scale.y

func _die() -> void:
	# Importante: Desativar colisão para não morrer duas vezes no mesmo frame
	set_physics_process(false)
	GameManager.add_xp(xp_reward)
	PixelEffects.spawn_xp_particles(global_position)
	queue_free()

func _update_hp_bar() -> void:
	if hp_bar_fill and hp_bar_bg:
		var ratio: float = clamp(float(current_hp) / float(max_hp), 0.0, 1.0)
		hp_bar_fill.size.x = hp_bar_bg.size.x * ratio # Dinâmico ao tamanho do BG
		
		if ratio > 0.5:
			hp_bar_fill.color = Color(0.1, 0.9, 0.1)
		elif ratio > 0.25:
			hp_bar_fill.color = Color(0.9, 0.8, 0.1)
		else:
			hp_bar_fill.color = Color(0.9, 0.1, 0.1)
