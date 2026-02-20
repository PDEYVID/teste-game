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
]

var option_buttons: Array = []
var selected_upgrades: Array = []
var main_container: Control  # Container principal para animações

func _ready() -> void:
	GameManager.level_up.connect(_on_level_up)
	visible = false
	_setup_ui()

func _setup_ui() -> void:
	"""Cria a UI programaticamente em pixel art style."""
	# Fundo escuro semi-transparente
	var bg = ColorRect.new()
	bg.color = Color(0.0, 0.0, 0.0, 0.85)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	
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
	var title_panel = _create_pixel_panel(Color(0.15, 0.1, 0.2), 4)
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
	
	for i in range(selected_upgrades.size()):
		var card = _create_upgrade_card(selected_upgrades[i], i)
		container.add_child(card)
		option_buttons.append(card)

func _create_upgrade_card(upgrade: Dictionary, index: int) -> Control:
	"""Cria um card de upgrade estilo Vampire Survivors."""
	var card_container = Control.new()
	card_container.custom_minimum_size = Vector2(260, 360)
	
	# Painel do card com cor baseada na raridade
	var rarity_colors = {
		"comum": Color(0.25, 0.25, 0.3),
		"raro": Color(0.2, 0.3, 0.5),
		"épico": Color(0.4, 0.2, 0.5)
	}
	var bg_color = rarity_colors.get(upgrade.get("rarity", "comum"), Color(0.25, 0.25, 0.3))
	var card_panel = _create_pixel_panel(bg_color, 5)
	card_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	card_container.add_child(card_panel)
	
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	card_panel.add_child(vbox)
	
	vbox.add_child(_create_spacer(15))
	
	# Ícone grande
	var icon_label = Label.new()
	icon_label.text = upgrade.get("icon", "?")
	icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_label.add_theme_font_size_override("font_size", 72)
	vbox.add_child(icon_label)
	
	vbox.add_child(_create_spacer(10))
	
	# Nome do upgrade
	var name_label = Label.new()
	name_label.text = upgrade["name"]
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 20)
	name_label.add_theme_color_override("font_color", upgrade["color"])
	vbox.add_child(name_label)
	
	vbox.add_child(_create_spacer(10))
	
	# Descrição
	var desc_label = Label.new()
	desc_label.text = upgrade["description"]
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.add_theme_font_size_override("font_size", 16)
	desc_label.custom_minimum_size = Vector2(220, 80)
	vbox.add_child(desc_label)
	
	vbox.add_child(_create_spacer(15))
	
	# Botão de seleção
	var btn = Button.new()
	btn.text = "ESCOLHER"
	btn.custom_minimum_size = Vector2(200, 50)
	btn.add_theme_font_size_override("font_size", 18)
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
	GameManager.apply_upgrade(upgrade_id)
	
	# Animação de saída
	if main_container:
		var tween = create_tween()
		tween.tween_property(main_container, "modulate:a", 0.0, 0.2)
		await tween.finished
		main_container.modulate.a = 1.0
	
	visible = false
	get_tree().paused = false
