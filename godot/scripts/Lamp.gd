class_name Lamp
extends Node2D

var head: Sprite2D
var moths: Array = []

func _ready() -> void:
	var post := Sprite2D.new()
	post.texture = load("res://assets/sprites/lamp_post.png")
	post.position = Vector2(0, -70)
	add_child(post)

	head = Sprite2D.new()
	head.texture = load("res://assets/sprites/lamp_head.png")
	head.position = Vector2(0, -143)
	add_child(head)

	var tw := create_tween().set_loops()
	tw.tween_property(head, "rotation_degrees", 6, 0.9 + randf() * 0.3)
	tw.tween_property(head, "rotation_degrees", -6, 0.9 + randf() * 0.3)

	var glow := Sprite2D.new()
	glow.texture = _soft_glow_placeholder()
	glow.modulate = Color(1, 0.86, 0.6, 0.08)
	glow.position = Vector2(0, -120)
	glow.scale = Vector2(3.0, 1.8)
	add_child(glow)

	var hazard := Area2D.new()
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(180, 90)
	shape.shape = rect
	shape.position = Vector2(0, -120)
	hazard.add_child(shape)
	hazard.body_entered.connect(_on_body_entered)
	add_child(hazard)

	for i in range(2):
		var m := Sprite2D.new()
		m.texture = load("res://assets/sprites/moth.png")
		m.set_meta("angle", randf() * TAU)
		m.set_meta("speed", 1.0 + randf())
		m.set_meta("radius", 16.0 + randf() * 12.0)
		add_child(m)
		moths.append(m)


func _soft_glow_placeholder() -> Texture2D:
	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	img.fill(Color(1, 1, 1, 1))
	return ImageTexture.create_from_image(img)


func _process(delta: float) -> void:
	for m in moths:
		var a = m.get_meta("angle") + m.get_meta("speed") * delta
		m.set_meta("angle", a)
		var r = m.get_meta("radius")
		m.position = Vector2(cos(a) * r, -120 + sin(a) * r * 0.5)


func _on_body_entered(body: Node) -> void:
	if body is Player:
		body.die()
