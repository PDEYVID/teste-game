# SpriteGenerator.gd
# Gera sprites pixel art proceduralmente usando Image + ImageTexture.
# Isso elimina a necessidade de arquivos externos e garante o estilo pixel art.
# Usado como Autoload para que qualquer cena possa pedir um sprite.
extends Node

# Paleta de cores do jogo (estilo pixel art retrô)
const PALETTE = {
	"transparent": Color(0, 0, 0, 0),
	"black": Color(0.05, 0.05, 0.08),
	"dark_gray": Color(0.15, 0.15, 0.2),
	"gray": Color(0.4, 0.4, 0.5),
	"white": Color(0.95, 0.95, 1.0),
	# Player - azul ciano
	"player_dark": Color(0.0, 0.3, 0.6),
	"player_mid": Color(0.1, 0.6, 0.9),
	"player_light": Color(0.4, 0.85, 1.0),
	"player_highlight": Color(0.8, 0.95, 1.0),
	# Inimigo - vermelho
	"enemy_dark": Color(0.4, 0.0, 0.0),
	"enemy_mid": Color(0.75, 0.1, 0.1),
	"enemy_light": Color(1.0, 0.25, 0.2),
	"enemy_eye": Color(1.0, 0.85, 0.0),
	"enemy_eye_glow": Color(1.0, 0.5, 0.0),
	# Projétil - amarelo/dourado
	"proj_core": Color(1.0, 1.0, 0.6),
	"proj_mid": Color(1.0, 0.8, 0.1),
	"proj_outer": Color(0.9, 0.4, 0.0),
	"proj_glow": Color(1.0, 0.9, 0.3, 0.6),
	# XP orb - verde
	"xp_core": Color(0.5, 1.0, 0.3),
	"xp_mid": Color(0.2, 0.8, 0.1),
	"xp_dark": Color(0.1, 0.4, 0.05),
}

# Cache de texturas geradas
var _texture_cache: Dictionary = {}

func get_player_texture() -> ImageTexture:
	return _get_cached("player", _create_player_image)

func get_enemy_texture() -> ImageTexture:
	return _get_cached("enemy", _create_enemy_image)

func get_projectile_texture() -> ImageTexture:
	return _get_cached("projectile", _create_projectile_image)

func get_xp_orb_texture() -> ImageTexture:
	return _get_cached("xp_orb", _create_xp_orb_image)

func get_background_tile_texture() -> ImageTexture:
	return _get_cached("bg_tile", _create_background_tile_image)

# Novos tipos de inimigos
func get_enemy_fast_texture() -> ImageTexture:
	return _get_cached("enemy_fast", _create_enemy_fast_image)

func get_enemy_tank_texture() -> ImageTexture:
	return _get_cached("enemy_tank", _create_enemy_tank_image)

func get_enemy_boss_texture() -> ImageTexture:
	return _get_cached("enemy_boss", _create_enemy_boss_image)

# Novos projéteis
func get_laser_texture() -> ImageTexture:
	return _get_cached("laser", _create_laser_image)

func get_explosion_texture() -> ImageTexture:
	return _get_cached("explosion", _create_explosion_image)

func _get_cached(key: String, creator: Callable) -> ImageTexture:
	if _texture_cache.has(key):
		return _texture_cache[key]
	var tex = creator.call()
	_texture_cache[key] = tex
	print("Sprite gerado: ", key, " - Tamanho: ", tex.get_width(), "x", tex.get_height())
	return tex

func _image_from_pixels(pixel_map: Array, scale: int = 1) -> ImageTexture:
	"""Converte um array 2D de cores em ImageTexture com escala pixel art."""
	var height = pixel_map.size()
	var width = pixel_map[0].size()
	var img = Image.create(width * scale, height * scale, false, Image.FORMAT_RGBA8)
	
	for y in range(height):
		for x in range(width):
			var color: Color = pixel_map[y][x]
			# Preenche o bloco de pixels (scale x scale)
			for sy in range(scale):
				for sx in range(scale):
					img.set_pixel(x * scale + sx, y * scale + sy, color)
	
	var tex = ImageTexture.create_from_image(img)
	return tex

