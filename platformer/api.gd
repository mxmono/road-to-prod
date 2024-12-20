extends Area2D

signal collected()


func _ready() -> void:
	$AnimationPlayer.play("float")
	body_entered.connect(_on_body_entered)


func _on_body_entered(_body: Node2D):
	collected.emit()
	queue_free()
	$AnimationPlayer.play("picked")
