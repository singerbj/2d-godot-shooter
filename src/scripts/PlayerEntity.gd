extends Entity

class_name PlayerEntity

const interpolation_parameters = [
	"transform.origin.x", "transform.origin.y", "transform.origin.z",
	"rotation.x", "rotation.y", "rotation.z",
	"head_nod_angle"
]

var transform : Transform3D
var velocity : Vector3
var rotation : Vector3
var head_nod_angle : float
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
	self.rotation = attr_dict.rotation
	self.head_nod_angle = attr_dict.head_nod_angle
	self.health = attr_dict.health

static func get_class_name():
	return "PlayerEntity"

func serialize():
	var buffer := StreamPeerBuffer.new()
	
	buffer.put_u32(id)
	NetworkUtil.serialize_transform(buffer, transform)
	NetworkUtil.serialize_vector3(buffer, velocity)
	NetworkUtil.serialize_vector3(buffer, rotation)
	buffer.put_float(head_nod_angle)
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
		"transform": NetworkUtil.deserialize_transform(buffer),
		"velocity": NetworkUtil.deserialize_vector3(buffer),
		"rotation": NetworkUtil.deserialize_vector3(buffer),
		"head_nod_angle": buffer.get_float(),
		"health": buffer.get_float(),
	}