func _create_player_image() -> ImageTexture:
	"""
	Sprite do player: guerreiro épico 16x16 pixel art, vista top-down.
	Azul ciano com armadura detalhada, capacete com pluma e capa.
	"""
	var T = PALETTE["transparent"]
	var B = PALETTE["black"]
	var PD = PALETTE["player_dark"]
	var PM = PALETTE["player_mid"]
	var PL = PALETTE["player_light"]
	var PH = PALETTE["player_highlight"]
	var W = PALETTE["white"]
	var G = PALETTE["gray"]
	var DG = PALETTE["dark_gray"]
	var GOLD = Color(1.0, 0.85, 0.0)
	var CAPE = Color(0.6, 0.0, 0.8)
	
	var pixels = [
		[T,  T,  T,  T,  GOLD,GOLD,PD, PD, PD, PD, GOLD,GOLD,T,  T,  T,  T ],
		[T,  T,  T,  GOLD,PD, PM, PM, PL, PL, PM, PM, PD, GOLD,T,  T,  T ],
		[T,  T,  CAPE,PD, PM, PL, PH, W,  W,  PH, PL, PM, PD, CAPE,T,  T ],
		[T,  CAPE,PD, PM, PL, PH, PH, PL, PL, PH, PH, PL, PM, PD, CAPE,T ],
		[T,  CAPE,PD, PM, PL, W,  PL, B,  B,  PL, W,  PL, PM, PD, CAPE,T ],
		[CAPE,CAPE,PD, PM, PM, PL, PL, PL, PL, PL, PL, PM, PM, PD, CAPE,CAPE],
		[CAPE,T,  T,  PD, PM, PM, GOLD,PM, PM, GOLD,PM, PM, PD, T,  T,  CAPE],
		[T,  T,  T,  T,  PD, GOLD,GOLD,PD, PD, GOLD,GOLD,PD, T,  T,  T,  T ],
		[T,  T,  T,  PD, PM, PM, PM, PM, PM, PM, PM, PM, PD, T,  T,  T ],
		[T,  T,  PD, PM, PL, PL, PM, GOLD,GOLD,PM, PL, PL, PM, PD, T,  T ],
		[T,  PD, PM, PL, PH, PL, PD, T,  T,  PD, PL, PH, PL, PM, PD, T ],
		[T,  PD, PM, PL, PL, PD, T,  T,  T,  T,  PD, PL, PL, PM, PD, T ],
		[T,  T,  PD, PM, PD, T,  T,  T,  T,  T,  T,  PD, PM, PD, T,  T ],
		[T,  T,  T,  PD, PM, PD, T,  T,  T,  T,  PD, PM, PD, T,  T,  T ],
		[T,  T,  T,  T,  PD, PM, PD, T,  T,  PD, PM, PD, T,  T,  T,  T ],
		[T,  T,  T,  T,  T,  PD, PD, T,  T,  PD, PD, T,  T,  T,  T,  T ],
	]
	return _image_from_pixels(pixels, 3)  # 3x scale = 48x48 pixels

