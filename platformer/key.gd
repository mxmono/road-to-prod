extends Area2D

@onready var main_scene = $"../.."


func _ready() -> void:
	body_shape_entered.connect(_on_body_shape_entered)


func _on_body_shape_entered(_body_rid: RID, body: Node2D, _body_shape_index: int, local_shape_index: int):
	if body is Player:
		if local_shape_index == 0:  # key blocker trigger
			if main_scene.collected_apis >= main_scene.total_apis:
				for cell in $KeyBlocker.get_used_cells():
					$KeyBlocker.erase_cell(cell)
					await get_tree().create_timer(0.2).timeout
				$Label.visible = false
		
		elif local_shape_index == 1:  # keybox
			# play open key anime
			$Key.play("default")
			
			# remove onsen blocker pillar
			if is_instance_valid($OnsenBlocker):
				for cell in $OnsenBlocker/Blocker.get_used_cells():
					$OnsenBlocker/Blocker.erase_cell(cell)
					await get_tree().create_timer(0.2).timeout
				$OnsenBlocker.queue_free()
			
			$"../../Water/Curtain/CollisionShape2D".disabled = false
