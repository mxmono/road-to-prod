class_name Belt extends Area2D

signal item_received
signal item_offloaded
signal direction_setup

var flow_direction: Dictionary = BeltUtils.flow_direction
var Direction = BeltUtils.Direction

@export var from_direction: BeltUtils.Direction = Direction.LEFT
@export var to_direction: BeltUtils.Direction = Direction.RIGHT
@export var speed: float = 10  # pixel per second
var start_pos: Vector2
var end_pos: Vector2
var direction: Vector2 = Vector2.RIGHT

var is_moving_item: bool = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var sprite_still: Sprite2D = $Sprite2D
@onready var item_holder: Node2D = $ItemHolder
@onready var area_shape: CollisionShape2D = $CollisionShape2D
@onready var next_belt_detector: Area2D = $NextBeltDetector


func _ready() -> void:
	
	# set up belt sprite and directions
	set_up_direction()
	sprite_still.texture = null
	
	# connect signals
	area_shape_exited.connect(_on_area_shape_exited)
	
	item_received.connect(_on_item_received)
	item_offloaded.connect(_on_item_offloaded)


func _physics_process(delta: float) -> void:
	
	# if no item on belt, sleep
	if item_holder.get_child_count() == 0:
		return
	
	var item = item_holder.get_child(0)
	is_moving_item = true
	
	var next_belt = get_next_belt()
	
	if next_belt == null:  # can't proceed to next belt
		if is_equal_approx(item.global_position.x, end_pos.x):
			if is_equal_approx(item.global_position.y, end_pos.y):
				is_moving_item = false
	
	if is_moving_item:
		if from_direction == flow_direction[to_direction]:  # if straight
			item.global_position += direction.normalized() * speed * delta
		else:  # if corner
			if from_direction == Direction.LEFT or from_direction == Direction.RIGHT:
				if not is_equal_approx(item.global_position.x, end_pos.x):
					item.global_position += Vector2(direction.x, 0) * speed * delta
				else:
					item.global_position += Vector2(0, direction.y) * speed * delta
			else:
				if not is_equal_approx(item.global_position.x, end_pos.x):
					item.global_position += Vector2(0, direction.y) * speed * delta
				else:
					item.global_position += Vector2(direction.x, 0) * speed * delta


func get_next_belt(log = false):
	if log:
		print("detector position: ", next_belt_detector.position)
	var areas = next_belt_detector.get_overlapping_areas()
	if log:
		print(areas)
	for area in areas:
		# if find the belt where the next belt should be
		if area is Belt:
			if log:
				print("belt area: ", area.name)
				print("next belt from: ", area.from_direction)
				print("self to: ", self.to_direction)
				print("flow for self to: ", flow_direction[self.to_direction])
			# eg, self is L -> R*, next one is L* -> R
			if area.from_direction == flow_direction[self.to_direction]:
				if area.can_receive_item():
					return area


func _on_area_exited(area):
	#if area is BeltItem:
		##print("exited")
		#var next_belt = get_next_belt()
		#if next_belt != null:
			#print("belt ", self.name, " exited at ", area.global_position, ", next belt ", next_belt.name)
			#item_offloaded.emit()
			##print(next_belt)
			#next_belt.call_deferred("receive_item", area)
	pass


func _on_area_shape_exited(area_rid, area, area_shape_index, local_shape_index):
	if area is BeltItem and local_shape_index == 0:
		#print("exited")
		var next_belt = get_next_belt()
		if next_belt != null:
			#print("belt ", self.name, " exited at ", area.global_position, ", next belt ", next_belt.name)
			item_offloaded.emit()
			#print(next_belt)
			next_belt.call_deferred("receive_item", area)
	

func set_up_direction():
	
	# position to detect belt item leaving the area
	end_pos = $Markers/C.global_position
	
	if from_direction == Direction.RIGHT:
		start_pos = $Markers/R.global_position
		if to_direction == Direction.LEFT:
			sprite.play("left")
			direction = Vector2.LEFT
		elif to_direction == Direction.UP:
			pass
		elif to_direction == Direction.DOWN:
			pass
	
	elif from_direction == Direction.LEFT:
		start_pos = $Markers/L.global_position
		if to_direction == Direction.RIGHT:
			sprite.play("right")
			direction = Vector2.RIGHT
		elif to_direction == Direction.UP:
			sprite.play("right_up")
			direction = Vector2.RIGHT + Vector2.UP
		elif to_direction == Direction.DOWN:
			sprite.play("right_down")
			direction = Vector2.RIGHT + Vector2.DOWN

	elif from_direction == Direction.DOWN:
		start_pos = $Markers/B.global_position
		if to_direction == Direction.UP:
			sprite.play("up")
			direction = Vector2.UP
		elif to_direction == Direction.LEFT:
			pass
		elif to_direction == Direction.RIGHT:
			pass
	
	elif from_direction == Direction.UP:
		start_pos = $Markers/T.global_position
		if to_direction == Direction.DOWN:
			sprite.play("down")
			direction = Vector2.DOWN
		elif to_direction == Direction.LEFT:
			pass
		elif to_direction == Direction.RIGHT:
			pass
	
	# area shape center position is in between start and end
	area_shape.global_position = (start_pos + end_pos) / 2
	
	# detect next belt based on "to" facing
	if to_direction == Direction.RIGHT:
		next_belt_detector.global_position = $Markers/NextRight.global_position
		
	elif to_direction == Direction.LEFT:
		next_belt_detector.global_position = $Markers/NextLeft.global_position
	
	elif to_direction == Direction.UP:
		next_belt_detector.global_position = $Markers/NextUp.global_position
	
	elif to_direction == Direction.DOWN:
		next_belt_detector.global_position = $Markers/NextDown.global_position
	
	direction_setup.emit()


func can_receive_item():
	# if already has an item, can't receive item
	if item_holder.get_child_count() > 0:
		return false
	
	return true


func receive_item(item: BeltItem):
	#item.moving = true
	#item.direction = direction
	##item.travel_from = from_direction
	##item.travel_to = to_direction
	#item.start_pos = start_pos
	#item.end_pos = end_pos
	#item.call_deferred("reparent", item_holder, true)
	item.reparent(item_holder, true)
	item_received.emit()
	#item_holder.print_tree()
	#item.reparent(item_holder, true)
	#item_holder.is_moving_item = true

func _on_item_received():
	print(self.name, " received")


func _on_item_offloaded():
	pass


func _on_direction_setup():
	pass
