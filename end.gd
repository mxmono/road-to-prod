extends Node2D

@onready var menu_button = $GUI/Button


func _ready() -> void:
	menu_button.hide()
	menu_button.pressed.connect(_on_menu_button_clicked)
	
	await Utils.fade_in_screen($GUI, Color(1, 1, 1))
	await get_tree().create_timer(1).timeout
	menu_button.show()
	
	
func _on_menu_button_clicked():
	get_tree().change_scene_to_file("res://menu.tscn")
