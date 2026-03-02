# UpgradeScreen.gd
# Tela de escolha de upgrade estilo Vampire Survivors
# Cards em pixel art com ícones visuais e animações
extends CanvasLayer

# Definição de todos os upgrades disponíveis
const UPGRADES: Array[Dictionary] = [
	{
		"id": "damage_up",
		"name": "ESPADA AFIADA",
		"description": "+10 de dano\npor projétil",
		"icon": "⚔",
		"color": Color(0.9, 0.2, 0.2),
		"rarity": "comum"
	},
	{
		"id": "speed_up",
		"name": "BOTAS RÁPIDAS",
		"description": "+30 velocidade\nde movimento",
		"icon": "👟",
		"color": Color(0.2, 0.8, 0.2),
		"rarity": "comum"
	},
	{
		"id": "range_up",
		"name": "OLHO DE ÁGUIA",
		"description": "+30 raio\nde ataque",
		"icon": "🎯",
		"color": Color(0.2, 0.5, 0.9),
		"rarity": "comum"
	},
	{
		"id": "cooldown_down",
		"name": "FÚRIA VELOZ",
		"description": "-0.2s cooldown\nde ataque",
		"icon": "⚡",
		"color": Color(0.9, 0.8, 0.1),
		"rarity": "raro"
	},
	{
		"id": "hp_up",
		"name": "CORAÇÃO FORTE",
		"description": "+25 HP máximo\ne cura total",
		"icon": "❤",
		"color": Color(0.9, 0.3, 0.5),
		"rarity": "comum"
	},
	{
		"id": "multishot",
		"name": "TIRO MÚLTIPLO",
		"description": "+1 projétil\npor ataque",
		"icon": "🔱",
		"color": Color(0.7, 0.2, 0.9),
		"rarity": "épico"
	},
	{
		"id": "crit_up",
		"name": "SORTE FATAL",
		"description": "+10% chance\nde crítico",
		"icon": "🎲",
		"color": Color(1.0, 0.5, 0.0),
		"rarity": "raro"
	},
	{
		"id": "crit_damage_up",
		"name": "GOLPE MORTAL",
		"description": "+0.5x dano\ncrítico",
		"icon": "💥",
		"color": Color(1.0, 0.2, 0.2),
		"rarity": "épico"
	},
	{
		"id": "lifesteal_up",
		"name": "VAMPIRISMO",
		"description": "+10% roubo\nde vida",
		"icon": "🩸",
		"color": Color(0.8, 0.1, 0.4),
		"rarity": "épico"
	},
	{
		"id": "dash_upgrade",
		"name": "PASSO SOMBRIO",
		"description": "-0.3s cooldown\ndo dash",
		"icon": "👻",
		"color": Color(0.3, 0.8, 1.0),
		"rarity": "raro"
	},
	{
		"id": "arcane_nova",
		"name": "NOVA ARCANA",
		"description": "+4 tiros\nem círculo",
		"icon": "✨",
		"color": Color(0.9, 0.6, 1.0),
		"rarity": "lendário"
	},
	{
		"id": "pierce_rounds",
		"name": "MUNIÇÃO FANTASMA",
		"description": "projéteis atravessam\n+1 inimigo",
		"icon": "🜂",
		"color": Color(0.7, 0.95, 1.0),
		"rarity": "épico"
	},
	{
		"id": "crit_explosion",
		"name": "CRÍTICO EXPLOSIVO",
		"description": "críticos explodem\nem área",
		"icon": "💣",
		"color": Color(1.0, 0.55, 0.25),
		"rarity": "lendário"
	},
	{
		"id": "hyper_projectile",
		"name": "PROJÉTIL HIPER",
		"description": "+65% velocidade\ndo projétil",
		"icon": "🚀",
		"color": Color(0.4, 0.95, 1.0),
		"rarity": "raro"
	},
	{
		"id": "mutant_horns",
		"name": "CHIFRES MUTANTES",
		"description": "+dano e crítico\nforma demoníaca",
		"icon": "😈",
		"color": Color(0.95, 0.25, 0.35),
		"rarity": "lendário"
	},
	{
		"id": "demon_baby",
		"name": "BEBÊ CAÓTICO",
		"description": "chance de tiro\ncaótico extra",
		"icon": "👶",
		"color": Color(0.95, 0.65, 0.95),
		"rarity": "épico"
	},
	{
		"id": "giant_form",
		"name": "FORMA GIGANTE",
		"description": "+vida/+dano\nmaior e mais pesado",
		"icon": "🗿",
		"color": Color(0.9, 0.82, 0.65),
		"rarity": "raro"
	},
	{
		"id": "tiny_terror",
		"name": "TERROR MINI",
		"description": "menor e muito\nmais rápido",
		"icon": "🦇",
		"color": Color(0.55, 0.95, 0.95),
		"rarity": "raro"
	},
	{
		"id": "void_orbit",
		"name": "ÓRBITA DO VAZIO",
		"description": "esferas orbitais\nque trituram tudo",
		"icon": "🪐",
		"color": Color(0.45, 0.95, 1.0),
		"rarity": "lendário"
	},
	{
		"id": "quantum_brain",
		"name": "CÉREBRO QUÂNTICO",
		"description": "tiros em caos\nimprevisível",
		"icon": "🧠",
		"color": Color(0.9, 0.45, 1.0),
		"rarity": "lendário"
	},
]

