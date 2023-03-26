extends Node


class_name NetworkInputManager

var _input_buffers = {}
var _last_processed_inputs = {}
var _buffer_max_size

func _init(buffer_max_size : int):
	_buffer_max_size = buffer_max_size
	
func add_input(peer_id : int, input : NetworkInput) -> void:
	if !peer_id in _input_buffers:
		_input_buffers[peer_id] = []
	
	_input_buffers[peer_id].append(input)
	
	if _input_buffers[peer_id].size() > _buffer_max_size:
		_input_buffers[peer_id].pop_front()
	
func get_ids() -> Array:
	return _input_buffers.keys()
	
func get_input_buffer(peer_id : int) -> Array:
	if !peer_id in _input_buffers:
		_input_buffers[peer_id] = []
	_input_buffers[peer_id].sort_custom(Callable(NetworkUtil,"sort_network_inputs"))
	return _input_buffers[peer_id]
	
func get_and_clear_input_buffer(peer_id : int) -> Array:
	if !peer_id in _input_buffers:
		_input_buffers[peer_id] = []
	_input_buffers[peer_id].sort_custom(Callable(NetworkUtil,"sort_network_inputs"))
	var input_buffer_copy = [] + _input_buffers[peer_id]
	_input_buffers[peer_id] = []
	return input_buffer_copy

func set_last_processed_input_id(peer_id : int, input_id : int) -> void:
	_last_processed_inputs[peer_id] = input_id
	
func get_last_processed_input_ids() -> Dictionary:
	return _last_processed_inputs
