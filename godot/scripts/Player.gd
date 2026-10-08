class_name Player
extends CharacterBody2D

const SPEED := 190.0
const JUMP_VELOCITY := -430.0
const GRAVITY := 900.0

var dead := false
var facing := 1
var checkpoint := Vector2.ZERO

var arm_left: Sprite2D
var arm_right: Sprite2D
var body_sprite: Sprite2D
var arm_tween: Tween

func _ready() -> void:
	add_to_group("player")

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(26, 56)
	shape.shape = rect
	shape.position = Vector2(0, -28)
	add_child(shape)

	arm_left = _make_sprite("res://assets/sprites/player_arm_left.png", Vector2(-14, -44))
	arm_right = _make_sprite("res://assets/sprites/player_arm_right.png", Vector2(14, -44))
	body_sprite = _make_sprite("res://assets/sprites/player_body.png", Vector2(0, -2))

	checkpoint = position


func _make_sprite(path: String, pos: Vector2) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = load(path)
	s.position = pos
	s.centered = true
	add_child(s)
	return s


func _physics_process(delta: float) -> void:
	if dead:
		return

	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = min(velocity.y, 0)

	var left := Input.is_action_pressed("move_left")
	var right := Input.is_action_pressed("move_right")

	if left and not right:
		velocity.x = -SPEED
		facing = -1
		_set_visual_flip(-1)
		_start_walk_anim()
	elif right and not left:
		velocity.x = SPEED
		facing = 1
		_set_visual_flip(1)
		_start_walk_anim()
	else:
		velocity.x = 0
		_stop_walk_anim()

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	move_and_slide()

	if is_on_floor() and not dead:
		checkpoint = position


func _set_visual_flip(dir: int) -> void:
	body_sprite.scale.x = float(dir)
	arm_left.scale.x = float(dir)
	arm_right.scale.x = float(dir)


func _start_walk_anim() -> void:
	if arm_tween and arm_tween.is_valid():
		return
	arm_tween = create_tween().set_loops()
	arm_tween.tween_property(arm_left, "rotation_degrees", 18, 0.11)
	arm_tween.parallel().tween_property(arm_right, "rotation_degrees", -18, 0.11)
	arm_tween.tween_property(arm_left, "rotation_degrees", -18, 0.11)
	arm_tween.parallel().tween_property(arm_right, "rotation_degrees", 18, 0.11)


func _stop_walk_anim() -> void:
	if arm_tween and arm_tween.is_valid():
		arm_tween.kill()
		arm_tween = null
	arm_left.rotation_degrees = 0
	arm_right.rotation_degrees = 0


func die() -> void:
	if dead:
		return
	dead = true
	_stop_walk_anim()
	get_tree().call_group("level", "show_death_message")
	velocity = Vector2(0, -120)
	var t := create_tween()
	t.tween_property(self, "modulate:a", 0.0, 0.5)
	t.parallel().tween_property(self, "rotation_degrees", float(facing) * 40.0, 0.5)
	t.tween_callback(_respawn)


func _respawn() -> void:
	dead = false
	position = checkpoint
	velocity = Vector2.ZERO
	rotation_degrees = 0
	modulate.a = 1.0
	get_tree().call_group("level", "on_player_respawned")
