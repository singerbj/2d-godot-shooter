extends Node

class_name NetworkUtil

static func gen_unique_string(length: int) -> String:
	var _ascii_letters_and_digits = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	var result = ""
	for _i in range(length):
		result += _ascii_letters_and_digits[randi() % _ascii_letters_and_digits.length()]
	return result

static func sort_snapshots(a, b):
	if a.time < b.time:
		return true
	return false
	
static func sort_network_inputs(a, b):
	if a.id < b.id:
		return true
	return false
	
static func get_cmd_line_ipaddress() -> String:
	var ip_address = "localhost"
	var args = Array(OS.get_cmdline_args())
	for arg in args:
		var formatted_arg_array = arg.split("=")
		print(formatted_arg_array)
		if formatted_arg_array.size() == 2:
			if formatted_arg_array[0] == "-ip":
				ip_address = formatted_arg_array[1]
				print("Using command line specified ip: " + ip_address)
	if ip_address == "localhost":
		print("Command line ip not specified. Defaulting to localhost")
	return ip_address

static func serialize_transform2D(buffer : StreamPeerBuffer, transform : Transform2D) -> void:
	serialize_vector2(buffer, transform.origin)

static func serialize_transform3D(buffer : StreamPeerBuffer, transform : Transform3D) -> void:
	serialize_basis(buffer, transform.basis)
	serialize_vector3(buffer, transform.origin)

static func serialize_basis(buffer : StreamPeerBuffer, basis : Basis) -> void:
	serialize_vector3(buffer, basis.x)
	serialize_vector3(buffer, basis.y)
	serialize_vector3(buffer, basis.z)
	
static func serialize_vector2(buffer : StreamPeerBuffer, vector : Vector2) -> void:
	buffer.put_float(vector.x)
	buffer.put_float(vector.y)

static func serialize_vector3(buffer : StreamPeerBuffer, vector : Vector3) -> void:
	buffer.put_float(vector.x)
	buffer.put_float(vector.y)
	buffer.put_float(vector.z)
	
static func serialize_color(buffer : StreamPeerBuffer, color : Color) -> void:
	buffer.put_float(color.r)
	buffer.put_float(color.g)
	buffer.put_float(color.b)
	buffer.put_float(color.a)
	
static func deserialize_transform2D(buffer : StreamPeerBuffer) -> Transform2D:
	var origin = deserialize_vector2(buffer)
	var t = Transform2D()
	t.origin = origin
	return t
	
static func deserialize_transform3D(buffer : StreamPeerBuffer) -> Transform3D:
	return Transform3D(deserialize_basis(buffer), deserialize_vector3(buffer))

static func deserialize_basis(buffer : StreamPeerBuffer) -> Basis:
	return Basis(deserialize_vector3(buffer), deserialize_vector3(buffer), deserialize_vector3(buffer))

static func deserialize_vector2(buffer : StreamPeerBuffer) -> Vector2:
	return Vector2(buffer.get_float(), buffer.get_float())
	
static func deserialize_vector3(buffer : StreamPeerBuffer) -> Vector3:
	return Vector3(buffer.get_float(), buffer.get_float(), buffer.get_float())
	
static func deserialize_color(buffer : StreamPeerBuffer) -> Color:
	return Color(buffer.get_float(), buffer.get_float(), buffer.get_float(), buffer.get_float())
		
