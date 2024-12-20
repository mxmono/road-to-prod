class_name Splitter extends Belt

signal splitter_switched

#@export var from_direction: BeltUtils.Direction = Direction.LEFT
#@export var to_direction: BeltUtils.Direction = Direction.RIGHT
#@export var speed: float = 10  # pixel per second
#var start_pos: Vector2
#var end_pos: Vector2
#var direction: Vector2 = Vector2.RIGHT
#
#var is_moving_item: bool = false
#
#@onready var sprite = $AnimatedSprite2D
#@onready var item_holder = $ItemHolder
#@onready var area_shape = $CollisionShape2D
#@onready var next_belt_detector = $NextBeltDetector
var to_directions = [BeltUtils.Direction.UP, BeltUtils.Direction.RIGHT, BeltUtils.Direction.DOWN]
var direction_index = 0
#
#@onready var timer = $Timer
#
#
func _ready() -> void:
	self.from_direction = Direction.LEFT
	self.to_direction = to_directions[direction_index]
	
	super._ready()
	print(to_directions[0], to_directions[1], to_directions[2])
	
	sprite_still.texture = preload("res://texture/belt-splitter.png")


#enum Direction {LEFT, RIGHT, UP, DOWN}
#var to_directions = [BeltUtils.Direction.UP, BeltUtils.Direction.RIGHT, BeltUtils.Direction.DOWN]

func switch_belt():
	self.direction_index = (self.direction_index + 1) % to_directions.size()
	self.to_direction = to_directions[direction_index]
	print("direction index: ", direction_index, "  to direction: ", to_direction, " actual: ", to_directions[direction_index])
	set_up_direction()
	await direction_setup

	if get_next_belt(true) == null:
		print("no next belt")
		switch_belt()


func _on_timer_timeout():
	pass
	#switch_belt()
		#if get_next_belt() == null:
			#print("null")
		##timer.timeout.emit()

func _on_item_offloaded():
	print("offloaded")
	switch_belt()



#extends Area2D
#
#var is_moving_item: bool = false
#
#@onready var detector_top: Area2D = $TopDetector
#@onready var detector_right: Area2D = $RightDetector
#@onready var detector_bottom: Area2D = $BottomDetector
#
#@onready var item_hold = $ItemHold
#
#
#func detect_belts():
	#
	#var belts_out = []
	#
	#var top_belt = get_next_belt(detector_top, BeltUtils.Direction.UP)
	#var right_belt = get_next_belt(detector_right, BeltUtils.Direction.RIGHT)
	#var bottom_belt = get_next_belt(detector_bottom, BeltUtils.Direction.DOWN)
	#
	#if top_belt != null:
		#belts_out.append({"belt": top_belt, "direction": Vector2.UP})
	#if right_belt != null:
		#belts_out.append(right_belt)
	#if bottom_belt != null:
		#belts_out.append(bottom_belt)
	#
	#return belts_out
#
#
#func get_next_belt(detector, to_direction):
	#var areas = detector.get_overlapping_areas()
	#for area in areas:
		## if find the belt where the next belt should be
		#if area is Belt:
			## eg, self is L -> R*, next one is L* -> R
			#if to_direction == BeltUtils.flow_direction[area.from_direction]:
				#if area.can_receive_item():
					#return area
#
#
#func _physics_process(delta: float) -> void:
	#
	##if item_hold.get_child_count() == 0:
		##return
	##
	##var item = item_hold.get_child(0)
	##
	##detect_belts()
	##
	##for belt in self.belts_out:
		##belt.call_deferred("receive_item")
	#
	#
	## if no item on belt, sleep
	#if item_hold.get_child_count() == 0:
		#return
	#
	#var item = item_hold.get_child(0)
	#is_moving_item = true
	#
	#var belts_out = detect_belts()
	#
	#if belts_out.size() == 0:
		#is_moving_item = false
	#
	#if is_moving_item:
		#for belt_dict in belts_out:
			#item.global_position += belt_dict["direction"].normalized() * belt_dict["belt"].speed * delta
