extends Area2D

@export var speed = 200
@onready var sprite = $AnimatedSprite2D
@onready var timer = $Timer


func _ready() -> void:
	sprite.play("roll")
	body_entered.connect(_on_body_entered)
	timer.timeout.connect(_on_timer_timeout)


func _physics_process(delta: float) -> void:
	position.y += speed * delta
 

func _on_body_entered(body):
	if body is PlayerSki:
		set_deferred("monitoring", false)
		body.smashed()
		play_kill_animation()
		await sprite.animation_finished
		self.queue_free()


func play_kill_animation():
	sprite.play("smash")
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property(self, "position", self.position - Vector2(0, 200), 0.2)
	tween.tween_property(self, "rotation_degrees", 720, 0.2)
	tween.play()


func _on_timer_timeout():
	self.queue_free()
