class_name ItemHolder extends Node2D

#var is_moving_item: bool = false


#func _ready() -> void:
	#pass
#
#
##func receive_item(item: BeltItem):
	##item.call_deferred("reparent", self, true)
	##is_moving_item = true
#
#
#func offload_item():
	#if get_child_count() == 0:
		#return
	##
	##var item: BeltItem = get_child(0)
	##return item
#
#
#func hold_item():
	#is_moving_item = false
	#
#
#func _physics_process(delta: float) -> void:
	##pass
	#if not is_moving_item or get_child_count() == 0:
		#return
	#
	#var item: BeltItem = get_child(0)
	#item.global_position += item.direction * item.speed * delta
