class_name SkyManager
extends Node2D

var moon: Sprite2D
var clouds: Array = []
var patches: Array = []
var moon_visibility := 1.0
var world_width := 4200.0

func setup(p_world_width: float, ground_y: float, patch_xs: Array) -> void:
	world_width = p_world_width

	var bg := ParallaxBackground.new()
	add_child(bg)

	var sky_layer := ParallaxLayer.new()
	sky_layer.motion_scale = Vector2(0.05, 0.05)
	sky_layer.motion_mirroring = Vector2(1600, 0)
	bg.add_child(sky_layer)
	var sky := Sprite2D.new()
	sky.texture = load("res://assets/sprites/sky_stars.png")
	sky.centered = false
	sky_layer.add_child(sky)

	var castle_layer := ParallaxLayer.new()
	castle_layer.motion_scale = Vector2(0.3, 0.3)
	castle_layer.motion_mirroring = Vector2(1600, 0)
	bg.add_child(castle_layer)
	var castle := Sprite2D.new()
	castle.texture = load("res://assets/sprites/castle_far.png")
	castle.centered = false
	castle.position = Vector2(0, 120)
	castle_layer.add_child(castle)

	var far_layer := ParallaxLayer.new()
	far_layer.motion_scale = Vector2(0.5, 0.5)
	far_layer.motion_mirroring = Vector2(1600, 0)
	bg.add_child(far_layer)
	var far_buildings := Sprite2D.new()
	far_buildings.texture = load("res://assets/sprites/buildings_far.png")
	far_buildings.centered = false
	far_buildings.position = Vector2(0, 180)
	far_buildings.modulate.a = 0.95
	far_layer.add_child(far_buildings)

	var buildings_layer := ParallaxLayer.new()
	buildings_layer.motion_scale = Vector2(0.75, 0.75)
	buildings_layer.motion_mirroring = Vector2(1600, 0)
	bg.add_child(buildings_layer)
	var buildings := Sprite2D.new()
	buildings.texture = load("res://assets/sprites/buildings_mid.png")
	buildings.centered = false
	buildings.position = Vector2(0, 120)
	buildings_layer.add_child(buildings)

	moon = Sprite2D.new()
	moon.texture = load("res://assets/sprites/moon.png")
	moon.position = Vector2(world_width * 0.5, 90)
	moon.scale = Vector2(0.6, 0.6)
	add_child(moon)

	for i in range(10):
		var c := Sprite2D.new()
		c.texture = load("res://assets/sprites/cloud_%d.png" % (i % 4))
		c.position = Vector2(randf() * world_width, 40 + randf() * 180)
		c.modulate.a = 0.9
		var sc = 0.8 + randf() * 0.6
		c.scale = Vector2(sc, sc)
		c.set_meta("speed", 4.0 + randf() * 10.0)
		add_child(c)
		clouds.append(c)

	for x in patch_xs:
		var patch := {}
		patch["x"] = x
		var area := Area2D.new()
		area.monitoring = false
		var shape := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = Vector2(140, 34)
		shape.shape = rect
		area.add_child(shape)
		area.position = Vector2(x, ground_y - 6)
		area.body_entered.connect(_on_patch_entered)
		add_child(area)
		patch["area"] = area
		patches.append(patch)


func _process(delta: float) -> void:
	var occluded := false
	for c in clouds:
		c.position.x += c.get_meta("speed") * delta
		if c.position.x > world_width + 200:
			c.position.x = -200
		if absf(c.position.x - moon.position.x) < 140 and absf(c.position.y - moon.position.y) < 90:
			occluded = true

	var target := 0.15 if occluded else 1.0
	moon_visibility = lerpf(moon_visibility, target, 0.02)
	moon.modulate.a = moon_visibility

	var active := moon_visibility >= 0.6
	for patch in patches:
		patch["area"].monitoring = active


func _on_patch_entered(body: Node) -> void:
	if body is Player:
		body.die()
