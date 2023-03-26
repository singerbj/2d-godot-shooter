extends Node

class_name NetworkInput

var id : int
var delta : float
var time : int
var data : Dictionary

func _ready():
	if !has_method("serialize"):
		push_error("This entity does not have a serialize function")
	if !has_method("deserialize"):
		push_error("This entity does not have a deserialize function")
		
func _set_required_data(_id : int = 0, _delta : float = 0.0, _time : int = 0):
	self.id = _id
	self.delta = _delta
	self.time = _time
