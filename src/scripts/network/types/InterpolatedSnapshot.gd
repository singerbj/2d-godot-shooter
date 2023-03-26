extends Node

class_name InterpolatedSnapshot

var state : Dictionary = {}
var percentage : float
var older : String
var newer : String

func _init(_state : Dictionary,_percentage : float,_older : String,_newer : String):
	self.state = _state
	self.percentage = _percentage
	self.older = _older
	self.newer = _newer
