# ScreenEffects.gd
# Efeitos visuais de tela: vinheta, shake, slow motion
# Adiciona atmosfera e feedback visual ao jogo
extends CanvasLayer

var vignette: TextureRect
var fade_overlay: ColorRect
var shake_amount: float = 0.0
var shake_decay: float = 5.0
var original_camera_pos: Vector2

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 100  # Acima de tudo
	add_to_group("screen_effects")
	_create_vignette()
	_create_fade_overlay()
	
	# Conecta eventos do GameManager
	if GameManager.has_signal("level_up"):
		GameManager.level_up.connect(_on_level_up)

func _create_vignette() -> void:
	"""Cria uma vinheta sutil nas bordas da tela."""
	vignette = TextureRect.new()
	vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vignette.stretch_mode = TextureRect.STRETCH_SCALE
	
	# Shader de vinheta (simulado com gradiente radial)
	var gradient = GradientTexture2D.new()
	var grad = Gradient.new()
	grad.set_color(0, Color(0, 0, 0, 0))
	grad.set_color(1, Color(0, 0, 0, 0.5))
	gradient.gradient = grad
	gradient.fill = GradientTexture2D.FILL_RADIAL
	gradient.fill_from = Vector2(0.5, 0.5)
	gradient.fill_to = Vector2(0.5, 0.0)
	
	vignette.texture = gradient
	add_child(vignette)

func _create_fade_overlay() -> void:
	"""Cria overlay para transições cinematográficas de cena."""
	fade_overlay = ColorRect.new()
	fade_overlay.color = Color(0.0, 0.0, 0.0, 1.0)
	fade_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fade_overlay)

func fade_in_from_black(duration: float = 0.6) -> void:
	if not fade_overlay:
		return
	fade_overlay.modulate.a = 1.0
	var tween = create_tween()
	tween.tween_property(fade_overlay, "modulate:a", 0.0, duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func fade_to_black(duration: float = 0.35) -> void:
	if not fade_overlay:
		return
	fade_overlay.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(fade_overlay, "modulate:a", 1.0, duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)

func _process(delta: float) -> void:
	# Decai o shake ao longo do tempo
	if shake_amount > 0:
		shake_amount = max(0, shake_amount - shake_decay * delta)

func screen_shake(intensity: float) -> void:
	"""Adiciona shake na tela."""
	shake_amount = intensity
	var camera = get_tree().get_first_node_in_group("main_camera")
	if camera and camera.has_method("shake"):
		camera.shake(max(2.0, intensity), 0.18)

func flash_white(duration: float = 0.2) -> void:
	"""Flash branco na tela."""
	var flash = ColorRect.new()
	flash.color = Color(1.0, 1.0, 1.0, 0.6)
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(flash)
	
	var tween = create_tween()
	tween.tween_property(flash, "modulate:a", 0.0, duration)
	await tween.finished
	flash.queue_free()

func damage_flash() -> void:
	"""Flash vermelho ao tomar dano."""
	var flash = ColorRect.new()
	flash.color = Color(1.0, 0.2, 0.2, 0.4)
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(flash)
	
	var tween = create_tween()
	tween.tween_property(flash, "modulate:a", 0.0, 0.3)
	await tween.finished
	flash.queue_free()

func _on_level_up(_level: int) -> void:
	"""Efeito visual ao subir de nível."""
	flash_white(0.3)
	pulse_vignette(0.25, 0.4)
	screen_shake(4.5)
	
	# Slow motion temporário
	Engine.time_scale = 0.35
	await get_tree().create_timer(0.35, true, false, true).timeout
	Engine.time_scale = 1.0

func pulse_vignette(intensity: float = 0.3, duration: float = 0.5) -> void:
	"""Pulsa a vinheta para criar tensão."""
	var original_modulate = vignette.modulate
	var tween = create_tween()
	tween.tween_property(vignette, "modulate", Color(1.0, 0.5, 0.5, 1.0 + intensity), duration * 0.5)
	tween.tween_property(vignette, "modulate", original_modulate, duration * 0.5)
