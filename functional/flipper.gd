extends Node2D


@export var input_action: String = "flip_left"
@export var rest_angle: float = 20.0
@export var flip_angle: float = -40.0

@onready var flipper: AnimatableBody2D = $Flipper
var enabled: bool = true 


func _ready():
	flipper.rotation_degrees = rest_angle


func _process(_delta: float) -> void:
	# if flipper stays up, down it down as correction
	if not Input.is_action_pressed(input_action):
		if is_equal_approx(flipper.rotation_degrees, flip_angle):
			drop_down()


func _input(event):
	
	if not enabled:
		return
	
	if not event is InputEventKey:
		return
	
	if Input.is_action_just_pressed(input_action):
		flip_up()

	if Input.is_action_just_released(input_action):
		drop_down()


func flip_up():
	var tween = get_tree().create_tween()
	tween.tween_property(flipper, "rotation_degrees", flip_angle, 0.16).set_trans(Tween.TRANS_CUBIC)
	tween.play()


func drop_down():
	var tween = get_tree().create_tween()
	tween.tween_property(flipper, "rotation_degrees", rest_angle, 0.05)
	tween.play()
