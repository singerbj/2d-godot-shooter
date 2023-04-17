extends Node

class_name SnapshotInterpolationManager

var vault 

var _name : String
var _network_config
var _interpolation_buffer
var _auto_correct_time_offset
var _whitespace_regex : RegEx
var _time_offset: float = -1.0

var server_time = 0

func _init(name : String,network_config : NetworkConfig,auto_correct_time_offset : bool):
	_name = name
	_network_config = network_config
	vault = Vault.new(_network_config)
	_interpolation_buffer = (1000 / Engine.physics_ticks_per_second) * _network_config.DEFAULT_INTERPOLATION_BUFFER_MULTIPLIER
	_auto_correct_time_offset = auto_correct_time_offset
	_whitespace_regex = RegEx.new()
	_whitespace_regex.compile("\\W+")

func create_snapshot(state : Dictionary, last_processed_input_ids : Dictionary):
	var new_id = NetworkUtil.gen_unique_string(6)
	return Snapshot.new(new_id, Time.get_unix_time_from_system(), state, last_processed_input_ids)

func add_snapshot(snapshot : Snapshot):
#	print("[%s] Adding snapshot" % _name)
	var now = Time.get_unix_time_from_system()
	
	if _time_offset == -1:
		_time_offset = now - snapshot.time
		
	if _auto_correct_time_offset:
		var time_offset = now - snapshot.time
#		print(name, " =====================>", now, snapshot.time)
#		print("=> _time_offset ", _time_offset, " => time_offset ", time_offset)
		var time_difference = abs(_time_offset - time_offset)
#		print("time_difference ", time_difference) # TODO: this is always 0 on the client side which is a bug
		if(time_difference > _network_config.DEFAULT_MAX_TIME_OFFSET_MS):
			_time_offset = time_offset
			
	vault.add(snapshot)

func sample(snapshot_a : Snapshot, snapshot_b : Snapshot, time : float, entity_classes : Dictionary) -> InterpolatedSnapshot:
	var snapshot_array = [snapshot_a, snapshot_b]
	snapshot_array.sort_custom(Callable(NetworkUtil,"sort_snapshots"))
	
	var newer : Snapshot = snapshot_array[0]
	var older : Snapshot = snapshot_array[1]

	var t0 : float = newer.time
	var t1 : float = older.time
	
	var zero_percent = time - t1
	var hundred_percent = t0 - t1
	var p_percent
	if hundred_percent == 0:
		print("Divide by zero in sample")
		p_percent = 0
	else:
		p_percent = time if time <= 1 else zero_percent / hundred_percent

	var server_time = lerp(t1, t0, p_percent)

	var temp_snapshot: Snapshot = newer

	for i in len(newer.state.values()):
		var e1 : Entity = newer.state.values()[i]
		var e2 : Entity
		
		for temp_e in older.state.values():
			if e1.id == temp_e.id:
				e2 = temp_e
				break
				
		if !e2: return null
		# Dont sample things with the same id that are not the same type of entity
		if e1.get_class_name() != e2.get_class_name(): return null	
		
		var parameters : Array = []
		for entity_class in entity_classes.values():
			if e1.get_class_name() == entity_class.get_class_name():
				parameters = entity_class.interpolation_parameters
				break

		for j in len(parameters):
			var param = parameters[j]
			var p0 = e1
			var p1 = e2
			if "." in param:
				var sub_param_array = param.split(".")
				for sub_param in sub_param_array:
					p0 = p0[sub_param]
					p1 = p1[sub_param]
			else:
				p0 = e1[param]
				p1 = e2[param]

			var pn = lerp(p1, p0, p_percent)
			
			var new_state_to_update = temp_snapshot.state.values()[i]
			if "." in param:
				var sub_param_array = param.split(".")
				var temp_attr_ref = new_state_to_update		
				for k in len(sub_param_array): # TODO: good chance this is broken
					var sub_param = sub_param_array[k]
					if k < sub_param_array.size() - 1:
						temp_attr_ref = temp_attr_ref[sub_param]
					else:
						temp_attr_ref[sub_param] = pn
			else:
				new_state_to_update[param] = pn

	var interpolatedSnapshot : InterpolatedSnapshot = InterpolatedSnapshot.new(temp_snapshot.state, p_percent, newer.id, older.id)
	return interpolatedSnapshot

func get_server_time() -> float:
#	print(_name, " _time_offset ", _time_offset, " _interpolation_buffer ", _interpolation_buffer)
	return Time.get_unix_time_from_system() - _time_offset
	
#func get_client_adjusted_server_time() -> float:
##	print(_name, " _time_offset ", _time_offset, " _interpolation_buffer ", _interpolation_buffer)
#	return Time.get_unix_time_from_system() - _time_offset - _interpolation_buffer
	
func calculate_client_adjusted_interpolation(entity_classes : Dictionary) -> InterpolatedSnapshot:
#	return calculate_interpolation_with_time(entity_classes, get_client_adjusted_server_time())
	return calculate_interpolation_with_time(entity_classes, get_server_time())
	
func calculate_interpolation_with_time(entity_classes : Dictionary, time : float) -> InterpolatedSnapshot:
	var snapshots = vault.get_surrounding_snapshots(time)
	if snapshots[0] == null || snapshots[1] == null: 
		print("Either a before or after snapshot could not be found for interpolation")
		return null
	
	return sample(snapshots[0], snapshots[1], time, entity_classes)
	
