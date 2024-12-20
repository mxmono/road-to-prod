extends Area2D

signal shooting_start()

@onready var main_scene = $".."


func _ready() -> void:
	body_shape_entered.connect(_on_body_shape_entered)


func _on_body_shape_entered(_body_rid: RID, body: Node2D, _body_shape_index: int, local_shape_index: int):
	if body is Player:
		if local_shape_index == 0:  # leek scene trigger
			
			body.state = Player.PlayerState.CONTROL_DISABLED
			
			# zoom out
			var tween = get_tree().create_tween().set_parallel()
			tween.tween_method(body.set_camera_zoom, 2.0, 0.35, 2).set_ease(Tween.EASE_IN_OUT)
			tween.tween_method(body.set_camera_offset, Vector2(0, -64), Vector2(-900, -64), 2).set_ease(Tween.EASE_IN_OUT)
			
			await get_tree().create_timer(2).timeout
			
			# draw curves and show memory leeks
			$"../MountainShape/AnimationPlayer".play("draw_curve")
			await get_tree().create_timer(3).timeout
			$"../MountainShape/AnimationPlayer".play("draw_level")
			await get_tree().create_timer(1).timeout
			$"../MountainShape/AnimationPlayer".play("draw_baseline")
			await get_tree().create_timer(1).timeout
			
			# show arrow
			tween = get_tree().create_tween()
			tween.tween_property($"../MountainShape/Arrow", "modulate:a", 1, 0.2)
			tween.tween_interval(0.2)
			tween.tween_property($"../MountainShape/Arrow", "modulate:a", 0, 0.2)
			tween.tween_interval(0.2)
			tween.set_loops(3)
			tween.play()
			
			await tween.finished
			
			# change text
			main_scene.play_grow_leek_animation()
			await get_tree().create_timer(4).timeout
			main_scene.animate_label_change($"../GUI/Instructions", "OH NO! MEMORY LEEKS!")
			
			# zoom in on memory leeks
			await get_tree().create_timer(2).timeout
			tween = get_tree().create_tween().set_parallel()
			tween.tween_method(body.set_camera_zoom, 0.35, 0.8, 1).set_ease(Tween.EASE_IN_OUT)
			tween.tween_method(body.set_camera_offset, Vector2(-900, -64), Vector2(550, 100), 1).set_ease(Tween.EASE_IN_OUT)
			
			# remove mememory line
			await tween.finished
			tween.kill()
			$"../MountainShape".visible = false
			
			# start attacking
			main_scene.animate_label_change($"../GUI/Instructions", "POWER UP CELERY WORKERS TO DEFEAT MEMORY LEEKS")
			
			# remove trigger
			$LeekTrigger.set_deferred("disabled", true)
			
			# walk robson to canon
			tween = get_tree().create_tween()
			tween.tween_property(body, "global_position:x", 3019, 1)
			tween.play()
			await tween.finished
			tween.kill()
			body.set_animation("raise")
			shooting_start.emit()
			
