# PixelEffects.gd
# Efeitos visuais pixel art: partículas de XP, flash de dano, animações.
# Autoload — qualquer sistema pode chamar PixelEffects.spawn_xp_particle(pos)
extends Node2D

# Cena de partícula (criada proceduralmente)
const XP_PARTICLE_COUNT = 4

func spawn_xp_particles(position: Vector2) -> void:
	"""Spawna partículas de XP ao matar um inimigo."""
	for i in range(XP_PARTICLE_COUNT):
		var particle = _create_xp_particle()
		get_tree().current_scene.add_child(particle)
		particle.global_position = position
		
		# Direção aleatória em leque
		var angle = randf() * TAU
		var speed = randf_range(60.0, 140.0)
		var direction = Vector2(cos(angle), sin(angle))
		
		_animate_particle(particle, direction * speed)

func spawn_damage_number(position: Vector2, amount: int, is_crit: bool = false) -> void:
	"""Exibe número de dano flutuante em estilo pixel art."""
	var label = Label.new()
	
	if is_crit:
		label.text = str(amount) + "!"
		label.add_theme_font_size_override("font_size", 20)
		label.modulate = Color(1.0, 0.2, 0.2)  # Vermelho para crítico
	else:
		label.text = str(amount)
		label.add_theme_font_size_override("font_size", 14)
		label.modulate = Color(1.0, 0.9, 0.1)
	
	label.z_index = 10
	get_tree().current_scene.add_child(label)
	label.global_position = position + Vector2(-8, -20)
	
	_animate_damage_number(label, is_crit)

func spawn_level_up_effect(position: Vector2) -> void:
	"""Efeito de level up: círculo de partículas douradas."""
	for i in range(8):
		var particle = _create_star_particle()
		get_tree().current_scene.add_child(particle)
		particle.global_position = position
		
		var angle = (TAU / 8.0) * i
		var direction = Vector2(cos(angle), sin(angle))
		_animate_particle(particle, direction * 120.0, Color(1.0, 0.9, 0.2))

func _create_xp_particle() -> ColorRect:
	"""Cria um pixel de XP (quadrado 4x4 verde)."""
	var rect = ColorRect.new()
	rect.size = Vector2(6, 6)
	rect.color = Color(0.3, 1.0, 0.2)
	rect.z_index = 5
	return rect

func _create_star_particle() -> ColorRect:
	"""Cria um pixel dourado para efeito de level up."""
	var rect = ColorRect.new()
	rect.size = Vector2(5, 5)
	rect.color = Color(1.0, 0.85, 0.1)
	rect.z_index = 5
	return rect

func _animate_particle(particle: Node, velocity: Vector2, color: Color = Color.WHITE) -> void:
	"""Anima uma partícula: move e desaparece."""
	if color != Color.WHITE and particle is ColorRect:
		particle.color = color
	
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	
	# Move na direção com desaceleração
	tween.tween_property(particle, "global_position",
		particle.global_position + velocity * 0.5,
		0.4
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	# Fade out
	tween.tween_property(particle, "modulate:a", 0.0, 0.4).set_ease(Tween.EASE_IN)
	
	# Destrói após a animação
	tween.tween_callback(particle.queue_free).set_delay(0.41)

func _animate_damage_number(label: Label, is_crit: bool = false) -> void:
	"""Anima o número de dano: sobe e desaparece."""
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	
	# Crítico sobe mais e mais rápido
	var rise_amount: float = -40 if is_crit else -30
	var duration: float = 0.7 if is_crit else 0.6
	
	# Sobe
	tween.tween_property(label, "global_position:y",
		label.global_position.y + rise_amount,
		duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	# Escala para crítico
	if is_crit:
		tween.tween_property(label, "scale", Vector2(1.3, 1.3), 0.1)
	
	# Fade out após 0.3s
	tween.tween_property(label, "modulate:a", 0.0, 0.3).set_delay(0.3)
	
	tween.tween_callback(label.queue_free).set_delay(duration + 0.1)
