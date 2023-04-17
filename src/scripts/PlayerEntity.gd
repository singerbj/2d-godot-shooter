extends Entity

class_name PlayerEntity

const interpolation_parameters = [
	"transform.origin.x", "transform.origin.y"
]

var transform : Transform2D
var velocity : Vector2
var health : float

func _init(attributes):
	var attr_dict : Dictionary
	if attributes is Dictionary:
		attr_dict = attributes
	else:
		attr_dict = deserialize(attributes)
	
	self.id = attr_dict.id
	self.transform = attr_dict.transform
	self.velocity = attr_dict.velocity
	self.health = attr_dict.health

static func get_class_name():
	return "PlayerEntity"

func serialize():
	var buffer := StreamPeerBuffer.new()
	
	buffer.put_u32(id)
	NetworkUtil.serialize_transform2D(buffer, transform)
	NetworkUtil.serialize_vector2(buffer, velocity)
	buffer.put_float(health)
	
	buffer.resize(buffer.get_position())
	return buffer.data_array

func deserialize(serialized : PackedByteArray):
	var buffer := StreamPeerBuffer.new()
	buffer.put_data(serialized)
	buffer.seek(0)
	
#	return get_script().new({
	return {
		"id": buffer.get_u32(),
		"transform": NetworkUtil.deserialize_transform2D(buffer),
		"velocity": NetworkUtil.deserialize_vector2(buffer),
		"health": buffer.get_float(),
	}