func _create_enemy_image() -> ImageTexture:
	"""
	Sprite do inimigo: demônio/zumbi 16x16 pixel art, vista top-down.
	Vermelho escuro com olhos brilhantes, chifres e detalhes assustadores.
	"""
	var T = PALETTE["transparent"]
	var B = PALETTE["black"]
	var ED = PALETTE["enemy_dark"]
	var EM = PALETTE["enemy_mid"]
	var EL = PALETTE["enemy_light"]
	var EY = PALETTE["enemy_eye"]
	var EG = PALETTE["enemy_eye_glow"]
	var HORN = Color(0.3, 0.0, 0.0)
	
	var pixels = [
		[T,  T,  HORN,T,  T,  ED, ED, T,  T,  ED, ED, T,  T,  HORN,T,  T ],
		[T,  T,  T,  HORN,ED, EM, EM, ED, ED, EM, EM, ED, HORN,T,  T,  T ],
		[T,  T,  T,  ED, EM, EL, EL, EM, EM, EL, EL, EM, ED, T,  T,  T ],
		[T,  T,  ED, EM, EL, EL, EL, EL, EL, EL, EL, EL, EM, ED, T,  T ],
		[T,  T,  ED, EM, B,  EY, EG, EL, EL, EG, EY, B,  EM, ED, T,  T ],
		[T,  T,  ED, EM, EL, EG, EY, EL, EL, EY, EG, EL, EM, ED, T,  T ],
		[T,  T,  ED, EM, EL, EL, EL, B,  B,  EL, EL, EL, EM, ED, T,  T ],
		[T,  T,  T,  ED, EM, EL, B,  B,  B,  B,  EL, EM, ED, T,  T,  T ],
		[T,  T,  T,  ED, EM, EM, B,  EM, EM, B,  EM, EM, ED, T,  T,  T ],
		[T,  T,  ED, EM, EL, EL, EM, ED, ED, EM, EL, EL, EM, ED, T,  T ],
		[T,  ED, EM, EL, EL, EL, ED, T,  T,  ED, EL, EL, EL, EM, ED, T ],
		[T,  ED, EM, EL, EL, ED, T,  T,  T,  T,  ED, EL, EL, EM, ED, T ],
		[T,  T,  ED, EM, ED, T,  T,  T,  T,  T,  T,  ED, EM, ED, T,  T ],
		[T,  T,  T,  ED, EM, ED, T,  T,  T,  T,  ED, EM, ED, T,  T,  T ],
		[T,  T,  T,  T,  ED, EM, ED, T,  T,  ED, EM, ED, T,  T,  T,  T ],
		[T,  T,  T,  T,  T,  ED, ED, T,  T,  ED, ED, T,  T,  T,  T,  T ],
	]
	return _image_from_pixels(pixels, 3)  # 48x48 pixels

func _create_projectile_image() -> ImageTexture:
	"""
	Sprite do projétil: orbe mágico 8x8 pixel art.
	Amarelo dourado brilhante.
	"""
	var T = PALETTE["transparent"]
	var PC = PALETTE["proj_core"]
	var PM = PALETTE["proj_mid"]
	var PO = PALETTE["proj_outer"]
	var PG = PALETTE["proj_glow"]
	
	var pixels = [
		[T,  T,  PO, PO, PO, PO, T,  T ],
		[T,  PO, PM, PM, PM, PM, PO, T ],
		[PO, PM, PM, PC, PC, PM, PM, PO],
		[PO, PM, PC, PC, PC, PC, PM, PO],
		[PO, PM, PC, PC, PC, PC, PM, PO],
		[PO, PM, PM, PC, PC, PM, PM, PO],
		[T,  PO, PM, PM, PM, PM, PO, T ],
		[T,  T,  PO, PO, PO, PO, T,  T ],
	]
	return _image_from_pixels(pixels, 3)  # 24x24 pixels

func _create_xp_orb_image() -> ImageTexture:
	"""
	Sprite do orbe de XP: cristal verde 8x8 pixel art.
	"""
	var T = PALETTE["transparent"]
	var XC = PALETTE["xp_core"]
	var XM = PALETTE["xp_mid"]
	var XD = PALETTE["xp_dark"]
	var W = PALETTE["white"]
	
	var pixels = [
		[T,  T,  XD, XD, XD, T,  T,  T ],
		[T,  XD, XM, XM, XM, XD, T,  T ],
		[XD, XM, XC, W,  XC, XM, XD, T ],
		[XD, XM, XC, XC, XC, XM, XD, T ],
		[XD, XM, XM, XC, XM, XM, XD, T ],
		[T,  XD, XM, XM, XM, XD, T,  T ],
		[T,  T,  XD, XD, XD, T,  T,  T ],
		[T,  T,  T,  T,  T,  T,  T,  T ],
	]
	return _image_from_pixels(pixels, 3)  # 24x24 pixels

