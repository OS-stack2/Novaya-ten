extends Node2D

const WORLD_WIDTH := 4200.0
const GROUND_Y := 470.0

var player: Player

func _ready() -> void:
	add_to_group("level")
	randomize()

	var sky := SkyManager.new()
	add_child(sky)
	sky.setup(WORLD_WIDTH, GROUND_Y, [500.0, 1400.0, 2100.0, 2900.0, 3700.0])

	_build_ground_and_props()
	_build_hazard_props()
	_build_soldiers()
	_build_rats()

	var tavern := Sprite2D.new()
	tavern.texture = load("res://assets/sprites/tavern.png")
	tavern.centered = false
	tavern.position = Vector2(WORLD_WIDTH - 270, GROUND_Y - 254)
	add_child(tavern)

	var exit_area := Area2D.new()
	var exit_shape := CollisionShape2D.new()
	var exit_rect := RectangleShape2D.new()
	exit_rect.size = Vector2(120, 160)
	exit_shape.shape = exit_rect
	exit_area.add_child(exit_shape)
	exit_area.position = Vector2(WORLD_WIDTH - 140, GROUND_Y - 80)
	exit_area.body_entered.connect(_on_exit_entered)
	add_child(exit_area)

	player = Player.new()
	player.position = Vector2(80, GROUND_Y - 40)
	add_child(player)

	var cam := Camera2D.new()
	cam.position_smoothing_enabled = true
	cam.limit_left = 0
	cam.limit_right = int(WORLD_WIDTH)
	cam.limit_top = 0
	cam.limit_bottom = 540
	player.add_child(cam)
	cam.make_current()

	_build_hud()


func _build_ground_and_props() -> void:
	var near_tex = load("res://assets/sprites/buildings_near.png")
	var nx := 0.0
	while nx < WORLD_WIDTH:
		var near := Sprite2D.new()
		near.texture = near_tex
		near.centered = false
		near.position = Vector2(nx, 20)
		near.z_index = -5
		add_child(near)
		nx += 1600.0

	var ground_tex = load("res://assets/sprites/ground.png")
	var gx := 0.0
	while gx < WORLD_WIDTH:
		var ground := Sprite2D.new()
		ground.texture = ground_tex
		ground.centered = false
		ground.position = Vector2(gx, GROUND_Y)
		ground.z_index = -1
		add_child(ground)
		gx += 1600.0

	var ground_body := StaticBody2D.new()
	var ground_shape := CollisionShape2D.new()
	var ground_rect := RectangleShape2D.new()
	ground_rect.size = Vector2(WORLD_WIDTH, 90)
	ground_shape.shape = ground_rect
	ground_shape.position = Vector2(WORLD_WIDTH / 2.0, GROUND_Y + 45)
	ground_body.add_child(ground_shape)
	add_child(ground_body)

	var x := 400.0
	while x < WORLD_WIDTH - 300:
		var barrel := Sprite2D.new()
		barrel.texture = load("res://assets/sprites/barrel.png")
		barrel.position = Vector2(x, GROUND_Y - 20)
		add_child(barrel)

		var body := StaticBody2D.new()
		var shape := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = Vector2(30, 36)
		shape.shape = rect
		body.add_child(shape)
		body.position = Vector2(x, GROUND_Y - 18)
		add_child(body)

		x += randf_range(350, 650)

	x = 500.0
	while x < WORLD_WIDTH - 300:
		var alive = randf() < 0.5
		var cage := Sprite2D.new()
		cage.texture = load("res://assets/sprites/cage_prisoner_alive.png" if alive else "res://assets/sprites/cage_prisoner_dead.png")
		cage.centered = false
		cage.position = Vector2(x - 20, GROUND_Y - 150)
		add_child(cage)
		var tw := cage.create_tween().set_loops()
		tw.tween_property(cage, "rotation_degrees", 4, 1.1 + randf() * 0.4)
		tw.tween_property(cage, "rotation_degrees", -4, 1.1 + randf() * 0.4)
		x += randf_range(700, 1100)

	x = 650.0
	while x < WORLD_WIDTH - 300:
		var deco := Sprite2D.new()
		if randf() < 0.5:
			deco.texture = load("res://assets/sprites/gallows.png")
			deco.centered = false
			deco.position = Vector2(x - 45, GROUND_Y - 110)
		else:
			deco.texture = load("res://assets/sprites/stocks.png")
			deco.centered = false
			deco.position = Vector2(x - 25, GROUND_Y - 40)
		deco.z_index = -2
		add_child(deco)
		x += randf_range(900, 1400)


func _build_hazard_props() -> void:
	var x := 260.0
	while x < WORLD_WIDTH - 200:
		if randf() < 0.55:
			var torch := Torch.new()
			torch.position = Vector2(x, GROUND_Y)
			add_child(torch)
		else:
			var lamp := Lamp.new()
			lamp.position = Vector2(x, GROUND_Y)
			add_child(lamp)
		x += randf_range(420, 560)

	x = 180.0
	while x < WORLD_WIDTH - 150:
		var w := WindowLight.new()
		w.position = Vector2(x, GROUND_Y - 150 - randf() * 60)
		add_child(w)
		x += randf_range(220, 340)


func _build_soldiers() -> void:
	var routes = [[760.0, 1180.0, 900.0], [2000.0, 2480.0, 2200.0], [3100.0, 3600.0, 3300.0]]
	for r in routes:
		var s := Soldier.new()
		s.position = Vector2(r[2], GROUND_Y)
		s.setup(r[0], r[1])
		add_child(s)


func _build_rats() -> void:
	var kinds = ["normal", "plague", "skeleton"]
	for i in range(9):
		var cx = 300.0 + i * 420.0 + randf() * 100.0
		var rat := Rat.new()
		rat.position = Vector2(cx, GROUND_Y)
		rat.setup(kinds[i % 3], cx - 70, cx + 70)
		add_child(rat)


var hud_text: Label
var death_text: Label

func _build_hud() -> void:
	hud_text = Label.new()
	hud_text.text = "A/D или ←/→ — идти, Пробел — прыжок.\nДержись в тени: свет убивает."
	hud_text.position = Vector2(16, 16)
	hud_text.add_theme_color_override("font_color", Color(0.8, 0.72, 1.0))
	hud_text.z_as_relative = false
	var canvas := CanvasLayer.new()
	canvas.add_child(hud_text)
	add_child(canvas)

	var tw := hud_text.create_tween()
	tw.tween_interval(4.5)
	tw.tween_property(hud_text, "modulate:a", 0.0, 1.2)

	death_text = Label.new()
	death_text.text = ""
	death_text.position = Vector2(380, 260)
	death_text.add_theme_color_override("font_color", Color(1.0, 0.53, 0.53))
	death_text.modulate.a = 0.0
	canvas.add_child(death_text)
	death_canvas_ref = death_text


var death_canvas_ref: Label

func on_player_respawned() -> void:
	pass


func show_death_message() -> void:
	death_text.text = "Свет настиг тебя..."
	death_text.modulate.a = 1.0
	var tw := death_text.create_tween()
	tw.tween_interval(0.7)
	tw.tween_property(death_text, "modulate:a", 0.0, 0.7)


func _on_exit_entered(body: Node) -> void:
	if body is Player:
		get_tree().change_scene_to_file("res://scenes/Level2Stub.tscn")
