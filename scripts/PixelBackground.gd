# PixelBackground.gd
# Renderiza o fundo do jogo como um grid de tiles pixel art.
# Segue a câmera para criar a ilusão de mundo infinito.
extends Node2D

const TILE_SIZE: int = 16       # Tamanho de cada tile em pixels
const TILES_VISIBLE: int = 50   # Quantos tiles renderizar em cada direção
const SCENARIO_DURATION: float = 30.0

const SCENARIOS: Array[Dictionary] = [
	{
		"name": "🛸 PLANETA XERON",
		"base": Color(0.04, 0.09, 0.13),
		"alt": Color(0.07, 0.16, 0.20),
		"line": Color(0.10, 0.45, 0.45, 0.32),
		"tint": Color(0.55, 1.0, 1.0, 0.36)
	},
	{
		"name": "☄ DESERTO DE PLASMA",
		"base": Color(0.11, 0.05, 0.02),
		"alt": Color(0.20, 0.08, 0.04),
		"line": Color(0.42, 0.15, 0.05, 0.35),
		"tint": Color(1.0, 0.58, 0.22, 0.35)
	},
	{
		"name": "🧬 BIOMA NEON",
		"base": Color(0.05, 0.03, 0.10),
		"alt": Color(0.11, 0.05, 0.16),
		"line": Color(0.35, 0.12, 0.60, 0.32),
		"tint": Color(0.95, 0.35, 1.0, 0.36)
	},
	{
		"name": "👁 RUÍNAS ORBITAIS",
		"base": Color(0.03, 0.06, 0.11),
		"alt": Color(0.04, 0.10, 0.17),
		"line": Color(0.12, 0.30, 0.55, 0.32),
		"tint": Color(0.45, 0.80, 1.0, 0.34)
	}
]

var _tile_texture: ImageTexture = null
var _camera: Camera2D = null
var _current_scenario_index: int = -1

func _ready() -> void:
	# Gera a textura do tile
	_tile_texture = SpriteGenerator.get_background_tile_texture()
	# Busca a câmera
	_camera = get_tree().get_first_node_in_group("main_camera")
	# Desenha o fundo inicial
	_update_scenario(true)
	queue_redraw()

func _process(_delta: float) -> void:
	_update_scenario(false)
	# Redesenha quando a câmera se move (snap ao grid para efeito pixel art)
	queue_redraw()

func _update_scenario(force: bool) -> void:
	var next_index: int = int(GameManager.survived_time / SCENARIO_DURATION) % SCENARIOS.size()
	if not force and next_index == _current_scenario_index:
		return
	_current_scenario_index = next_index
	var notifications = get_tree().get_first_node_in_group("notifications")
	if notifications and notifications.has_method("notify_achievement"):
		notifications.notify_achievement("Cenário: %s" % SCENARIOS[_current_scenario_index]["name"])

func _draw() -> void:
	"""Desenha tiles ao redor da posição atual da câmera."""
	if _tile_texture == null:
		return
	
	# Pega a posição da câmera (ou origem se não houver câmera)
	var cam_pos: Vector2 = Vector2.ZERO
	if _camera and is_instance_valid(_camera):
		cam_pos = _camera.global_position
	
	# Calcula o offset do grid (snap ao tile)
	var offset_x: int = int(cam_pos.x) % TILE_SIZE
	var offset_y: int = int(cam_pos.y) % TILE_SIZE

	var scenario := SCENARIOS[max(_current_scenario_index, 0)]
	var base_color: Color = scenario["base"]
	var alt_color: Color = scenario["alt"]
	var line_color: Color = scenario["line"]
	var texture_tint: Color = scenario["tint"]
	
	# Área de renderização
	var start_x: int = int(cam_pos.x) - TILES_VISIBLE * TILE_SIZE - offset_x
	var start_y: int = int(cam_pos.y) - TILES_VISIBLE * TILE_SIZE - offset_y
	
	for ty in range(TILES_VISIBLE * 2 + 2):
		for tx in range(TILES_VISIBLE * 2 + 2):
			var tile_pos = Vector2(
				start_x + tx * TILE_SIZE,
				start_y + ty * TILE_SIZE
			)
			var checker: bool = ((tx + ty) % 2 == 0)
			draw_rect(Rect2(tile_pos, Vector2(TILE_SIZE, TILE_SIZE)), base_color if checker else alt_color)
			draw_texture_rect(_tile_texture, Rect2(tile_pos, Vector2(TILE_SIZE, TILE_SIZE)), false, texture_tint)
	
	# Desenha linhas de grid sutis para dar profundidade
	for ty in range(TILES_VISIBLE * 2 + 2):
		var y_pos = start_y + ty * TILE_SIZE
		draw_line(
			Vector2(start_x, y_pos),
			Vector2(start_x + (TILES_VISIBLE * 2 + 2) * TILE_SIZE, y_pos),
			line_color, 0.5
		)
	for tx in range(TILES_VISIBLE * 2 + 2):
		var x_pos = start_x + tx * TILE_SIZE
		draw_line(
			Vector2(x_pos, start_y),
			Vector2(x_pos, start_y + (TILES_VISIBLE * 2 + 2) * TILE_SIZE),
			line_color, 0.5
		)
