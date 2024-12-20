extends Control

@onready var main_scene = $".."


func _ready() -> void:
	for button: TextureButton in get_children():
		button.pressed.connect(_on_button_pressed.bind(button))


func _on_button_pressed(button: TextureButton):
	for other_button: TextureButton in get_children():
		if other_button != button: 
			other_button.texture_normal = other_button.get("texture_disabled")
	
	if not button.button_pressed:
		button.texture_normal = button.texture_disabled


func disable_all():
	for button: TextureButton in get_children():
		button.disabled = true


func reset_all():
	for button: TextureButton in get_children():
		button.button_pressed = false
		button.texture_normal = button.texture_focused  # hold of original texture


func enable_and_show_button(choice: int):
	match choice:
		main_scene.Choice.W:
			$W.visible = true
			$W.disabled = false
		main_scene.Choice.S:
			$S.visible = true
			$S.disabled = false
		main_scene.Choice.D:
			$D.visible = true
			$D.disabled = false


func hide_button(choice: int):
	match choice:
		main_scene.Choice.W:
			$W.visible = false
		main_scene.Choice.S:
			$S.visible = false
		main_scene.Choice.D:
			$D.visible = false


func disable_and_hide_button(choice: int):
	match choice:
		main_scene.Choice.W:
			$W.visible = false
			$W.disabled = true
		main_scene.Choice.S:
			$S.visible = false
			$S.disabled = true
		main_scene.Choice.D:
			$D.visible = false
			$D.disabled = true