func _create_background_tile_image() -> ImageTexture:
	"""
	Tile de fundo: pedra/terra escura 16x16 pixel art para criar grid.
	"""
	var C1 = Color(0.08, 0.08, 0.13)  # base escura
	var C2 = Color(0.10, 0.10, 0.16)  # variação leve
	var C3 = Color(0.06, 0.06, 0.10)  # sombra
	var C4 = Color(0.12, 0.12, 0.18)  # highlight sutil
	
	var pixels = [
		[C1, C1, C2, C1, C1, C3, C1, C2, C1, C1, C2, C1, C3, C1, C1, C2],
		[C1, C4, C1, C1, C2, C1, C1, C1, C2, C1, C1, C4, C1, C1, C2, C1],
		[C2, C1, C1, C3, C1, C1, C2, C1, C1, C3, C1, C1, C2, C1, C1, C1],
		[C1, C1, C2, C1, C4, C1, C1, C1, C2, C1, C1, C1, C1, C3, C1, C2],
		[C3, C1, C1, C1, C1, C2, C1, C3, C1, C1, C2, C1, C1, C1, C4, C1],
		[C1, C2, C1, C1, C3, C1, C1, C1, C1, C2, C1, C1, C3, C1, C1, C1],
		[C1, C1, C4, C1, C1, C1, C2, C1, C1, C1, C4, C1, C1, C1, C2, C3],
		[C2, C1, C1, C2, C1, C3, C1, C1, C2, C1, C1, C2, C1, C4, C1, C1],
		[C1, C3, C1, C1, C1, C1, C4, C2, C1, C3, C1, C1, C1, C1, C3, C1],
		[C1, C1, C2, C1, C2, C1, C1, C1, C1, C1, C2, C1, C2, C1, C1, C4],
		[C4, C1, C1, C3, C1, C1, C1, C4, C2, C1, C1, C3, C1, C1, C1, C1],
		[C1, C1, C1, C1, C4, C2, C1, C1, C1, C1, C1, C1, C4, C2, C1, C1],
		[C1, C2, C3, C1, C1, C1, C3, C1, C1, C2, C3, C1, C1, C1, C3, C2],
		[C3, C1, C1, C1, C1, C4, C1, C2, C3, C1, C1, C1, C1, C4, C1, C1],
		[C1, C1, C4, C2, C1, C1, C1, C1, C1, C1, C4, C2, C1, C1, C1, C3],
		[C2, C1, C1, C1, C3, C1, C2, C1, C2, C1, C1, C1, C3, C1, C2, C1],
	]
	return _image_from_pixels(pixels, 1)


func _create_enemy_fast_image() -> ImageTexture:
	"""
	Inimigo rápido: criatura ágil verde/azul com design aerodinâmico.
	"""
	var T = PALETTE["transparent"]
	var B = PALETTE["black"]
	var FAST_D = Color(0.0, 0.4, 0.5)
	var FAST_M = Color(0.1, 0.7, 0.8)
	var FAST_L = Color(0.3, 0.9, 1.0)
	var EY = PALETTE["enemy_eye"]
	var W = PALETTE["white"]
	
	var pixels = [
		[T,  T,  T,  T,  T,  T,  FAST_D,FAST_D,FAST_D,FAST_D,T,  T,  T,  T,  T,  T ],
		[T,  T,  T,  T,  FAST_D,FAST_M,FAST_M,FAST_L,FAST_L,FAST_M,FAST_M,FAST_D,T,  T,  T,  T ],
		[T,  T,  T,  FAST_D,FAST_M,FAST_L,FAST_L,W,  W,  FAST_L,FAST_L,FAST_M,FAST_D,T,  T,  T ],
		[T,  T,  FAST_D,FAST_M,FAST_L,W,  FAST_L,FAST_L,FAST_L,FAST_L,W,  FAST_L,FAST_M,FAST_D,T,  T ],
		[T,  T,  FAST_D,FAST_M,FAST_L,B,  EY, FAST_L,FAST_L,EY, B,  FAST_L,FAST_M,FAST_D,T,  T ],
		[T,  T,  FAST_D,FAST_M,FAST_M,FAST_L,FAST_L,FAST_L,FAST_L,FAST_L,FAST_L,FAST_M,FAST_M,FAST_D,T,  T ],
		[T,  T,  T,  FAST_D,FAST_M,FAST_M,FAST_M,FAST_M,FAST_M,FAST_M,FAST_M,FAST_M,FAST_D,T,  T,  T ],
		[T,  T,  T,  T,  FAST_D,FAST_D,FAST_M,FAST_M,FAST_M,FAST_M,FAST_D,FAST_D,T,  T,  T,  T ],
		[T,  T,  T,  FAST_D,FAST_M,FAST_M,FAST_M,FAST_M,FAST_M,FAST_M,FAST_M,FAST_M,FAST_D,T,  T,  T ],
		[T,  T,  FAST_D,FAST_M,FAST_L,FAST_L,FAST_M,FAST_D,FAST_D,FAST_M,FAST_L,FAST_L,FAST_M,FAST_D,T,  T ],
		[T,  FAST_D,FAST_M,FAST_L,FAST_L,FAST_L,FAST_D,T,  T,  FAST_D,FAST_L,FAST_L,FAST_L,FAST_M,FAST_D,T ],
		[T,  FAST_D,FAST_M,FAST_L,FAST_L,FAST_D,T,  T,  T,  T,  FAST_D,FAST_L,FAST_L,FAST_M,FAST_D,T ],
		[T,  T,  FAST_D,FAST_M,FAST_D,T,  T,  T,  T,  T,  T,  FAST_D,FAST_M,FAST_D,T,  T ],
		[T,  T,  T,  FAST_D,FAST_M,FAST_D,T,  T,  T,  T,  FAST_D,FAST_M,FAST_D,T,  T,  T ],
		[T,  T,  T,  T,  FAST_D,FAST_M,FAST_D,T,  T,  FAST_D,FAST_M,FAST_D,T,  T,  T,  T ],
		[T,  T,  T,  T,  T,  FAST_D,FAST_D,T,  T,  FAST_D,FAST_D,T,  T,  T,  T,  T ],
	]
	return _image_from_pixels(pixels, 3)

