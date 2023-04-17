extends Entity

class_name ShotEntity

const interpolation_parameters = []
const DEFAULT_COLOR = Color.WHITE

var peer_id : int
var time : float
var origin : Vector2
var normal : Vector2
var hit : int
var color : Color = DEFAULT_COLOR

func _init(attributes):
	var attr_dict : Dictionary
	if attributes is Dictionary:
		attr_dict = attributes
	else:
		attr_dict = deserialize(attributes)
		
	self.id = attr_dict.id
	self.peer_id = attr_dict.peer_id
	self.time = attr_dict.time
	self.origin = attr_dict.origin
	self.normal = attr_dict.normal
	self.hit = attr_dict.hit
	self.color = attr_dict.color

static func get_class_name():
	return "ShotEntity"

func serialize():
	var buffer := StreamPeerBuffer.new()
	
	buffer.put_string(str(id))
	buffer.put_u32(peer_id)
	buffer.put_float(time)
	NetworkUtil.serialize_vector2(buffer, origin)
	NetworkUtil.serialize_vector2(buffer, normal)
	buffer.put_u32(hit)
	NetworkUtil.serialize_color(buffer, color)
	
	buffer.resize(buffer.get_position())
	return buffer.data_array

func deserialize(serialized : PackedByteArray):
	var buffer := StreamPeerBuffer.new()
	buffer.put_data(serialized)
	buffer.seek(0)
	
	return {
		"id": buffer.get_string(),
		"peer_id": buffer.get_u32(), 
		"time": buffer.get_float(),
		"origin": NetworkUtil.deserialize_vector2(buffer),
		"normal": NetworkUtil.deserialize_vector2(buffer),
		"hit": buffer.get_u32(),
		"color": NetworkUtil.deserialize_color(buffer),
	}
