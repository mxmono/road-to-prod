extends Control

func _ready():
	$PanelContainer/VBoxContainer/Resume.pressed.connect(_on_resume_pressed)
	$PanelContainer/VBoxContainer/Restart.pressed.connect(_on_restart_pressed)
	$PanelContainer/VBoxContainer/Select.pressed.connect(_on_select_pressed)
	$PanelContainer/VBoxContainer/Menu.pressed.connect(_on_menu_pressed)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if get_tree().paused:
			get_tree().paused = false
			hide()
		else:
			get_tree().paused = true
			show()


func _on_resume_pressed():
	hide()
	get_tree().paused = false


func _on_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()
	

func _on_select_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://select.tscn")


func _on_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://menu.tscn")
