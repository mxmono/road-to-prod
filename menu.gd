extends Node2D

@onready var vbox = $Buttons/VBox
@onready var start = $Buttons/VBox/Start/Button
@onready var select = $Buttons/VBox/Select/Button
@onready var select_confirmation = $Buttons/VBox/Select/ConfirmationDialog
@onready var title = $Buttons/VBox/Title/Button
@onready var quit = $Buttons/VBox/Quit/Button


func _ready() -> void:
	for hbox: HBoxContainer in vbox.get_children():
		hbox.get_node("Arrow").modulate.a = 0
		hbox.get_node("Button").mouse_entered.connect(_on_button_hovered.bind(hbox))
		hbox.get_node("Button").mouse_exited.connect(_on_button_unhovered.bind(hbox))
	
	start.pressed.connect(_on_start_pressed)
	select.pressed.connect(_on_select_pressed)
	title.pressed.connect(_on_title_pressed)
	quit.pressed.connect(_on_quit_pressed)
	
	select_confirmation.confirmed.connect(_on_select_confirmation_confirmed)
	
	await Utils.fade_in_screen($".")
	

func _on_button_hovered(hbox):
	hbox.get_node("Arrow").modulate.a = 1


func _on_button_unhovered(hbox):
	hbox.get_node("Arrow").modulate.a = 0


func _on_start_pressed():
	Utils.fade_out_screen($".", Color(1, 1, 1))
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file("res://open.tscn")


func _on_select_pressed():
	select_confirmation.popup_centered()


func _on_select_confirmation_confirmed():
	get_tree().change_scene_to_file("res://select.tscn")
	

func _on_title_pressed():
	get_tree().change_scene_to_file("res://title.tscn")
	
	
func _on_quit_pressed():
	get_tree().quit()
