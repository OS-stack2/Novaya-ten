class_name WindowLight
extends Node2D

enum State { IDLE, GLOWING, OPEN }

var state := State.IDLE
var timer := 0.0
var closed_spr: Sprite2D
var glow_spr: Sprite2D
var open_spr: Sprite2D
var hazard: Area2D

func _ready() -> void:
	closed_spr = Sprite2D.new()
	closed_spr.texture = load("res://assets/sprites/window_closed.png")
	add_child(closed_spr)

	glow_spr = Sprite2D.new()
	glow_spr.texture = load("res://assets/sprites/window_curtain_glow.png")
	glow_spr.modulate.a = 0.0
	add_child(glow_spr)

	open_spr = Sprite2D.new()
	open_spr.texture = load("res://assets/sprites/window_open.png")
	open_spr.visible = false
	add_child(open_spr)

	hazard = Area2D.new()
	hazard.monitoring = false
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(32, 90)
	shape.shape = rect
	shape.position = Vector2(0, 45)
	hazard.add_child(shape)
	hazard.body_entered.connect(_on_body_entered)
	add_child(hazard)

	timer = randf_range(2.0, 9.0)


func _process(delta: float) -> void:
	timer -= delta
	if state == State.GLOWING:
		var t = (sin(Time.get_ticks_msec() * 0.006) + 1.0) / 2.0
		glow_spr.modulate.a = 0.4 + t * 0.6

	if timer > 0:
		return

	match state:
		State.IDLE:
			state = State.GLOWING
			timer = randf_range(0.9, 1.6)
		State.GLOWING:
			state = State.OPEN
			glow_spr.modulate.a = 0.0
			closed_spr.visible = false
			open_spr.visible = true
			hazard.monitoring = true
			timer = randf_range(2.5, 5.0)
		State.OPEN:
			state = State.IDLE
			closed_spr.visible = true
			open_spr.visible = false
			hazard.monitoring = false
			timer = randf_range(4.0, 12.0)


func _on_body_entered(body: Node) -> void:
	if body is Player:
		body.die()
