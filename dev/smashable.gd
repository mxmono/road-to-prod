extends Area2D


@onready var sprite = $AnimatedSprite2D


func _ready() -> void:
	sprite.play("snowman")
	sprite.frame = 0
	sprite.pause()
	body_entered.connect(_on_body_entered)


func _on_body_entered(body):
	if body is PlayerSki:
		set_deferred("monitoring", false)
		play_kill_animation()
		await sprite.animation_finished
		self.queue_free()


func play_kill_animation():
	sprite.play("snowman")
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property(self, "position", self.position - Vector2(0, 200), 0.2)
	tween.tween_property(self, "rotation_degrees", 720, 0.2)
	tween.play()
