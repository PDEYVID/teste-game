# PixelBackground.gd
# Renderiza o fundo do jogo como um grid de tiles pixel art.
# Segue a câmera para criar a ilusão de mundo infinito.
extends Node2D

const TILE_SIZE: int = 16       # Tamanho de cada tile em pixels
const TILES_VISIBLE: int = 50   # Quantos tiles renderizar em cada direção

var _tile_texture: ImageTexture = null
var _camera: Camera2D = null

func _ready() -> void:
	# Gera a textura do tile
	_tile_texture = SpriteGenerator.get_background_tile_texture()
	# Busca a câmera
	_camera = get_tree().get_first_node_in_group("main_camera")
	# Desenha o fundo inicial
	queue_redraw()

func _process(_delta: float) -> void:
	# Redesenha quando a câmera se move (snap ao grid para efeito pixel art)
	queue_redraw()

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
	
	# Área de renderização
	var start_x: int = int(cam_pos.x) - TILES_VISIBLE * TILE_SIZE - offset_x
	var start_y: int = int(cam_pos.y) - TILES_VISIBLE * TILE_SIZE - offset_y
	
	for ty in range(TILES_VISIBLE * 2 + 2):
		for tx in range(TILES_VISIBLE * 2 + 2):
			var tile_pos = Vector2(
				start_x + tx * TILE_SIZE,
				start_y + ty * TILE_SIZE
			)
			draw_texture(_tile_texture, tile_pos)
	
	# Desenha linhas de grid sutis para dar profundidade
	var grid_color = Color(0.12, 0.12, 0.18, 0.4)
	for ty in range(TILES_VISIBLE * 2 + 2):
		var y_pos = start_y + ty * TILE_SIZE
		draw_line(
			Vector2(start_x, y_pos),
			Vector2(start_x + (TILES_VISIBLE * 2 + 2) * TILE_SIZE, y_pos),
			grid_color, 0.5
		)
	for tx in range(TILES_VISIBLE * 2 + 2):
		var x_pos = start_x + tx * TILE_SIZE
		draw_line(
			Vector2(x_pos, start_y),
			Vector2(x_pos, start_y + (TILES_VISIBLE * 2 + 2) * TILE_SIZE),
			grid_color, 0.5
		)