var option_buttons: Array = []
var selected_upgrades: Array = []
var main_container: Control  # Container principal para animações
var _title_label: Label
var _bg_overlay: ColorRect
var _is_closing: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	set_process_unhandled_input(true)
	GameManager.level_up.connect(_on_level_up)
	visible = false
	_setup_ui()

func _setup_ui() -> void:
	"""Cria a UI programaticamente em pixel art style."""
	# Fundo escuro semi-transparente
	var bg = ColorRect.new()
	bg.color = Color(0.0, 0.0, 0.0, 0.45)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	_bg_overlay = bg
	
	# Container principal (para animações)
	main_container = Control.new()
	main_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(main_container)
	
	# Container centralizado
	var main_vbox = VBoxContainer.new()
	main_vbox.set_anchors_preset(Control.PRESET_CENTER)
	main_vbox.custom_minimum_size = Vector2(900, 500)
	main_vbox.position = Vector2(-450, -250)
	main_container.add_child(main_vbox)
	
	# Título com borda pixel art
	var title_panel = _create_pixel_panel(Color(0.20, 0.12, 0.32, 0.95), 4)
	title_panel.custom_minimum_size = Vector2(0, 80)
	main_vbox.add_child(title_panel)
	
	var title = Label.new()
	title.name = "LevelLabel"
	title.text = "LEVEL UP!"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 42)
	title.add_theme_color_override("font_color", Color(1.0, 0.9, 0.2))
	title.set_anchors_preset(Control.PRESET_FULL_RECT)
	title_panel.add_child(title)
	_title_label = title

	var subtitle = Label.new()
	subtitle.text = "Escolha um poder doido:"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 24)
	subtitle.add_theme_color_override("font_color", Color(0.92, 0.95, 1.0))
	subtitle.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.75))
	subtitle.add_theme_constant_override("shadow_offset_x", 2)
	subtitle.add_theme_constant_override("shadow_offset_y", 2)
	main_vbox.add_child(subtitle)
	
	main_vbox.add_child(_create_spacer(20))
	
	# Container dos cards
	var cards_hbox = HBoxContainer.new()
	cards_hbox.name = "OptionsContainer"
	cards_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	cards_hbox.add_theme_constant_override("separation", 30)
	main_vbox.add_child(cards_hbox)

