# Projectile.gd
# Projétil disparado pelo WeaponSystem.
# Usa sprite pixel art de orbe mágico com animação de rotação.
extends Area2D

var direction: Vector2 = Vector2.RIGHT
var speed: float = 400.0
var damage: float = 20.0
var lifetime: float = 2.0
var is_crit: bool = false

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	get_tree().create_timer(lifetime).timeout.connect(queue_free)
	
	# Aplica sprite pixel art do orbe
	if sprite:
		sprite.texture = SpriteGenerator.get_projectile_texture()
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		sprite.visible = true
		
		# Animação de entrada: escala de 0 para 1
		sprite.scale = Vector2.ZERO
		var tween = create_tween()
		tween.tween_property(sprite, "scale", Vector2.ONE, 0.1).set_trans(Tween.TRANS_BACK)

func setup(dir: Vector2, dmg: float) -> void:
	"""Configura o projétil com direção e dano."""
	direction = dir
	# Calcula dano com chance de crítico
	var damage_result = GameManager.calculate_damage(dmg)
	damage = damage_result["damage"]
	is_crit = damage_result["is_crit"]
	
	# Visual diferente para crítico
	if is_crit:
		sprite.modulate = Color(1.5, 0.5, 0.5)  # Vermelho brilhante
		sprite.scale = Vector2(1.3, 1.3)  # Maior

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	# Rotação constante do orbe (efeito visual)
	sprite.rotation += delta * 5.0

func _on_body_entered(body: Node2D) -> void:
	"""Colisão com inimigo: causa dano e se destrói com efeito."""
	if body.is_in_group("enemies"):
		if body.has_method("take_damage"):
			body.take_damage(int(damage), is_crit)
			# Aplica lifesteal
			GameManager.apply_lifesteal(damage)
		_destroy_with_effect()

func _destroy_with_effect() -> void:
	"""Animação de destruição antes de queue_free."""
	# Desativa colisão imediatamente para não acertar múltiplos
	$CollisionShape2D.set_deferred("disabled", true)
	
	var tween = create_tween()
	tween.set_parallel(true)
	# Expande e desaparece
	tween.tween_property(sprite, "scale", Vector2(2.0, 2.0), 0.12)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.12)
	tween.tween_callback(queue_free).set_delay(0.13)
