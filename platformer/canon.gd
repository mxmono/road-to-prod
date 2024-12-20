extends Node2D

@export var bullet_velocity = 2000
@export var enabled = false

@onready var timer := $Cooldown as Timer


func _ready() -> void:
	pass


func _physics_process(_delta: float) -> void:
	if not enabled:
		return
	
	var angle: float = global_position.direction_to(get_global_mouse_position()).angle()
	angle = clampf(angle, Vector2.UP.angle(), Vector2.DOWN.angle())
	var direction: Vector2 = Vector2.from_angle(angle)
	
	$Canon.rotation = angle
	
	if Input.is_action_pressed("fire"):
		shoot(direction)


func shoot(direction: Vector2) -> bool:
	if not timer.is_stopped():
		return false
	
	var canon_ball: CanonBall = preload("res://platformer/canon_ball.tscn").instantiate()
	canon_ball.global_position = $Canon/Marker2D.global_position
	canon_ball.linear_velocity = direction * bullet_velocity
	var _scale = randf()  * 2 + 1
	canon_ball.scale = Vector2(_scale, _scale)
	
	canon_ball.set_as_top_level(true)
	add_child(canon_ball)
	timer.start()
	return true


func set_canon_rotation_degrees(degrees: float):
	$Canon.rotation_degrees = degrees


func set_animation(anime_name: String):
	$Canon.play(anime_name)