func _create_pixel_panel(color: Color, border_size: int = 3) -> PanelContainer:
	"""Cria um painel com borda pixel art."""
	var panel = PanelContainer.new()
	
	# StyleBox com borda pixel art
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = Color(0.8, 0.8, 0.9)
	style.set_border_width_all(border_size)
	style.corner_radius_top_left = 0
	style.corner_radius_top_right = 0
	style.corner_radius_bottom_left = 0
	style.corner_radius_bottom_right = 0
	
	panel.add_theme_stylebox_override("panel", style)
	return panel

func _create_spacer(height: int) -> Control:
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, height)
	return spacer

func _on_level_up(new_level: int) -> void:
	"""Exibe a tela de upgrade ao subir de nível."""
	var title = get_node_or_null("VBoxContainer/LevelLabel")
	if not title:
		title = find_child("LevelLabel", true, false)
	if title:
		title.text = "NÍVEL %d!" % new_level
	
	_show_random_upgrades()
	visible = true
	get_tree().paused = true
	_is_closing = false

	if _bg_overlay:
		_bg_overlay.modulate.a = 0.0
	if main_container:
		main_container.modulate.a = 0.0
		main_container.scale = Vector2(0.94, 0.94)
		main_container.position = Vector2(0, 20)
	var open_tween = create_tween()
	open_tween.set_parallel(true)
	if _bg_overlay:
		open_tween.tween_property(_bg_overlay, "modulate:a", 1.0, 0.18)
	if main_container:
		open_tween.tween_property(main_container, "modulate:a", 1.0, 0.24)
		open_tween.tween_property(main_container, "scale", Vector2.ONE, 0.24).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		open_tween.tween_property(main_container, "position", Vector2.ZERO, 0.24).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	if _title_label:
		_title_label.scale = Vector2.ONE
		var title_tween = create_tween()
		title_tween.set_loops(2)
		title_tween.tween_property(_title_label, "scale", Vector2(1.05, 1.05), 0.2)
		title_tween.tween_property(_title_label, "scale", Vector2.ONE, 0.2)

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if _is_closing:
		return
	if event.is_action_pressed("ui_cancel"):
		return
	if event.is_action_pressed("ui_select") and selected_upgrades.size() > 0:
		_on_upgrade_selected(selected_upgrades[0]["id"])
		get_viewport().set_input_as_handled()
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_1 and selected_upgrades.size() > 0:
			_on_upgrade_selected(selected_upgrades[0]["id"])
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_2 and selected_upgrades.size() > 1:
			_on_upgrade_selected(selected_upgrades[1]["id"])
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_3 and selected_upgrades.size() > 2:
			_on_upgrade_selected(selected_upgrades[2]["id"])
			get_viewport().set_input_as_handled()

func _show_random_upgrades() -> void:
	"""Seleciona 3 upgrades aleatórios e cria os cards."""
	var container = find_child("OptionsContainer", true, false)
	if not container:
		return
	
	# Limpa cards anteriores
	for child in container.get_children():
		child.queue_free()
	option_buttons.clear()
	
	# Embaralha e pega 3 upgrades
	var shuffled: Array = UPGRADES.duplicate()
	shuffled.shuffle()
	selected_upgrades = shuffled.slice(0, 3)

	if GameManager.current_level >= 3:
		var crazy_ids := {
			"arcane_nova": true,
			"pierce_rounds": true,
			"crit_explosion": true,
			"hyper_projectile": true,
			"mutant_horns": true,
			"demon_baby": true,
			"giant_form": true,
			"tiny_terror": true,
			"void_orbit": true,
			"quantum_brain": true
		}
		var has_crazy: bool = false
		for upgrade in selected_upgrades:
			if crazy_ids.has(upgrade.get("id", "")):
				has_crazy = true
				break

		if not has_crazy:
			var crazy_pool: Array = []
			for upgrade in UPGRADES:
				if crazy_ids.has(upgrade.get("id", "")):
					crazy_pool.append(upgrade)
			if not crazy_pool.is_empty():
				crazy_pool.shuffle()
				selected_upgrades[0] = crazy_pool[0]
	
	for i in range(selected_upgrades.size()):
		var card = _create_upgrade_card(selected_upgrades[i], i)
		container.add_child(card)
		option_buttons.append(card)

