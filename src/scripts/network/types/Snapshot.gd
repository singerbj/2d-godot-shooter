extends Node

class_name Snapshot

var id : String
var time : float
var state : Dictionary = {}
var last_processed_input_ids : Dictionary

func _init(_id : String = "", _time : float = -1.0, _state : Dictionary = {}, _last_processed_input_ids : Dictionary = {}):
	self.id = _id
	self.time = _time
	self.state = _state
	self.last_processed_input_ids = _last_processed_input_ids
	
func is_valid():
	return time != -1
	
# TODO: These serialize and deserialize state functions could be heavily optimized - not sure how to
#	make them work with unknown length array values
func serialize():
	var serialized_state = []
	for entity in state.values():
		serialized_state.append({ 
			"name": entity.get_class_name(),
			"data": entity.serialize() 
		})
	return {
		"id": id,
		"time": time,
		"state": serialized_state,
		"last_processed_input_ids": last_processed_input_ids
	}

func deserialize(entity_classes : Dictionary, serialized_snapshot : Dictionary):
	var deserialized_state = {}
	for serialized_entity in serialized_snapshot["state"]:
		var deserialized_entity : Entity = entity_classes[serialized_entity["name"]].new(serialized_entity["data"])
		deserialized_state[deserialized_entity["id"]] = deserialized_entity
	return get_script().new(
		serialized_snapshot["id"], 
		serialized_snapshot["time"], 
		deserialized_state, 
		serialized_snapshot["last_processed_input_ids"]
	)
	
