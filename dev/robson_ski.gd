class_name PlayerSki extends CharacterBody2D


enum State {
	CONTROL_DISABLED,
	SKI,
}

var state = State.CONTROL_DISABLED
@export var speed = 250
@export var camera_limit_left: int = -1000
@export var camera_limit_right: int = 1000

@onready var camera: Camera2D = $Camera2D
@onready var label: Label = $Label
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	
	camera.limit_left = camera_limit_left
	camera.limit_right = camera_limit_right
	
	label.modulate.a = 0


func _physics_process(_delta: float) -> void:
	
	if state != State.SKI:
		velocity = Vector2.ZERO
	
	else:
		# constantly move up
		velocity.y = -speed
		
		var direction := Input.get_axis("move_left", "move_right")
		if direction:
			velocity.x = direction * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()


func smashed():
	"""When hit, turn off control and collision for 1 sec."""
	
	state = State.CONTROL_DISABLED
	var tween = get_tree().create_tween().set_loops(5)
	tween.tween_property(self, "modulate:a", 0, 0.1)
	tween.tween_property(self, "modulate:a", 1, 0.1)
	tween.play()
	await tween.finished
	
	state = State.SKI


func flash_label(label_text = "+1"):
	label.text = label_text
	var tween = get_tree().create_tween().set_loops(2)
	tween.tween_property(label, "modulate:a", 1, 0.1)
	tween.tween_property(label, "modulate:a", 0, 0.1)
	tween.play()
