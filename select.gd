extends Node2D

@onready var vbox = $Buttons/VBox

var stage_mapping = {
	"Intro": preload("res://open.tscn"),
	"Dev": preload("res://dev/dev.tscn"),
	"Coverage": preload("res://coverage/coverage.tscn"),
	"Functional": preload("res://functional/functional.tscn"),
	"NFR": preload("res://nfr/nfr.tscn"),
	"Dodge": preload("res://dodge/dodge.tscn"),
	"Soak": preload("res://platformer/soak.tscn"),
	"Outro": preload("res://outro/outro.tscn"),
	"Menu": preload("res://menu.tscn"),
}


func _ready() -> void:
	for hbox: HBoxContainer in vbox.get_children():
		hbox.get_node("Arrow").modulate.a = 0
		
		if hbox.has_node("Button"):
			var button = hbox.get_node("Button")
			hbox.get_node("Button").mouse_entered.connect(_on_button_hovered.bind(hbox))
			hbox.get_node("Button").mouse_exited.connect(_on_button_unhovered.bind(hbox))
			button.pressed.connect(_on_stage_selected.bind(button.get_parent().name))
	
	await Utils.fade_in_screen($".", Color(1, 1, 1), 0.5)


func _on_button_hovered(hbox):
	hbox.get_node("Arrow").modulate.a = 1


func _on_button_unhovered(hbox):
	hbox.get_node("Arrow").modulate.a = 0


func _on_stage_selected(stage_name):
	get_tree().change_scene_to_packed(stage_mapping[stage_name])
