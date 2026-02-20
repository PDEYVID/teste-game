# CameraController.gd
# Câmera que segue o player com suavização e efeito de screen shake.
extends Camera2D

# --- Shake ---
var _shake_intensity: float = 0.0
var _shake_duration: float = 0.0
var _shake_timer: float = 0.0

# --- Follow ---
var _target: Node2D = null
var follow_speed: float = 8.0

func _ready() -> void:
	add_to_group("main_camera")
	# Configura zoom para efeito pixel art (zoom 2x = pixels maiores)
	zoom = Vector2(2.0, 2.0)

func set_target(target: Node2D) -> void:
	_target = target

func shake(intensity: float = 3.0, duration: float = 0.2) -> void:
	"""Inicia um efeito de screen shake."""
	_shake_intensity = intensity
	_shake_duration = duration
	_shake_timer = duration

func _process(delta: float) -> void:
	_follow_target(delta)
	_handle_shake(delta)

func _follow_target(delta: float) -> void:
	"""Segue o target com interpolação suave."""
	if _target == null or not is_instance_valid(_target):
		return
	global_position = global_position.lerp(_target.global_position, follow_speed * delta)

func _handle_shake(delta: float) -> void:
	"""Aplica screen shake decrescente."""
	if _shake_timer > 0:
		_shake_timer -= delta
		var progress = _shake_timer / _shake_duration
		var current_intensity = _shake_intensity * progress
		offset = Vector2(
			randf_range(-current_intensity, current_intensity),
			randf_range(-current_intensity, current_intensity)
		)
	else:
		offset = Vector2.ZERO
