class_name BeltItem extends Node2D

enum Direction {LEFT, RIGHT, UP, DOWN}
var travel_from: Direction = Direction.LEFT
var travel_to: Direction = Direction.RIGHT
var start_pos: Vector2
var end_pos: Vector2
var speed: float = 10  # pixel per second
var moving: bool = true
var direction: Vector2 = Vector2.RIGHT
#@export var time: int = 1


func _ready() -> void:
	#var tween = get_tree().create_tween()
	#tween.tween_property(self, "global_position", Vector2(63, 72), 1)
	#tween.play()
	pass


func _physics_process(delta: float) -> void:
	#if moving:
		#global_position += direction * speed * delta
	pass
