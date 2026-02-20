# Main.gd
# Cena principal: inicializa o jogo e conecta os sistemas.
extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var hud: CanvasLayer = $HUD
@onready var camera: Camera2D = $Camera2D

func _ready() -> void:
	GameManager.reset_game()
	GameManager.is_game_running = true
	
	# Conecta a HUD ao player
	hud.connect_player(player)
	
	# Configura a câmera para seguir o player
	camera.set_target(player)
	
	# Conecta o shake da câmera ao player (quando toma dano)
	player.hp_changed.connect(_on_player_hp_changed)

func _on_player_hp_changed(current: int, maximum: int) -> void:
	"""Shake de câmera quando o player toma dano."""
	# Detecta se foi dano (HP diminuiu) — comparando com frame anterior não é trivial,
	# então usamos uma heurística: se HP < max, pode ter tomado dano
	# O shake é disparado pelo Player.take_damage diretamente via GameManager
	pass
