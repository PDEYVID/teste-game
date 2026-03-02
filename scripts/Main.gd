# Main.gd
# Cena principal: inicializa o jogo e conecta os sistemas.
extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var hud: CanvasLayer = $HUD
@onready var camera: Camera2D = $Camera2D
@onready var notification_system: CanvasLayer = $NotificationSystem
@onready var screen_effects: CanvasLayer = $ScreenEffects

var _previous_hp: int = -1
var _danger_notify_cooldown: float = 0.0

func _ready() -> void:
	GameManager.reset_game()
	GameManager.is_game_running = true
	
	# Conecta a HUD ao player
	hud.connect_player(player)
	
	# Configura a câmera para seguir o player
	camera.set_target(player)
	if screen_effects and screen_effects.has_method("fade_in_from_black"):
		screen_effects.fade_in_from_black(0.45)
	if notification_system and notification_system.has_method("notify_achievement"):
		notification_system.notify_achievement("PATCH ATIVO: cenários + mutações + elites")
	
	# Conecta o shake da câmera ao player (quando toma dano)
	player.hp_changed.connect(_on_player_hp_changed)
	GameManager.level_up.connect(_on_level_up)
	_previous_hp = player.current_hp

func _process(delta: float) -> void:
	if _danger_notify_cooldown > 0.0:
		_danger_notify_cooldown -= delta

func _on_player_hp_changed(current: int, maximum: int) -> void:
	"""Dispara shake da câmera quando o HP diminui."""
	if _previous_hp >= 0 and current < _previous_hp:
		var damage_taken: int = _previous_hp - current
		var intensity: float = clamp(2.0 + float(damage_taken) * 0.12, 2.0, 6.0)
		camera.shake(intensity, 0.16)
		if screen_effects:
			screen_effects.damage_flash()
			screen_effects.pulse_vignette(clamp(float(damage_taken) * 0.02, 0.12, 0.35), 0.35)

	var hp_ratio: float = float(current) / float(maximum)
	if hp_ratio <= 0.2 and _danger_notify_cooldown <= 0.0 and notification_system:
		notification_system.notify_danger("VIDA CRÍTICA!")
		_danger_notify_cooldown = 8.0

	_previous_hp = current

func _on_level_up(new_level: int) -> void:
	if notification_system:
		notification_system.notify_level_up(new_level)
