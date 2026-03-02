# GameOverScreen.gd
# Tela de Game Over estilo Vampire Survivors
# Mostra estatísticas da run e botão de reiniciar
extends CanvasLayer

var time_label: Label
var stats_label: Label
var restart_button: Button
var main_container: Control  # Container principal para animações
var _panel_style: StyleBoxFlat
var _hint_label: Label
var _hint_tween: Tween

func _ready() -> void:
	_create_game_over_screen()
	GameManager.game_over.connect(_on_game_over)
	visible = false

func _create_game_over_screen() -> void:
	"""Cria a tela de game over programaticamente."""
	# Fundo escuro
	var bg = ColorRect.new()
	bg.color = Color(0.0, 0.0, 0.0, 0.9)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	
	# Container principal (para animações)
	main_container = Control.new()
	main_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(main_container)
	
	# Container central
	var center = Control.new()
	center.set_anchors_preset(Control.PRESET_CENTER)
	center.custom_minimum_size = Vector2(600, 500)
	center.position = Vector2(-300, -250)
	main_container.add_child(center)
	
	# Painel principal
	var panel = PanelContainer.new()
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.1, 0.2)
	style.border_color = Color(0.8, 0.2, 0.2)
	style.set_border_width_all(6)
	panel.add_theme_stylebox_override("panel", style)
	_panel_style = style
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.add_child(panel)
	
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 25)
	panel.add_child(vbox)
	
	# Título GAME OVER com sombra
	var title = Label.new()
	title.text = "💀 GAME OVER 💀"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 56)
	title.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))
	title.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 1.0))
	title.add_theme_constant_override("shadow_offset_x", 4)
	title.add_theme_constant_override("shadow_offset_y", 4)
	vbox.add_child(title)
	
	# Tempo sobrevivido com sombra
	time_label = Label.new()
	time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	time_label.add_theme_font_size_override("font_size", 36)
	time_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3))
	time_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.9))
	time_label.add_theme_constant_override("shadow_offset_x", 3)
	time_label.add_theme_constant_override("shadow_offset_y", 3)
	vbox.add_child(time_label)
	
	# Estatísticas da run com sombra
	stats_label = Label.new()
	stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_label.add_theme_font_size_override("font_size", 22)
	stats_label.add_theme_color_override("font_color", Color(0.9, 0.9, 1.0))
	stats_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.8))
	stats_label.add_theme_constant_override("shadow_offset_x", 2)
	stats_label.add_theme_constant_override("shadow_offset_y", 2)
	vbox.add_child(stats_label)
	
	# Botão de reiniciar com estilo melhorado
	restart_button = Button.new()
	restart_button.text = "🔄 JOGAR NOVAMENTE"
	restart_button.custom_minimum_size = Vector2(320, 70)
	restart_button.add_theme_font_size_override("font_size", 26)
	
	# Estilo do botão
	var btn_normal = StyleBoxFlat.new()
	btn_normal.bg_color = Color(0.2, 0.5, 0.8)
	btn_normal.border_color = Color(0.4, 0.7, 1.0)
	btn_normal.set_border_width_all(4)
	restart_button.add_theme_stylebox_override("normal", btn_normal)
	
	var btn_hover = StyleBoxFlat.new()
	btn_hover.bg_color = Color(0.3, 0.6, 1.0)
	btn_hover.border_color = Color(0.5, 0.8, 1.0)
	btn_hover.set_border_width_all(4)
	restart_button.add_theme_stylebox_override("hover", btn_hover)
	
	var btn_pressed = StyleBoxFlat.new()
	btn_pressed.bg_color = Color(0.1, 0.3, 0.6)
	btn_pressed.border_color = Color(0.3, 0.5, 0.8)
	btn_pressed.set_border_width_all(4)
	restart_button.add_theme_stylebox_override("pressed", btn_pressed)
	
	restart_button.pressed.connect(_on_restart_pressed)
	
	# Efeito de hover no botão
	restart_button.mouse_entered.connect(func():
		var tween = create_tween()
		tween.tween_property(restart_button, "scale", Vector2(1.1, 1.1), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	)
	restart_button.mouse_exited.connect(func():
		var tween = create_tween()
		tween.tween_property(restart_button, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	)
	
	vbox.add_child(restart_button)

	_hint_label = Label.new()
	_hint_label.text = "ENTER para reiniciar"
	_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint_label.add_theme_font_size_override("font_size", 16)
	_hint_label.add_theme_color_override("font_color", Color(0.85, 0.9, 1.0, 0.9))
	_hint_label.modulate.a = 0.0
	vbox.add_child(_hint_label)

func _on_game_over(survived_time: float) -> void:
	"""Exibe a tela de game over com estatísticas."""
	time_label.text = "⏱ Sobreviveu: %s" % GameManager.get_survived_time_string()
	
	# Calcula ranking baseado no tempo
	var rank = ""
	var rank_color = Color.WHITE
	if survived_time >= 600:  # 10 minutos
		rank = "🏆 LENDÁRIO"
		rank_color = Color(1.0, 0.85, 0.0)
	elif survived_time >= 300:  # 5 minutos
		rank = "🥇 OURO"
		rank_color = Color(1.0, 0.85, 0.0)
	elif survived_time >= 180:  # 3 minutos
		rank = "🥈 PRATA"
		rank_color = Color(0.75, 0.75, 0.75)
	elif survived_time >= 60:  # 1 minuto
		rank = "🥉 BRONZE"
		rank_color = Color(0.8, 0.5, 0.2)
	else:
		rank = "💀 INICIANTE"
		rank_color = Color(0.6, 0.6, 0.6)
	
	# Mostra estatísticas finais
	var stats = GameManager.player_stats
	var stats_text = ""
	stats_text += "%s\n\n" % rank
	stats_text += "⭐ Nível: %d\n" % GameManager.current_level
	stats_text += "⚔ Dano: %.0f\n" % stats["damage"]
	stats_text += "🔱 Projéteis: %d\n" % stats["projectile_count"]
	stats_text += "🎯 Crítico: %.0f%%\n" % (stats["crit_chance"] * 100)
	stats_text += "⚡ Cooldown: %.2fs\n" % stats["attack_cooldown"]
	if stats["lifesteal"] > 0:
		stats_text += "🩸 Lifesteal: %.0f%%" % (stats["lifesteal"] * 100)
	
	stats_label.text = stats_text
	stats_label.add_theme_color_override("font_color", rank_color)
	if _panel_style:
		_panel_style.border_color = rank_color.darkened(0.15)

	time_label.modulate.a = 0.0
	stats_label.modulate.a = 0.0
	restart_button.modulate.a = 0.0
	if _hint_label:
		_hint_label.modulate.a = 0.0
	
	visible = true
	get_tree().paused = false
	
	# Animação de entrada dramática
	if main_container:
		main_container.modulate.a = 0.0
		main_container.scale = Vector2(0.8, 0.8)
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(main_container, "modulate:a", 1.0, 0.6)
		tween.tween_property(main_container, "scale", Vector2.ONE, 0.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		await tween.finished

	var reveal_tween = create_tween()
	reveal_tween.tween_property(time_label, "modulate:a", 1.0, 0.16)
	reveal_tween.tween_property(stats_label, "modulate:a", 1.0, 0.22)
	reveal_tween.tween_property(restart_button, "modulate:a", 1.0, 0.14)
	if _hint_label:
		reveal_tween.tween_property(_hint_label, "modulate:a", 0.9, 0.12)
	await reveal_tween.finished

	if _hint_label:
		if _hint_tween and _hint_tween.is_running():
			_hint_tween.kill()
		_hint_tween = create_tween()
		_hint_tween.set_loops()
		_hint_tween.tween_property(_hint_label, "modulate:a", 0.45, 0.7)
		_hint_tween.tween_property(_hint_label, "modulate:a", 0.95, 0.7)

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_select"):
		_on_restart_pressed()
		get_viewport().set_input_as_handled()

func _on_restart_pressed() -> void:
	"""Reinicia o jogo do zero."""
	if _hint_tween and _hint_tween.is_running():
		_hint_tween.kill()
	GameManager.reset_game()
	get_tree().reload_current_scene()
