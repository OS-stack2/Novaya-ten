class_name Soldier
extends Node2D

const SPEED := 55.0
const CONE_LENGTH := 210.0
const CONE_HALF_ANGLE := 0.33

var patrol_min := 0.0
var patrol_max := 0.0
var dir := 1
var cone_poly: CollisionPolygon2D
var hazard: Area2D
var lantern: Sprite2D

func setup(p_min: float, p_max: float) -> void:
	patrol_min = p_min
	patrol_max = p_max


func _ready() -> void:
	var body := Sprite2D.new()
	body.texture = load("res://assets/sprites/soldier_body.png")
	body.position = Vector2(0, -33)
	add_child(body)

	var arm_left := Sprite2D.new()
	arm_left.texture = load("res://assets/sprites/soldier_arm_left.png")
	arm_left.position = Vector2(-13, -45)
	add_child(arm_left)

	lantern = Sprite2D.new()
	lantern.texture = load("res://assets/sprites/soldier_lantern.png")
	lantern.position = Vector2(13, -48)
	add_child(lantern)

	var tw := create_tween().set_loops()
	tw.tween_property(lantern, "rotation_degrees", 6, 0.45)
	tw.tween_property(lantern, "rotation_degrees", -6, 0.45)

	hazard = Area2D.new()
	cone_poly = CollisionPolygon2D.new()
	_update_cone_shape()
	hazard.add_child(cone_poly)
	hazard.body_entered.connect(_on_body_entered)
	add_child(hazard)


func _update_cone_shape() -> void:
	# Always built pointing toward local +x; Soldier.scale.x (set from dir)
	# mirrors this along with the sprites, so direction is not baked in here.
	var p1 := Vector2(18.0, -40.0)
	var p2 := p1 + Vector2(cos(-CONE_HALF_ANGLE), sin(-CONE_HALF_ANGLE)) * CONE_LENGTH
	var p3 := p1 + Vector2(cos(CONE_HALF_ANGLE), sin(CONE_HALF_ANGLE)) * CONE_LENGTH
	cone_poly.polygon = PackedVector2Array([p1, p2, p3])


func _process(delta: float) -> void:
	position.x += dir * SPEED * delta
	if position.x > patrol_max:
		dir = -1
	elif position.x < patrol_min:
		dir = 1
	scale.x = float(dir)


func _on_body_entered(body: Node) -> void:
	if body is Player:
		body.die()
