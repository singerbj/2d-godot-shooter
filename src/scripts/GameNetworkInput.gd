extends NetworkInput

class_name GameNetworkInput

var player_id : int
var m_forward : bool
var m_backward : bool
var m_left : bool
var m_right : bool
var equip_weapon : int = Enums.WeaponSlot.NONE
var jump : bool
var shooting : bool
var shooting_origin : Vector2
var shooting_normal : Vector2
var hit : int = -1 # Do this to prevent the server player from always taking damage

func serialize():
	var buffer := StreamPeerBuffer.new()
	
	buffer.put_u32(id)
	buffer.put_float(delta)
	buffer.put_float(time)
	buffer.put_u32(id)
	buffer.put_u8(int(m_forward))
	buffer.put_u8(int(m_backward))
	buffer.put_u8(int(m_left))
	buffer.put_u8(int(m_right))
	buffer.put_8(equip_weapon)
	buffer.put_u8(int(jump))
	buffer.put_u8(int(shooting))
	NetworkUtil.serialize_vector2(buffer, shooting_origin)
	NetworkUtil.serialize_vector2(buffer, shooting_normal)
	buffer.put_u32(hit)	
	
	buffer.resize(buffer.get_position())
	return buffer.data_array

func deserialize(serialized : PackedByteArray):
	var deserialized_network_input = get_script().new()
	var buffer := StreamPeerBuffer.new()
	buffer.put_data(serialized)
	buffer.seek(0)
	
	deserialized_network_input["id"] = buffer.get_u32()
	deserialized_network_input["delta"] = buffer.get_float()
	deserialized_network_input["time"] = buffer.get_float()
	deserialized_network_input["player_id"] = buffer.get_u32()
	deserialized_network_input["m_forward"] = bool(buffer.get_u8())
	deserialized_network_input["m_backward"] = bool(buffer.get_u8())
	deserialized_network_input["m_left"] = bool(buffer.get_u8())
	deserialized_network_input["m_right"] = bool(buffer.get_u8())
	deserialized_network_input["equip_weapon"] = buffer.get_8()
	deserialized_network_input["jump"] = bool(buffer.get_u8())
	deserialized_network_input["shooting"] = bool(buffer.get_u8())
	deserialized_network_input["shooting_origin"] = NetworkUtil.deserialize_vector2(buffer)
	deserialized_network_input["shooting_normal"] = NetworkUtil.deserialize_vector2(buffer)
	deserialized_network_input["hit"] = buffer.get_u32()
	
	return deserialized_network_input

