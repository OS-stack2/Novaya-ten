extends Node2D

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color(0.047, 0.031, 0.078))

	var canvas := CanvasLayer.new()
	add_child(canvas)

	var title := Label.new()
	title.text = "Таверна позади..."
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color(0.91, 0.85, 1.0))
	title.position = Vector2(340, 230)
	canvas.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Уровень 2 — скоро."
	subtitle.add_theme_color_override("font_color", Color(0.61, 0.53, 0.79))
	subtitle.position = Vector2(400, 280)
	canvas.add_child(subtitle)

	var hint := Label.new()
	hint.text = "(нажми любую клавишу, чтобы вернуться на уровень 1)"
	hint.add_theme_font_size_override("font_size", 13)
	hint.add_theme_color_override("font_color", Color(0.42, 0.35, 0.54))
	hint.position = Vector2(290, 330)
	canvas.add_child(hint)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		get_tree().change_scene_to_file("res://scenes/Level1.tscn")
