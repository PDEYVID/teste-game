# NotificationSystem.gd
# Sistema de notificações para conquistas e eventos
# Mostra mensagens elegantes no topo da tela
extends CanvasLayer

var notification_queue: Array = []
var is_showing: bool = false

func _ready() -> void:
	layer = 90  # Acima do HUD mas abaixo dos efeitos
	add_to_group("notifications")

func show_notification(text: String, icon: String = "⭐", color: Color = Color(1.0, 0.9, 0.2), duration: float = 3.0) -> void:
	"""Mostra uma notificação na tela."""
	notification_queue.append({
		"text": text,
		"icon": icon,
		"color": color,
		"duration": duration
	})
	
	if not is_showing:
		_show_next_notification()

func _show_next_notification() -> void:
	"""Mostra a próxima notificação da fila."""
	if notification_queue.is_empty():
		is_showing = false
		return
	
	is_showing = true
	var notif = notification_queue.pop_front()
	
	# Container da notificação
	var container = Control.new()
	container.set_anchors_preset(Control.PRESET_TOP_WIDE)
	container.custom_minimum_size = Vector2(0, 80)
	add_child(container)
	
	# Painel de fundo
	var panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER_TOP)
	panel.position = Vector2(0, 20)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.15, 0.95)
	style.border_color = notif["color"]
	style.set_border_width_all(3)
	style.content_margin_left = 20
	style.content_margin_right = 20
	style.content_margin_top = 15
	style.content_margin_bottom = 15
	panel.add_theme_stylebox_override("panel", style)
	container.add_child(panel)
	
	# Texto da notificação
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 15)
	panel.add_child(hbox)
	
	var icon_label = Label.new()
	icon_label.text = notif["icon"]
	icon_label.add_theme_font_size_override("font_size", 32)
	hbox.add_child(icon_label)
	
	var text_label = Label.new()
	text_label.text = notif["text"]
	text_label.add_theme_font_size_override("font_size", 24)
	text_label.add_theme_color_override("font_color", notif["color"])
	text_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.9))
	text_label.add_theme_constant_override("shadow_offset_x", 2)
	text_label.add_theme_constant_override("shadow_offset_y", 2)
	hbox.add_child(text_label)
	
	# Animação de entrada
	panel.modulate.a = 0.0
	panel.position.y = -50
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(panel, "modulate:a", 1.0, 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(panel, "position:y", 20, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	# Aguarda duração
	await get_tree().create_timer(notif["duration"]).timeout
	
	# Animação de saída
	var exit_tween = create_tween()
	exit_tween.set_parallel(true)
	exit_tween.tween_property(panel, "modulate:a", 0.0, 0.3)
	exit_tween.tween_property(panel, "position:y", -50, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	await exit_tween.finished
	
	container.queue_free()
	
	# Mostra próxima notificação
	_show_next_notification()

# Notificações pré-definidas
func notify_level_up(level: int) -> void:
	show_notification("NÍVEL %d ALCANÇADO!" % level, "⭐", Color(1.0, 0.9, 0.2))

func notify_achievement(text: String) -> void:
	show_notification(text, "🏆", Color(1.0, 0.85, 0.0))

func notify_danger(text: String) -> void:
	show_notification(text, "⚠", Color(1.0, 0.3, 0.3))

func notify_boss_spawn() -> void:
	show_notification("BOSS APARECEU!", "💀", Color(0.8, 0.2, 1.0), 4.0)
