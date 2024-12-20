extends Node2D

@onready var platform = $AnimatableBody2D
@onready var tilemap = $AnimatableBody2D/TileMapLayer
@onready var sprite = $AnimatableBody2D/AnimatedSprite2D
@export var variation: int = 0
@export var move_destination = Vector2(50, 0)
@export var speed: float = 50.0
var tween: Tween


func _ready() -> void:
	set_style()
	set_movement()


func set_style():

	tilemap.clear()
	
	match self.variation:
		0:  # grass
			tilemap.set_cell(Vector2i(0, 0), 0, Vector2i(1, 0), 0)
			tilemap.set_cell(Vector2i(1, 0), 0, Vector2i(2, 0), 0)
			tilemap.set_cell(Vector2i(2, 0), 0, Vector2i(3, 0), 0)
			sprite.play("default")
		1:  # golden
			tilemap.set_cell(Vector2i(0, 0), 0, Vector2i(1, 2), 0)
			tilemap.set_cell(Vector2i(1, 0), 0, Vector2i(2, 2), 0)
			tilemap.set_cell(Vector2i(2, 0), 0, Vector2i(3, 2), 0)
			sprite.play("default")
		2:  # snow
			tilemap.set_cell(Vector2i(0, 0), 0, Vector2i(1, 4), 0)
			tilemap.set_cell(Vector2i(1, 0), 0, Vector2i(2, 4), 0)
			tilemap.set_cell(Vector2i(2, 0), 0, Vector2i(3, 4), 0)
			sprite.play("snow")


func  _exit_tree() -> void:
	if tween:
		tween.stop()


func set_movement():
	if tween:
		tween.kill()
	tween = get_tree().create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.set_loops().set_parallel(false)
	var t = move_destination.length() / speed
	tween.tween_property(platform, "position", self.move_destination, t).set_ease(Tween.EASE_IN_OUT)
	tween.tween_interval(0.2)
	tween.tween_property(platform, "position", Vector2(0, 0), t).set_ease(Tween.EASE_IN_OUT)
	tween.tween_interval(0.2)
	tween.play()
