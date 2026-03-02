extends Area2D

@export var powerup_id: String = "frenzy"
@export var duration: float = 10.0

@onready var sprite: Sprite2D = $Sprite2D

var _base_y: float = 0.0
var _time: float = 0.0

func _ready() -> void:
	add_to_group("powerups")
	body_entered.connect(_on_body_entered)
	if sprite:
		sprite.texture = SpriteGenerator.get_projectile_texture()
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		sprite.modulate = _get_color_for_powerup(powerup_id)
		_base_y = sprite.position.y

func setup(id: String, buff_duration: float) -> void:
	powerup_id = id
	duration = buff_duration
	if sprite:
		sprite.modulate = _get_color_for_powerup(powerup_id)

func _process(delta: float) -> void:
	_time += delta
	if sprite:
		sprite.position.y = _base_y + sin(_time * 5.0) * 3.0
		sprite.rotation = sin(_time * 3.0) * 0.1

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	GameManager.apply_temporary_powerup(powerup_id, duration)
	PixelEffects.spawn_level_up_effect(global_position)
	if AudioManager:
		AudioManager.play_upgrade_select()
	queue_free()

func _get_color_for_powerup(id: String) -> Color:
	match id:
		"frenzy":
			return Color(1.0, 0.35, 0.25)
		"shield":
			return Color(0.25, 0.95, 1.0)
		"haste":
			return Color(1.0, 1.0, 0.35)
		"sword_mode":
			return Color(0.95, 0.95, 1.0)
		"magic_mode":
			return Color(0.85, 0.35, 1.0)
		_:
			return Color(0.7, 1.0, 0.7)
