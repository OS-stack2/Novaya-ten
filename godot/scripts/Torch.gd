class_name Torch
extends Node2D

var phases := [
	{"tex": "res://assets/sprites/torch_flame_bright.png", "min": 1.8, "max": 3.2, "deadly": true, "scale": 1.0},
	{"tex": "res://assets/sprites/torch_flame_low.png", "min": 0.4, "max": 0.9, "deadly": true, "scale": 0.8},
	{"tex": "res://assets/sprites/torch_flame_ember.png", "min": 0.3, "max": 0.7, "deadly": false, "scale": 0.5},
]

var phase_index := 0
var phase_timer := 0.0
var flame: Sprite2D
var hazard: Area2D
var hazard_shape: CollisionShape2D
var moths: Array = []
var base_x := 0.0

func _ready() -> void:
	base_x = position.x

	var pole := Sprite2D.new()
	pole.texture = load("res://assets/sprites/torch_pole.png")
	pole.position = Vector2(0, -35)
	add_child(pole)

	flame = Sprite2D.new()
	flame.position = Vector2(0, -78)
	add_child(flame)

	hazard = Area2D.new()
	hazard.monitoring = true
	hazard_shape = CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 34
	hazard_shape.shape = circle
	hazard_shape.position = Vector2(0, -78)
	hazard.add_child(hazard_shape)
	hazard.body_entered.connect(_on_body_entered)
	add_child(hazard)

	for i in range(3):
		var m := Sprite2D.new()
		m.texture = load("res://assets/sprites/moth.png")
		m.set_meta("angle", randf() * TAU)
		m.set_meta("speed", 1.2 + randf() * 1.8)
		m.set_meta("radius", 14.0 + randf() * 10.0)
		add_child(m)
		moths.append(m)

	_set_phase(0)
	phase_timer = randf_range(phases[0]["min"], phases[0]["max"])


func _set_phase(i: int) -> void:
	var p = phases[i]
	flame.texture = load(p["tex"])
	flame.scale = Vector2.ONE * (p["scale"] + randf() * 0.08)
	hazard.monitoring = p["deadly"]
	hazard_shape.disabled = not p["deadly"]


func _process(delta: float) -> void:
	phase_timer -= delta
	flame.position.x = sin(Time.get_ticks_msec() * 0.01) * 1.2
	if phase_timer <= 0:
		phase_index = (phase_index + 1) % phases.size()
		var p = phases[phase_index]
		phase_timer = randf_range(p["min"], p["max"])
		_set_phase(phase_index)

	for m in moths:
		var a = m.get_meta("angle") + m.get_meta("speed") * delta
		m.set_meta("angle", a)
		var r = m.get_meta("radius")
		m.position = Vector2(cos(a) * r, -78 + sin(a) * r * 0.6)


func _on_body_entered(body: Node) -> void:
	if body is Player:
		body.die()
