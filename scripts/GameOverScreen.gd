# GameOverScreen.gd
# Tela de Game Over estilo Vampire Survivors
# Mostra estatísticas da run e botão de reiniciar
extends CanvasLayer

var time_label: Label
var stats_label: Label
var restart_button: Button
var main_container: Control  # Container principal para animações

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
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.add_child(panel)
	
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 25)
	panel.add_child(vbox)
	
	# Título GAME OVER
	var title = Label.new()
	title.text = "💀 GAME OVER 💀"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 52)
	title.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))
	vbox.add_child(title)
	
	# Tempo sobrevivido
	time_label = Label.new()
	time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	time_label.add_theme_font_size_override("font_size", 32)
	time_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3))
	vbox.add_child(time_label)
	
	# Estatísticas da run
	stats_label = Label.new()
	stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_label.add_theme_font_size_override("font_size", 20)
	stats_label.add_theme_color_override("font_color", Color(0.9, 0.9, 1.0))
	vbox.add_child(stats_label)
	
	# Botão de reiniciar
	restart_button = Button.new()
	restart_button.text = "🔄 JOGAR NOVAMENTE"
	restart_button.custom_minimum_size = Vector2(300, 60)
	restart_button.add_theme_font_size_override("font_size", 24)
	restart_button.pressed.connect(_on_restart_pressed)
	vbox.add_child(restart_button)

func _on_game_over(survived_time: float) -> void:
	"""Exibe a tela de game over com estatísticas."""
	time_label.text = "⏱ Tempo: %s" % GameManager.get_survived_time_string()
	
	# Mostra estatísticas finais
	var stats = GameManager.player_stats
	var stats_text = ""
	stats_text += "⭐ Nível Alcançado: %d\n\n" % GameManager.current_level
	stats_text += "⚔ Dano Final: %.0f\n" % stats["damage"]
	stats_text += "🔱 Projéteis: %d\n" % stats["projectile_count"]
	stats_text += "🎯 Crítico: %.0f%%\n" % (stats["crit_chance"] * 100)
	if stats["lifesteal"] > 0:
		stats_text += "🩸 Lifesteal: %.0f%%" % (stats["lifesteal"] * 100)
	
	stats_label.text = stats_text
	
	visible = true
	get_tree().paused = false
	
	# Animação de entrada
	if main_container:
		main_container.modulate.a = 0.0
		var tween = create_tween()
		tween.tween_property(main_container, "modulate:a", 1.0, 0.5)

func _on_restart_pressed() -> void:
	"""Reinicia o jogo do zero."""
	GameManager.reset_game()
	get_tree().reload_current_scene()