func _create_upgrade_card(upgrade: Dictionary, index: int) -> Control:
	"""Cria um card de upgrade estilo Vampire Survivors."""
	var card_container = Control.new()
	card_container.custom_minimum_size = Vector2(280, 380)
	card_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Painel do card com cor baseada na raridade
	var rarity_colors = {
		"comum": Color(0.28, 0.28, 0.34),
		"raro": Color(0.22, 0.34, 0.56),
		"épico": Color(0.45, 0.25, 0.58),
		"lendário": Color(0.58, 0.34, 0.18)
	}
	var bg_color = rarity_colors.get(upgrade.get("rarity", "comum"), Color(0.25, 0.25, 0.3))
	var card_panel = _create_pixel_panel(bg_color, 5)
	card_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	card_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_container.add_child(card_panel)
	
	# Efeito de hover
	card_panel.mouse_entered.connect(func():
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(card_container, "scale", Vector2(1.08, 1.08), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(card_panel, "modulate", Color(1.2, 1.2, 1.2), 0.2)
	)
	card_panel.mouse_exited.connect(func():
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(card_container, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(card_panel, "modulate", Color.WHITE, 0.2)
	)
	
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_panel.add_child(vbox)
	
	vbox.add_child(_create_spacer(15))
	
	# Ícone grande com animação de rotação sutil
	var icon_label = Label.new()
	icon_label.text = upgrade.get("icon", "?")
	icon_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_label.add_theme_font_size_override("font_size", 80)
	icon_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.8))
	icon_label.add_theme_constant_override("shadow_offset_x", 3)
	icon_label.add_theme_constant_override("shadow_offset_y", 3)
	vbox.add_child(icon_label)
	
	# Animação de flutuação do ícone
	var icon_tween = create_tween()
	icon_tween.set_loops()
	icon_tween.tween_property(icon_label, "position:y", icon_label.position.y - 5, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	icon_tween.tween_property(icon_label, "position:y", icon_label.position.y + 5, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	vbox.add_child(_create_spacer(10))
	
	# Indicador de raridade
	var rarity_label = Label.new()
	rarity_label.text = upgrade.get("rarity", "comum").to_upper()
	rarity_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rarity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rarity_label.add_theme_font_size_override("font_size", 14)
	var rarity_color_map = {
		"comum": Color(0.7, 0.7, 0.7),
		"raro": Color(0.3, 0.6, 1.0),
		"épico": Color(0.8, 0.3, 1.0),
		"lendário": Color(1.0, 0.78, 0.22)
	}
	rarity_label.add_theme_color_override("font_color", rarity_color_map.get(upgrade.get("rarity", "comum"), Color.WHITE))
	vbox.add_child(rarity_label)
	
	vbox.add_child(_create_spacer(5))
	
	# Nome do upgrade com sombra
	var name_label = Label.new()
	name_label.text = upgrade["name"]
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 22)
	name_label.add_theme_color_override("font_color", upgrade["color"])
	name_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.9))
	name_label.add_theme_constant_override("shadow_offset_x", 2)
	name_label.add_theme_constant_override("shadow_offset_y", 2)
	vbox.add_child(name_label)
	
	vbox.add_child(_create_spacer(10))
	
	# Descrição
	var desc_label = Label.new()
	desc_label.text = upgrade["description"]
	desc_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.add_theme_font_size_override("font_size", 16)
	desc_label.add_theme_color_override("font_color", Color(0.92, 0.95, 1.0))
	desc_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.7))
	desc_label.add_theme_constant_override("shadow_offset_x", 1)
	desc_label.add_theme_constant_override("shadow_offset_y", 1)
	desc_label.custom_minimum_size = Vector2(220, 80)
	vbox.add_child(desc_label)
	
	vbox.add_child(_create_spacer(15))
	
	# Botão de seleção com estilo melhorado
	var btn = Button.new()
	btn.text = "ESCOLHER [%d]" % (index + 1)
	btn.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	btn.custom_minimum_size = Vector2(220, 55)
	btn.add_theme_font_size_override("font_size", 20)
	btn.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
	btn.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0))
	btn.add_theme_color_override("font_pressed_color", Color(0.9, 1.0, 0.9))
	
	# Estilo do botão
	var btn_normal = StyleBoxFlat.new()
	btn_normal.bg_color = Color(0.2, 0.6, 0.2)
	btn_normal.border_color = Color(0.4, 0.8, 0.4)
	btn_normal.set_border_width_all(3)
	btn.add_theme_stylebox_override("normal", btn_normal)
	
	var btn_hover = StyleBoxFlat.new()
	btn_hover.bg_color = Color(0.3, 0.8, 0.3)
	btn_hover.border_color = Color(0.5, 1.0, 0.5)
	btn_hover.set_border_width_all(3)
	btn.add_theme_stylebox_override("hover", btn_hover)
	
	var btn_pressed = StyleBoxFlat.new()
	btn_pressed.bg_color = Color(0.1, 0.4, 0.1)
	btn_pressed.border_color = Color(0.3, 0.6, 0.3)
	btn_pressed.set_border_width_all(3)
	btn.add_theme_stylebox_override("pressed", btn_pressed)
	
	btn.pressed.connect(_on_upgrade_selected.bind(upgrade["id"]))
	vbox.add_child(btn)
	
	# Animação de entrada
	card_container.modulate.a = 0.0
	card_container.scale = Vector2(0.8, 0.8)
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(card_container, "modulate:a", 1.0, 0.3).set_delay(index * 0.1)
	tween.tween_property(card_container, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(index * 0.1)
	
	return card_container

func _on_upgrade_selected(upgrade_id: String) -> void:
	"""Aplica o upgrade escolhido e retorna ao jogo."""
	if _is_closing:
		return
	_is_closing = true

	for card in option_buttons:
		if card is Control:
			card.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var selected_index: int = -1
	for i in range(selected_upgrades.size()):
		if selected_upgrades[i].get("id", "") == upgrade_id:
			selected_index = i
			break

	var focus_tween = create_tween()
	focus_tween.set_parallel(true)
	for i in range(option_buttons.size()):
		var card = option_buttons[i]
		if not (card is Control):
			continue
		if i == selected_index:
			focus_tween.tween_property(card, "scale", Vector2(1.1, 1.1), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		else:
			focus_tween.tween_property(card, "modulate:a", 0.35, 0.12)
	await focus_tween.finished

	# Flash branco ao selecionar
	var flash = ColorRect.new()
	flash.color = Color(1.0, 1.0, 1.0, 0.8)
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(flash)
	if AudioManager:
		AudioManager.play_upgrade_select()
	
	var flash_tween = create_tween()
	flash_tween.tween_property(flash, "modulate:a", 0.0, 0.3)
	await flash_tween.finished
	flash.queue_free()
	
	GameManager.apply_upgrade(upgrade_id)
	
	# Animação de saída
	if main_container:
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(main_container, "modulate:a", 0.0, 0.2)
		tween.tween_property(main_container, "scale", Vector2(0.96, 0.96), 0.2)
		if _bg_overlay:
			tween.tween_property(_bg_overlay, "modulate:a", 0.0, 0.2)
		await tween.finished
		main_container.modulate.a = 1.0
		main_container.scale = Vector2.ONE
		main_container.position = Vector2.ZERO
	
	visible = false
	get_tree().paused = false