func _create_enemy_tank_image() -> ImageTexture:
	"""
	Inimigo tanque: criatura grande e robusta laranja/marrom.
	"""
	var T = PALETTE["transparent"]
	var B = PALETTE["black"]
	var TANK_D = Color(0.5, 0.25, 0.0)
	var TANK_M = Color(0.8, 0.4, 0.1)
	var TANK_L = Color(1.0, 0.6, 0.2)
	var ARMOR = Color(0.3, 0.3, 0.35)
	var EY = Color(1.0, 0.3, 0.0)
	
	var pixels = [
		[T,  T,  T,  ARMOR,ARMOR,TANK_D,TANK_D,TANK_D,TANK_D,TANK_D,TANK_D,ARMOR,ARMOR,T,  T,  T ],
		[T,  T,  ARMOR,TANK_D,TANK_M,TANK_M,TANK_M,TANK_L,TANK_L,TANK_M,TANK_M,TANK_M,TANK_D,ARMOR,T,  T ],
		[T,  ARMOR,TANK_D,TANK_M,TANK_L,TANK_L,TANK_L,TANK_L,TANK_L,TANK_L,TANK_L,TANK_L,TANK_M,TANK_D,ARMOR,T ],
		[ARMOR,TANK_D,TANK_M,TANK_L,TANK_L,TANK_L,TANK_L,TANK_L,TANK_L,TANK_L,TANK_L,TANK_L,TANK_L,TANK_M,TANK_D,ARMOR],
		[ARMOR,TANK_D,TANK_M,TANK_L,ARMOR,B,  EY, TANK_L,TANK_L,EY, B,  ARMOR,TANK_L,TANK_M,TANK_D,ARMOR],
		[ARMOR,TANK_D,TANK_M,TANK_M,TANK_L,TANK_L,TANK_L,TANK_L,TANK_L,TANK_L,TANK_L,TANK_L,TANK_M,TANK_M,TANK_D,ARMOR],
		[T,  ARMOR,TANK_D,TANK_M,TANK_M,TANK_M,ARMOR,TANK_M,TANK_M,ARMOR,TANK_M,TANK_M,TANK_M,TANK_D,ARMOR,T ],
		[T,  T,  ARMOR,TANK_D,TANK_D,ARMOR,ARMOR,TANK_D,TANK_D,ARMOR,ARMOR,TANK_D,TANK_D,ARMOR,T,  T ],
		[T,  T,  ARMOR,TANK_D,TANK_M,TANK_M,TANK_M,TANK_M,TANK_M,TANK_M,TANK_M,TANK_M,TANK_D,ARMOR,T,  T ],
		[T,  ARMOR,TANK_D,TANK_M,TANK_L,TANK_L,TANK_M,TANK_D,TANK_D,TANK_M,TANK_L,TANK_L,TANK_M,TANK_D,ARMOR,T ],
		[ARMOR,TANK_D,TANK_M,TANK_L,TANK_L,TANK_L,TANK_D,ARMOR,ARMOR,TANK_D,TANK_L,TANK_L,TANK_L,TANK_M,TANK_D,ARMOR],
		[ARMOR,TANK_D,TANK_M,TANK_L,TANK_L,TANK_D,ARMOR,T,  T,  ARMOR,TANK_D,TANK_L,TANK_L,TANK_M,TANK_D,ARMOR],
		[T,  ARMOR,TANK_D,TANK_M,TANK_D,ARMOR,T,  T,  T,  T,  ARMOR,TANK_D,TANK_M,TANK_D,ARMOR,T ],
		[T,  T,  ARMOR,TANK_D,TANK_M,TANK_D,ARMOR,T,  T,  ARMOR,TANK_D,TANK_M,TANK_D,ARMOR,T,  T ],
		[T,  T,  T,  ARMOR,TANK_D,TANK_M,TANK_D,ARMOR,ARMOR,TANK_D,TANK_M,TANK_D,ARMOR,T,  T,  T ],
		[T,  T,  T,  T,  ARMOR,TANK_D,TANK_D,ARMOR,ARMOR,TANK_D,TANK_D,ARMOR,T,  T,  T,  T ],
	]
	return _image_from_pixels(pixels, 3)

