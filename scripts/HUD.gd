# HUD.gd
# Interface estilo Vampire Survivors com pixel art
# Barras de HP/XP, nível, tempo, combo e stats
extends CanvasLayer

var hp_bar: ProgressBar
var hp_label: Label
var xp_bar: ProgressBar
var level_label: Label
var time_label: Label
var gold_label: Label
var meta_label: Label
var combo_label: Label
var stats_label: Label
var _xp_glow_tween: Tween = null
var _last_combo_count: int = 0
var _combo_tween: Tween = null

func _ready() -> void:
	_create_hud()
	
	# Conecta sinais do GameManager
	GameManager.xp_changed.connect(_on_xp_changed)
	GameManager.level_up.connect(_on_level_up)
	
	_update_level_display()
	var intro_tween = create_tween()
	intro_tween.set_parallel(true)
	for child in get_children():
		if child is CanvasItem:
			child.modulate.a = 0.0
			intro_tween.tween_property(child, "modulate:a", 1.0, 0.4)

func _create_hud() -> void:
	"""Cria a HUD programaticamente em pixel art style."""
	# Container superior esquerdo (HP, XP, Level) com painel de fundo
	var top_left = MarginContainer.new()
	top_left.set_anchors_preset(Control.PRESET_TOP_LEFT)
	top_left.add_theme_constant_override("margin_left", 20)
	top_left.add_theme_constant_override("margin_top", 20)
	add_child(top_left)
	
	# Painel de fundo semi-transparente
	var bg_panel = PanelContainer.new()
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.0, 0.0, 0.0, 0.6)
	bg_style.border_color = Color(0.4, 0.4, 0.5, 0.8)
	bg_style.set_border_width_all(2)
	bg_style.corner_radius_top_left = 0
	bg_style.corner_radius_top_right = 0
	bg_style.corner_radius_bottom_left = 0
	bg_style.corner_radius_bottom_right = 0
	bg_style.content_margin_left = 15
	bg_style.content_margin_right = 15
	bg_style.content_margin_top = 15
	bg_style.content_margin_bottom = 15
	bg_panel.add_theme_stylebox_override("panel", bg_style)
	top_left.add_child(bg_panel)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	bg_panel.add_child(vbox)
	
	# Barra de HP
	var hp_container = _create_stat_bar("HP", Color(0.9, 0.2, 0.2))
	hp_bar = hp_container.get_node("Panel/Bar")
	hp_label = hp_container.get_node("Panel/Bar/Label")
	vbox.add_child(hp_container)
	
	# Barra de XP
	var xp_container = _create_stat_bar("XP", Color(0.2, 0.8, 0.3))
	xp_bar = xp_container.get_node("Panel/Bar")
	vbox.add_child(xp_container)
	
	# Label de nível com sombra e brilho
	level_label = Label.new()
	level_label.add_theme_font_size_override("font_size", 28)
	level_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.2))
	level_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.9))
	level_label.add_theme_constant_override("shadow_offset_x", 2)
	level_label.add_theme_constant_override("shadow_offset_y", 2)
	vbox.add_child(level_label)
	
	# Container superior direito (Tempo, Combo, Stats) com painel de fundo
	var top_right = MarginContainer.new()
	top_right.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	top_right.add_theme_constant_override("margin_right", 20)
	top_right.add_theme_constant_override("margin_top", 20)
	add_child(top_right)
	
	# Painel de fundo semi-transparente
	var right_bg_panel = PanelContainer.new()
	var right_bg_style = StyleBoxFlat.new()
	right_bg_style.bg_color = Color(0.0, 0.0, 0.0, 0.6)
	right_bg_style.border_color = Color(0.4, 0.4, 0.5, 0.8)
	right_bg_style.set_border_width_all(2)
	right_bg_style.corner_radius_top_left = 0
	right_bg_style.corner_radius_top_right = 0
	right_bg_style.corner_radius_bottom_left = 0
	right_bg_style.corner_radius_bottom_right = 0
	right_bg_style.content_margin_left = 15
	right_bg_style.content_margin_right = 15
	right_bg_style.content_margin_top = 15
	right_bg_style.content_margin_bottom = 15
	right_bg_panel.add_theme_stylebox_override("panel", right_bg_style)
	top_right.add_child(right_bg_panel)
	
	var right_vbox = VBoxContainer.new()
	right_vbox.add_theme_constant_override("separation", 10)
	right_bg_panel.add_child(right_vbox)
	
	# Tempo com sombra
	time_label = Label.new()
	time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	time_label.add_theme_font_size_override("font_size", 32)
	time_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
	time_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.8))
	time_label.add_theme_constant_override("shadow_offset_x", 2)
	time_label.add_theme_constant_override("shadow_offset_y", 2)
	right_vbox.add_child(time_label)

	gold_label = Label.new()
	gold_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	gold_label.add_theme_font_size_override("font_size", 22)
	gold_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.35))
	right_vbox.add_child(gold_label)

	meta_label = Label.new()
	meta_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	meta_label.add_theme_font_size_override("font_size", 16)
	meta_label.add_theme_color_override("font_color", Color(0.75, 0.95, 1.0))
	right_vbox.add_child(meta_label)
	
	# Combo com sombra e efeito
	combo_label = Label.new()
	combo_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	combo_label.add_theme_font_size_override("font_size", 26)
	combo_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.9))
	combo_label.add_theme_constant_override("shadow_offset_x", 3)
	combo_label.add_theme_constant_override("shadow_offset_y", 3)
	combo_label.visible = false
	right_vbox.add_child(combo_label)
	
	# Stats com sombra
	stats_label = Label.new()
	stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	stats_label.add_theme_font_size_override("font_size", 18)
	stats_label.add_theme_color_override("font_color", Color(0.9, 0.9, 1.0))
	stats_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.7))
	stats_label.add_theme_constant_override("shadow_offset_x", 1)
	stats_label.add_theme_constant_override("shadow_offset_y", 1)
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
	panel.name = "Panel"
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
	if MetaProgress:
		gold_label.text = "💰 %d (+%d)" % [MetaProgress.total_gold, MetaProgress.run_gold]
		meta_label.text = "META L%d  🏆 %d/%d" % [
			MetaProgress.meta_level,
			AchievementSystem.get_completion_count() if AchievementSystem else 0,
			AchievementSystem.get_total_count() if AchievementSystem else 0
		]
	
	# Atualiza combo com animação
	if GameManager.combo_count > 0:
		combo_label.visible = true
		combo_label.text = "🔥 COMBO x%d" % GameManager.combo_count
		if GameManager.combo_count != _last_combo_count:
			if _combo_tween and _combo_tween.is_running():
				_combo_tween.kill()
			combo_label.scale = Vector2(1.2, 1.2)
			_combo_tween = create_tween()
			_combo_tween.tween_property(combo_label, "scale", Vector2.ONE, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		
		# Cor e escala mudam com o combo
		if GameManager.combo_count > 20:
			combo_label.modulate = Color(1.0, 0.2, 0.2)
		elif GameManager.combo_count > 10:
			combo_label.modulate = Color(1.0, 0.6, 0.0)
		else:
			combo_label.modulate = Color(1.0, 1.0, 0.3)
	else:
		combo_label.visible = false
		combo_label.scale = Vector2.ONE

	_last_combo_count = GameManager.combo_count
	
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
	
	# Animação de pulso e shake quando HP baixo
	var hp_percent = float(current) / float(maximum)
	if hp_percent < 0.3:
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(hp_label, "modulate", Color(1.5, 0.5, 0.5), 0.3)
		tween.tween_property(hp_bar, "modulate", Color(1.3, 0.6, 0.6), 0.3)
		tween.chain()
		tween.tween_property(hp_label, "modulate", Color.WHITE, 0.3)
		tween.tween_property(hp_bar, "modulate", Color.WHITE, 0.3)
		
		# Shake sutil
		if hp_percent < 0.15:
			var original_pos = hp_bar.position
			var shake_tween = create_tween()
			shake_tween.tween_property(hp_bar, "position", original_pos + Vector2(2, 0), 0.05)
			shake_tween.tween_property(hp_bar, "position", original_pos + Vector2(-2, 0), 0.05)
			shake_tween.tween_property(hp_bar, "position", original_pos, 0.05)

func _on_xp_changed(current_xp: int, xp_to_next: int) -> void:
	"""Atualiza a barra de XP com animação e brilho quando próximo do level up."""
	xp_bar.max_value = xp_to_next
	
	# Anima o preenchimento
	var tween = create_tween()
	tween.tween_property(xp_bar, "value", current_xp, 0.3).set_trans(Tween.TRANS_CUBIC)
	
	# Brilho pulsante quando próximo do level up (>80%)
	var xp_percent = float(current_xp) / float(xp_to_next)
	if xp_percent > 0.8:
		if _xp_glow_tween == null or not _xp_glow_tween.is_running():
			_xp_glow_tween = create_tween()
			_xp_glow_tween.set_loops()
			_xp_glow_tween.tween_property(xp_bar, "modulate", Color(1.2, 1.35, 1.2), 0.45)
			_xp_glow_tween.tween_property(xp_bar, "modulate", Color.WHITE, 0.45)
	else:
		if _xp_glow_tween and _xp_glow_tween.is_running():
			_xp_glow_tween.kill()
		_xp_glow_tween = null
		xp_bar.modulate = Color.WHITE

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
	text += "  🚀 x%.2f" % float(stats.get("projectile_speed_mult", 1.0))
	text += "\n🗡 arma: %s" % GameManager.get_current_weapon_mode()
	if int(stats.get("pierce_count", 0)) > 0:
		text += "\n🜂 perfura %d" % int(stats.get("pierce_count", 0))
	if int(stats.get("radial_shot_count", 0)) > 0:
		text += "  ✨ nova %d" % int(stats.get("radial_shot_count", 0))
	if float(stats.get("crit_explosion_radius", 0.0)) > 0.0:
		text += "\n💣 crit AoE"
	if float(stats.get("chaos_shot_chance", 0.0)) > 0.0:
		text += "  👶 caos %.0f%%" % (float(stats.get("chaos_shot_chance", 0.0)) * 100.0)
	if int(stats.get("void_orbitals", 0)) > 0:
		text += "\n🪐 órbitas %d" % int(stats.get("void_orbitals", 0))
	if int(stats.get("quantum_brain", 0)) > 0:
		text += "  🧠 Q%d" % int(stats.get("quantum_brain", 0))
	if int(stats.get("mutation_power", 0)) > 0:
		text += "\n🧬 mutação %d" % int(stats.get("mutation_power", 0))

	if not GameManager.active_powerups.is_empty():
		var buff_texts: Array[String] = []
		for key in GameManager.active_powerups.keys():
			buff_texts.append("%s %.0fs" % [String(key), float(GameManager.active_powerups[key])])
		text += "\n⚡ " + ", ".join(buff_texts)
	
	stats_label.text = text
