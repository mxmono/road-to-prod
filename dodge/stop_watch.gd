class_name Stopwatch
extends Label

var timer : float = 0.0
var is_on : bool = false
var threshold: float = 1.0


func _process(delta : float):
	if is_on:
		timer += delta
		# time in seconds, with 3 decimal places
		self.text = String.num(timer, 2) + "s"
	
		if timer > threshold:
			self.modulate = Color("f2a383")


func start():
	is_on = true


func stop():
	is_on = false


func reset():
	timer = 0.0
	self.text = "0.00s"
	self.modulate = Color("white")
