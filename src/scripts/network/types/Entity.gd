extends Node

class_name Entity

var id # TODO: right now can be any type of value - maybe that's ok? maybe its not?

func _ready():
	if !has_method("get_class_name"):
		push_error("This entity does not have a get_class_name function")
	elif typeof(call("get_class_name")) != TYPE_STRING:
		push_error("get_class_name does not return string for this entity")
	if !has_method("serialize"):
		push_error("This entity does not have a serialize function")
	if !has_method("deserialize"):
		push_error("This entity does not have a deserialize function")
	if !"interpolation_parameters" in self:
		push_error("This entity does not have interpolation_parameters variable")
	elif typeof(self.interpolation_parameters) != TYPE_ARRAY:
		push_error("This entity's interpolation_parameters variable is not an Array")
		
func get_interpolation_parameters() -> Array:
	if "interpolation_parameters" in self:
		return self.interpolation_parameters
	else:
		return []
		
		