func _create_enemy_boss_image() -> ImageTexture:
	"""
	Boss: criatura épica roxa/preta com aura de poder.
	"""
	var T = PALETTE["transparent"]
	var B = PALETTE["black"]
	var BOSS_D = Color(0.2, 0.0, 0.3)
	var BOSS_M = Color(0.5, 0.1, 0.6)
	var BOSS_L = Color(0.8, 0.3, 0.9)
	var AURA = Color(0.9, 0.2, 1.0, 0.7)
	var EY = Color(1.0, 0.0, 0.0)
	var CROWN = Color(1.0, 0.85, 0.0)
	
	var pixels = [
		[T,  T,  CROWN,T,  CROWN,BOSS_D,BOSS_D,CROWN,CROWN,BOSS_D,BOSS_D,CROWN,T,  CROWN,T,  T ],
		[T,  T,  T,  CROWN,BOSS_D,BOSS_M,BOSS_M,BOSS_D,BOSS_D,BOSS_M,BOSS_M,BOSS_D,CROWN,T,  T,  T ],
		[T,  AURA,T,  BOSS_D,BOSS_M,BOSS_L,BOSS_L,BOSS_M,BOSS_M,BOSS_L,BOSS_L,BOSS_M,BOSS_D,T,  AURA,T ],
		[T,  AURA,BOSS_D,BOSS_M,BOSS_L,BOSS_L,BOSS_L,BOSS_L,BOSS_L,BOSS_L,BOSS_L,BOSS_L,BOSS_M,BOSS_D,AURA,T ],
		[AURA,AURA,BOSS_D,BOSS_M,B,  EY, EY, BOSS_L,BOSS_L,EY, EY, B,  BOSS_M,BOSS_D,AURA,AURA],
		[AURA,AURA,BOSS_D,BOSS_M,BOSS_L,EY, EY, BOSS_L,BOSS_L,EY, EY, BOSS_L,BOSS_M,BOSS_D,AURA,AURA],
		[T,  AURA,BOSS_D,BOSS_M,BOSS_L,BOSS_L,B,  B,  B,  B,  BOSS_L,BOSS_L,BOSS_M,BOSS_D,AURA,T ],
		[T,  T,  BOSS_D,BOSS_M,BOSS_M,B,  B,  B,  B,  B,  B,  BOSS_M,BOSS_M,BOSS_D,T,  T ],
		[T,  AURA,BOSS_D,BOSS_M,BOSS_M,BOSS_M,B,  BOSS_M,BOSS_M,B,  BOSS_M,BOSS_M,BOSS_M,BOSS_D,AURA,T ],
		[AURA,AURA,BOSS_D,BOSS_M,BOSS_L,BOSS_L,BOSS_M,BOSS_D,BOSS_D,BOSS_M,BOSS_L,BOSS_L,BOSS_M,BOSS_D,AURA,AURA],
		[AURA,BOSS_D,BOSS_M,BOSS_L,BOSS_L,BOSS_L,BOSS_D,AURA,AURA,BOSS_D,BOSS_L,BOSS_L,BOSS_L,BOSS_M,BOSS_D,AURA],
		[AURA,BOSS_D,BOSS_M,BOSS_L,BOSS_L,BOSS_D,AURA,T,  T,  AURA,BOSS_D,BOSS_L,BOSS_L,BOSS_M,BOSS_D,AURA],
		[T,  AURA,BOSS_D,BOSS_M,BOSS_D,AURA,T,  T,  T,  T,  AURA,BOSS_D,BOSS_M,BOSS_D,AURA,T ],
		[T,  T,  AURA,BOSS_D,BOSS_M,BOSS_D,AURA,T,  T,  AURA,BOSS_D,BOSS_M,BOSS_D,AURA,T,  T ],
		[T,  T,  T,  AURA,BOSS_D,BOSS_M,BOSS_D,AURA,AURA,BOSS_D,BOSS_M,BOSS_D,AURA,T,  T,  T ],
		[T,  T,  T,  T,  AURA,BOSS_D,BOSS_D,AURA,AURA,BOSS_D,BOSS_D,AURA,T,  T,  T,  T ],
	]
	return _image_from_pixels(pixels, 4)  # Boss é maior: 64x64

