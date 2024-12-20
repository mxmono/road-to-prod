class_name Dialog extends Polygon2D

signal dialog_finished
var dialog_typing: bool = false

enum Character {
	ROBSON,
	GHOSTY,
	STAKEHOLDER,
}

var colors: Dictionary = {
	Character.ROBSON: Color("1d9dae"),
	Character.GHOSTY: Color("de557b"),
	Character.STAKEHOLDER: Color("de557b"),
}
 
var portraits: Dictionary = {
	Character.ROBSON: Rect2(Vector2(32, 32), Vector2(32, 32)),
	Character.GHOSTY: Rect2(Vector2(32, 0), Vector2(32, 32)),
	Character.STAKEHOLDER: Rect2(Vector2(32, 0), Vector2(32, 32)),
}

var names: Dictionary = {
	Character.ROBSON: "ROBSON",
	Character.GHOSTY: "???",
	Character.STAKEHOLDER: "STAKEHOLDER",
}

@export var character: Character = Character.ROBSON

@onready var name_label = $Name
@onready var dialog = $Dialog
@onready var sprite = $Sprite2D

var dialog_full_text: String = ""


func _ready() -> void:
	name_label.text = names[character]
	name_label.modulate = colors[character]
	sprite.region_rect = portraits[character]


func show_dialog(dialog_character: Character, dialog_text: String):
	self.dialog_full_text = dialog_text
	name_label.text = names[dialog_character]
	name_label.modulate = colors[dialog_character]
	sprite.region_rect = portraits[dialog_character]
	dialog_typing = true
	await type_text(dialog_text, 0.05)
	dialog_typing = false
	dialog_finished.emit()


func type_text(full_text: String, delay: float = 0.05) -> void:
	dialog.text = ""
	for i in range(full_text.length()):
		dialog.text += full_text[i]
		await get_tree().create_timer(delay).timeout
