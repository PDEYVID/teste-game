# HUD.gd
# Interface estilo Vampire Survivors com pixel art
# Barras de HP/XP, nível, tempo, combo e stats
extends CanvasLayer

var hp_bar: ProgressBar
var hp_label: Label
var xp_bar: ProgressBar
var level_label: Label
var time_label: Label
var combo_label: Label
var stats_label: Label

func _ready() -> void:
	_create_hud()
	
	# Conecta sinais do GameManager
	GameManager.xp_changed.connect(_on_xp_changed)
	GameManager.level_up.connect(_on_level_up)
	
	_update_level_display()

func _create_hud() -> void:
	"""Cria a HUD programaticamente em pixel art style."""
	# Container superior esquerdo (HP, XP, Level)
	var top_left = MarginContainer.new()
	top_left.set_anchors_preset(Control.PRESET_TOP_LEFT)
	top_left.add_theme_constant_override("margin_left", 20)
	top_left.add_theme_constant_override("margin_top", 20)
	add_child(top_left)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	top_left.add_child(vbox)
	
	# Barra de HP
	var hp_container = _create_stat_bar("HP", Color(0.9, 0.2, 0.2))
	hp_bar = hp_container.get_node("Bar")
	hp_label = hp_container.get_node("Label")
	vbox.add_child(hp_container)
	
	# Barra de XP
	var xp_container = _create_stat_bar("XP", Color(0.2, 0.8, 0.3))
	xp_bar = xp_container.get_node("Bar")
	vbox.add_child(xp_container)
	
	# Label de nível
	level_label = Label.new()
	level_label.add_theme_font_size_override("font_size", 24)
	level_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.2))
	vbox.add_child(level_label)
	
	# Container superior direito (Tempo, Combo, Stats)
	var top_right = MarginContainer.new()
	top_right.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	top_right.add_theme_constant_override("margin_right", 20)
	top_right.add_theme_constant_override("margin_top", 20)
	add_child(top_right)
	
	var right_vbox = VBoxContainer.new()
	right_vbox.add_theme_constant_override("separation", 10)
	top_right.add_child(right_vbox)
	
	# Tempo
	time_label = Label.new()
	time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	time_label.add_theme_font_size_override("font_size", 28)
	time_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
	right_vbox.add_child(time_label)
	
	# Combo
	combo_label = Label.new()
	combo_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	combo_label.add_theme_font_size_override("font_size", 22)
	combo_label.visible = false
	right_vbox.add_child(combo_label)
	
	# Stats
	stats_label = Label.new()
	stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	stats_label.add_theme_font_size_override("font_size", 16)
	stats_label.add_theme_color_override("font_color", Color(0.9, 0.9, 1.0))
	right_vbox.add_child(stats_label)

func _create_stat_bar(label_text: String, color: Color) -> Control:
	"""Cria uma barra de status com label e borda pixel art."""
	var container = VBoxContainer.new()
	container.custom_minimum_size = Vector2(300, 0)
	
	# Label do stat
	var label = Label.new()
	label.text = label_text
	label.add_theme_font_size_override("font_size", 18)
	container.add_child(label)
	
	# Painel com borda
	var panel = PanelContainer.new()
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.15)
	style.border_color = Color(0.6, 0.6, 0.7)
	style.set_border_width_all(3)
	style.corner_radius_top_left = 0
	style.corner_radius_top_right = 0
	style.corner_radius_bottom_left = 0
	style.corner_radius_bottom_right = 0
	panel.add_theme_stylebox_override("panel", style)
	container.add_child(panel)
	
	# Barra de progresso
	var bar = ProgressBar.new()
	bar.name = "Bar"
	bar.custom_minimum_size = Vector2(0, 30)
	bar.show_percentage = false
	
	# Estilo da barra
	var bar_bg = StyleBoxFlat.new()
	bar_bg.bg_color = Color(0.15, 0.15, 0.2)
	bar.add_theme_stylebox_override("background", bar_bg)
	
	var bar_fill = StyleBoxFlat.new()
	bar_fill.bg_color = color
	bar.add_theme_stylebox_override("fill", bar_fill)
	
	panel.add_child(bar)
	
	# Label de valor sobre a barra
	var value_label = Label.new()
	value_label.name = "Label"
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	value_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	value_label.add_theme_font_size_override("font_size", 18)
	value_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
	value_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	bar.add_child(value_label)
	
	return container

func _process(_delta: float) -> void:
	# Atualiza o tempo
	time_label.text = "⏱ " + GameManager.get_survived_time_string()
	
	# Atualiza combo com animação
	if GameManager.combo_count > 0:
		combo_label.visible = true
		combo_label.text = "🔥 COMBO x%d" % GameManager.combo_count
		
		# Cor e escala mudam com o combo
		if GameManager.combo_count > 20:
			combo_label.modulate = Color(1.0, 0.2, 0.2)
			combo_label.scale = Vector2(1.2, 1.2)
		elif GameManager.combo_count > 10:
			combo_label.modulate = Color(1.0, 0.6, 0.0)
			combo_label.scale = Vector2(1.1, 1.1)
		else:
			combo_label.modulate = Color(1.0, 1.0, 0.3)
			combo_label.scale = Vector2.ONE
	else:
		combo_label.visible = false
	
	_update_stats_display()

func connect_player(player: Node) -> void:
	"""Conecta o sinal de HP do player à HUD."""
	player.hp_changed.connect(_on_hp_changed)
	_on_hp_changed(player.current_hp, player.max_hp)

func _on_hp_changed(current: int, maximum: int) -> void:
	"""Atualiza a barra e label de HP."""
	hp_bar.max_value = maximum
	hp_bar.value = current
	hp_label.text = "%d / %d" % [current, maximum]
	
	# Animação de pulso quando HP baixo
	if float(current) / float(maximum) < 0.3:
		var tween = create_tween()
		tween.tween_property(hp_label, "modulate", Color(1.5, 0.5, 0.5), 0.3)
		tween.tween_property(hp_label, "modulate", Color.WHITE, 0.3)

func _on_xp_changed(current_xp: int, xp_to_next: int) -> void:
	"""Atualiza a barra de XP com animação."""
	xp_bar.max_value = xp_to_next
	
	# Anima o preenchimento
	var tween = create_tween()
	tween.tween_property(xp_bar, "value", current_xp, 0.3).set_trans(Tween.TRANS_CUBIC)

func _on_level_up(new_level: int) -> void:
	"""Atualiza o display de nível com animação."""
	_update_level_display()
	
	# Animação de level up
	var original_scale = level_label.scale
	var tween = create_tween()
	tween.tween_property(level_label, "scale", Vector2(1.5, 1.5), 0.2)
	tween.tween_property(level_label, "scale", original_scale, 0.2)

func _update_level_display() -> void:
	level_label.text = "⭐ NÍVEL %d" % GameManager.current_level

func _update_stats_display() -> void:
	"""Atualiza display de estatísticas do player."""
	var stats = GameManager.player_stats
	var text = ""
	text += "⚔ %.0f" % stats["damage"]
	text += "  🎯 %.0f%%" % (stats["crit_chance"] * 100)
	if stats["lifesteal"] > 0:
		text += "  🩸 %.0f%%" % (stats["lifesteal"] * 100)
	text += "\n🔱 %d proj" % stats["projectile_count"]
	text += "  ⚡ %.1fs" % stats["attack_cooldown"]
	
	stats_label.text = text
