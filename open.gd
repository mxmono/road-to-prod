extends Node2D


@onready var forest = $Forest
@onready var forest_sprite = $Forest/Clip/Forest
@onready var forest_text = $Texts/Text1

@onready var rest = $Rest
@onready var rest_text = $Texts/Text2

@onready var climb = $Climb
@onready var climb_sprite = $Climb/Clip/Climb
@onready var climb_text = $Texts/Text3

@onready var texts = $Texts
@onready var camera = $Camera2D

@onready var skip_timer = $Timer


func _ready() -> void:
	forest.hide()
	rest.hide()
	climb.hide()
	
	for node in texts.get_children():
		node.modulate.a = 0
	
	forest.global_position = $Markers/Initial.global_position
	rest.global_position = $Markers/Initial2.global_position
	climb.global_position = $Markers/Initial3.global_position
	
	skip_timer.timeout.connect(_on_skip_timer_timeout)
	skip_timer.wait_time = 1
	
	await Utils.fade_in_screen($GUI, Color(1, 1, 1))
	
	await play_forest()
	await play_rest()
	await play_climb()


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_released("continue"):
		skip_timer.stop()
	if Input.is_action_just_pressed("continue"):
		skip_timer.start()


func _on_skip_timer_timeout():
	get_tree().change_scene_to_file("res://dev/dev.tscn")


func play_forest():
	$Forest/Robson.play("walk")
	forest.show()
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property(forest, "global_position", $Markers/End.global_position, 6).set_ease(Tween.EASE_OUT)
	tween.tween_property(forest_sprite, "position", forest_sprite.position + Vector2(150, 0), 10)
	tween.tween_property(forest_text, "modulate:a", 1, 2).set_delay(2)
	tween.play()
	await tween.finished
	tween.kill()
	
	tween = get_tree().create_tween().set_parallel()
	tween.tween_property(forest, "modulate:a", 0, 1).set_ease(Tween.EASE_OUT)
	tween.tween_property(forest_text, "modulate:a", 0, 1).set_ease(Tween.EASE_OUT)
	
	await get_tree().create_timer(1).timeout


func play_rest():
	$Rest/Robson.play("sit")
	rest.show()
	var tween = get_tree().create_tween()
	tween.tween_property(rest, "global_position", $Markers/End2.global_position, 6).set_ease(Tween.EASE_OUT)
	tween.tween_property(rest_text, "modulate:a", 1, 2).set_delay(2)
	tween.play()
	await tween.finished
	tween.kill()
	await get_tree().create_timer(8).timeout
	
	tween = get_tree().create_tween().set_parallel()
	tween.tween_property(rest, "modulate:a", 0, 1).set_ease(Tween.EASE_OUT)
	tween.tween_property(rest_text, "modulate:a", 0, 1).set_ease(Tween.EASE_OUT)
	
	await get_tree().create_timer(2).timeout
	


func play_climb():
	$Climb/Robson.play("climb")
	climb.show()
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property(climb, "global_position", $Markers/End3.global_position, 6).set_ease(Tween.EASE_OUT)
	tween.tween_property(climb_sprite, "position", climb_sprite.position + Vector2(-20, 30), 10)
	tween.tween_property(climb_text, "modulate:a", 1, 2).set_delay(2)
	tween.play()
	await tween.finished
	tween.kill()
	
	# zoom camera to transition
	camera.enabled = true
	tween = get_tree().create_tween()
	tween.tween_property(camera, "zoom", Vector2(30, 30), 1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	Utils.fade_out_screen($GUI, Color(1, 1, 1))
	
	await get_tree().create_timer(2).timeout
	
	get_tree().change_scene_to_file("res://dev/dev.tscn")
