extends Node2D

@onready var robson = $Robson
@onready var timer = $Timer  # allowed time before skipping
var allow_transition: bool = false


func _ready() -> void:
	
	robson.global_position = $Markers/Start.global_position
	$TextBox.hide()
	$TextBox/Hi.text = "HI, I'M ROBSON!"
	
	timer.wait_time = 3
	timer.start()
	timer.timeout.connect(_on_timer_timeout)
	
	play_intro()


func _input(_event):
	if timer.is_stopped():
		if Input.is_action_just_pressed("continue") and allow_transition == true:
			allow_transition = false
			go_to_menu()


func _on_timer_timeout():
	timer.stop()
	allow_transition = true
	
	
func go_to_menu():
	Utils.fade_out_screen($".")
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file("res://menu.tscn")


func play_intro():
	
	# wait
	await get_tree().create_timer(2).timeout
	
	# robson peaks
	robson.global_position = $Markers/Peek.global_position
	robson.play("peek")
	await robson.animation_finished
	await get_tree().create_timer(1).timeout
	
	# robson walks in
	robson.global_position = $Markers/Start.global_position
	robson.play("walk")
	var tween = get_tree().create_tween()
	tween.tween_property(robson, "global_position", $Markers/Hi.global_position, 3)
	tween.play()
	await tween.finished
	await get_tree().create_timer(0.5).timeout
	
	# robson says hi
	robson.play("hi")
	await get_tree().create_timer(1).timeout
	$TextBox.show()
	await get_tree().create_timer(2).timeout
	$TextBox/Hi.text = "LET'S GO!"
	await get_tree().create_timer(2).timeout
	$TextBox/Hi.text = "CLICK TO START!"
