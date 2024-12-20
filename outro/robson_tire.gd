class_name PlayerTire extends CharacterBody2D

enum State {
	CONTROL_DISABLED,
	NORMAL,
}

var state = State.CONTROL_DISABLED
var speed = 500
@onready var sprite = $Robson
@onready var camera = $Camera2D
#@export var speed = 300.0
#@export var jump_force = 600.0
#@export var gravity: float = 1200.0
#@export var jump_decay_rate: float = 0.9
#var is_jumping: bool = false
#var can_double_jump: bool = true
#
#
#@onready var sprite = $Robson


func _ready() -> void:
	pass


func _input(_event: InputEvent) -> void:
	
	if state == State.CONTROL_DISABLED:
		return
	
	if Input.is_action_just_pressed("jump"):
		sprite.play("jump")
		await sprite.animation_finished
		sprite.play("run")


func _physics_process(_delta: float) -> void:
	if state == State.CONTROL_DISABLED:
		return
	
	var direction := Input.get_axis("move_up", "move_down")
	if direction:
		velocity.y = direction * speed
	else:
		velocity.y = move_toward(velocity.y, 0, speed)
	move_and_slide()

#
#func _physics_process(delta: float) -> void:
	#
	## move right constantly
	#velocity.x = speed
	#
	## apply gravity
	#velocity.y += gravity * delta
#
	## jump
	#if Input.is_action_just_pressed("jump"):
		#if is_on_floor():
			#velocity.y = -jump_force
			#is_jumping = true
		#elif can_double_jump:
			#velocity.y = -jump_force
			#can_double_jump = false
	#
	#if not is_on_floor() and velocity.y < 0:
		#is_jumping = true
	#
	#if is_on_floor():
		#sprite.play("run")
		#is_jumping = false
		#can_double_jump = true
	#
	#if is_jumping and velocity.y < 0:
		#sprite.play("jump")
		##velocity.y *= jump_decay_rate
	#
	#
	#move_and_slide()
