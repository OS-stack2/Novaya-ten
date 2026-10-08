class_name Rat
extends Node2D

var speed := 28.0
var dir := 1
var patrol_min := 0.0
var patrol_max := 0.0
var sprite: Sprite2D

func setup(kind: String, p_min: float, p_max: float) -> void:
	var kind_speed := {"normal": 30.0, "plague": 22.0, "skeleton": 38.0}
	speed = kind_speed.get(kind, 28.0)
	patrol_min = p_min
	patrol_max = p_max
	dir = 1 if randf() < 0.5 else -1

	sprite = Sprite2D.new()
	sprite.texture = load("res://assets/sprites/rat_%s.png" % kind)
	sprite.position = Vector2(0, -7)
	add_child(sprite)


func _process(delta: float) -> void:
	position.x += dir * speed * delta
	if position.x > patrol_max:
		dir = -1
	elif position.x < patrol_min:
		dir = 1
	sprite.scale.x = 1.0 if dir > 0 else -1.0