func _create_laser_image() -> ImageTexture:
	"""
	Projétil laser: feixe de energia azul elétrico.
	"""
	var T = PALETTE["transparent"]
	var LASER_C = Color(0.5, 0.8, 1.0)
	var LASER_M = Color(0.2, 0.5, 1.0)
	var LASER_O = Color(0.0, 0.2, 0.8)
	var W = PALETTE["white"]
	
	var pixels = [
		[T,  T,  LASER_O,LASER_M,LASER_M,LASER_O,T,  T ],
		[T,  LASER_O,LASER_M,LASER_C,LASER_C,LASER_M,LASER_O,T ],
		[LASER_O,LASER_M,LASER_C,W,  W,  LASER_C,LASER_M,LASER_O],
		[LASER_M,LASER_C,W,  W,  W,  W,  LASER_C,LASER_M],
		[LASER_M,LASER_C,W,  W,  W,  W,  LASER_C,LASER_M],
		[LASER_O,LASER_M,LASER_C,W,  W,  LASER_C,LASER_M,LASER_O],
		[T,  LASER_O,LASER_M,LASER_C,LASER_C,LASER_M,LASER_O,T ],
		[T,  T,  LASER_O,LASER_M,LASER_M,LASER_O,T,  T ],
	]
	return _image_from_pixels(pixels, 3)

func _create_explosion_image() -> ImageTexture:
	"""
	Projétil explosivo: bomba vermelha/laranja.
	"""
	var T = PALETTE["transparent"]
	var B = PALETTE["black"]
	var EXP_C = Color(1.0, 1.0, 0.3)
	var EXP_M = Color(1.0, 0.5, 0.0)
	var EXP_O = Color(0.8, 0.0, 0.0)
	
	var pixels = [
		[T,  T,  EXP_O,EXP_O,EXP_O,EXP_O,T,  T ],
		[T,  EXP_O,EXP_M,EXP_M,EXP_M,EXP_M,EXP_O,T ],
		[EXP_O,EXP_M,EXP_M,EXP_C,EXP_C,EXP_M,EXP_M,EXP_O],
		[EXP_O,EXP_M,EXP_C,EXP_C,EXP_C,EXP_C,EXP_M,EXP_O],
		[EXP_O,EXP_M,EXP_C,EXP_C,EXP_C,EXP_C,EXP_M,EXP_O],
		[EXP_O,EXP_M,EXP_M,EXP_C,EXP_C,EXP_M,EXP_M,EXP_O],
		[T,  EXP_O,EXP_M,EXP_M,EXP_M,EXP_M,EXP_O,T ],
		[T,  T,  EXP_O,EXP_O,EXP_O,EXP_O,T,  T ],
	]
	return _image_from_pixels(pixels, 3)
