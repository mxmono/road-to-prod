class_name Player
extends CharacterBody2D

signal player_died()


enum PlayerState {
	NORMAL,
	JUMPING,
	FLOATING,
	DEAD,
	CONTROL_DISABLED,
}

@export var speed = 200
@export var acceleration_speed = speed * 18.0
@export var jump_velocity = -300.0
@export var terminal_velocity = 700  # maximum speed at which the player can fall
@export var vertical_enabled = true
@export var camera_enabled = true

@onready var camera = $Camera2D
@onready var sprite = $AnimatedSprite2D

var gravity: int = ProjectSettings.get("physics/2d/default_gravity")
var state = PlayerState.NORMAL


func _ready() -> void:
	$Camera2D.enabled = self.camera_enabled
	$Label.hide()
	set_animation("default")


func disable_camera():
	$Camera2D.enabled = false
	
	
func _physics_process(delta: float) -> void:
	
	if self.state == PlayerState.DEAD:
		return
	
	if self.state == PlayerState.CONTROL_DISABLED:
		return
	
	# only allow jumping in scroll mode (left right only)
	if not self.vertical_enabled:
		if is_on_floor() and Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity
		
		# fall
		velocity.y = minf(terminal_velocity, velocity.y + gravity * delta)
	
	# get direction depending on if top down or left right
	var direction
	
	if self.vertical_enabled:
		direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		velocity = direction * speed
	else:
		direction = Input.get_axis("move_left", "move_right")
		velocity.x = move_toward(velocity.x, direction * speed, acceleration_speed * delta)

	if not is_zero_approx(velocity.x):
		if velocity.x > 0.0:
			$AnimatedSprite2D.flip_h = false
		else:
			$AnimatedSprite2D.flip_h = true

	#floor_stop_on_slope = not platform_detector.is_colliding()
	
	# play animation accordingly
	if self.state == PlayerState.NORMAL or self.state == PlayerState.JUMPING:
		if self.vertical_enabled:
			if velocity.normalized().length() > 0:
				set_animation("default")
			else:
				$AnimatedSprite2D.stop()
		else:
			if abs(velocity.x) > 0:
				set_animation("default")
			else:
				$AnimatedSprite2D.stop()
	
	elif self.state == PlayerState.FLOATING:
		set_animation("float")
	
	# move
	move_and_slide()


func set_label(text: String, label_scale: Vector2 = Vector2(1, 1), label_color = Color("dd6564")):
	$Label.show()
	$Label.scale = label_scale
	$Label.modulate = label_color
	$Label.text = text


func hide_label():
	$Label.hide()


func set_state(player_state):
	state = player_state


func die():
	self.state = PlayerState.DEAD
	player_died.emit()
	velocity = Vector2.ZERO
	set_animation("die")
	

func revive():
	self.state = PlayerState.NORMAL
	set_animation("default")


func set_animation(animation_name: String):
	$AnimatedSprite2D.play(animation_name)


func set_camera_zoom(zoom: float):
	$Camera2D.zoom = Vector2(zoom, zoom)


func set_camera_offset(offset: Vector2):
	$Camera2D.offset = offset
