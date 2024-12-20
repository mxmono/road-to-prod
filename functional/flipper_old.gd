extends Node2D


@export var flip_strength: float = -1000.0
@export var input_action: String = "flip_left"
@onready var flipper: RigidBody2D = $Flipper


func _physics_process(_delta: float) -> void:
	
	if Input.is_action_pressed(input_action):
		#flipper.apply_torque(flip_strength)
		flipper.apply_torque_impulse(flip_strength)
		#flipper.freeze = false
	
	#elif Input.is_action_pressed(input_action):
		#flipper.rotation_degrees = -30
		#flipper.freeze = true
		#flipper.freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	
	else:
		flipper.apply_torque_impulse(-flip_strength)
		#flipper.freeze = false
