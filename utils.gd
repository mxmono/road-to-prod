extends Node


func flash_screen(color_rect: ColorRect):
	if not color_rect.visible:
		color_rect.show()
	var tween = get_tree().create_tween()
	tween.tween_property(color_rect, "color", Color(1, 1, 1, 0.8), 0.25).set_ease(Tween.EASE_OUT_IN)
	tween.tween_property(color_rect, "color", Color(1, 1, 1, 0), 0.25).set_ease(Tween.EASE_OUT_IN)
	tween.play()
	await tween.finished
	tween.kill()


func flash_label(label: Label, num_loops: int = 2, color: Color = Color("92e5a9")):
	var tween = get_tree().create_tween().set_loops(num_loops)
	var original_color = label.modulate
	tween.tween_property(label, "modulate", color, 0.1)
	tween.tween_property(label, "modulate", original_color, 0.1)
	tween.play()
	

func fade_out_screen(parent: Node, fade_color: Color = Color(0, 0, 0), duration: float = 1):
	var rect = ColorRect.new()
	rect.size = get_viewport().size
	rect.color = fade_color
	rect.color.a = 0
	
	parent.add_child(rect)
	
	var tween = get_tree().create_tween()
	tween.tween_property(rect, "color:a", 1, duration).set_ease(Tween.EASE_OUT_IN)
	tween.play()
	await tween.finished
	tween.kill()


func fade_in_screen(parent: Node, fade_color: Color = Color(0, 0, 0), duration: float = 1):
	var rect = ColorRect.new()
	rect.size = get_viewport().size
	rect.color = fade_color
	rect.color.a = 1
	
	parent.add_child(rect)
	
	var tween = get_tree().create_tween()
	tween.tween_property(rect, "color:a", 0, duration).set_ease(Tween.EASE_OUT_IN)
	tween.play()
	await tween.finished
	tween.kill()
	
	rect.queue_free()
