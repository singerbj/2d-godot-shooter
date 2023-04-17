extends NetworkManager

var local_peer_id : int
var players = {}
var Player: PackedScene = preload("res://src/scenes/Player.tscn")
var mouse_motion : Vector2 = Vector2(0, 0)
var reconciliations : int = 0

const RECONCILIATION_TOLERANCE : float = 8.0
const RECONCILIATION_FACTOR : float = 0.125

const WEAPON_DAMAGE : float = 10.0 #TODO: Move this to a weapon manager thingy

func _ready():
	super()
	var args = Array(OS.get_cmdline_args())
	var start_server = "server" in args
	var start_client = "client" in args
	if !start_server && !start_client: # TODO: put these in a config file that is in gitignore?
		start_server = false
		start_client = true

	if start_server:
		get_window().set_title("Server")
		self.start_server()
	if start_client:
		get_window().set_title("Client")
		self.connect_to_server(NetworkUtil.get_cmd_line_ipaddress())
	if start_server && start_client:
		get_window().set_title("Server and Client")
	
	if start_client:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _physics_process(delta):
	super(delta)
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
		
	if Input.is_action_just_pressed("camera_switch"):
		if $Camera2D.is_current():
			players[local_peer_id].set_camera_active()
		else:
			$Camera2D.make_current()
			
	if Input.is_action_just_pressed("change_mouse_mode"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
func _process(delta):
	super(delta)
	if local_peer_id in players:
		$UI/Label.text = "[FPS: %s] [Reconciliations: %s] [Server Clock: %s] [Player Health: %s]" % [
			str(Engine.get_frames_per_second()), 
			reconciliations, server_snapshot_manager.get_server_time(),
			players[local_peer_id].health
		]
	
#	if local_peer_id != null && local_peer_id in players:
#		players[local_peer_id].rotate_player_with_input(mouse_motion)
#		mouse_motion = Vector2(0, 0)
		
#func _input(event) -> void:
#	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED && event is InputEventMouseMotion:
#		mouse_motion += event.relative
		

########################################################
### Required Server Implementation Functions ###########
########################################################

func _on_server_creation_error(error):
	pass
	
func _on_peer_connected(peer_id : int):
	if peer_id != local_peer_id:
		var peer_player = Player.instantiate()
		peer_player.player_id = peer_id
		players[peer_id] = peer_player
		add_child(peer_player)
		peer_player.weapon_manager.ui_node = $UI
		peer_player.players = players
	
func _on_peer_disconnected(peer_id):
	if peer_id in players:
		players[peer_id].queue_free()
		players.erase(peer_id)
		
func _before_process_inputs():
	pass
	
func _process_inputs(delta : float, peer_id : int, inputs : Array):
	for input in inputs:
		if peer_id in players:
			if !_local_peer_is_server() || (_local_peer_is_server() && peer_id != local_peer_id):
				players[peer_id].move(input, delta)
				
				if input["equip_weapon"] != Enums.WeaponSlot.NONE:
					players[peer_id].equip_weapon(input["equip_weapon"])
			
			if input["shooting"]:
				players[peer_id].weapon_manager.pull_trigger(input["shooting_origin"], input["shooting_normal"])
			else:
				players[peer_id].weapon_manager.release_trigger()
				
			if "hit" in input:
				var hit = input["hit"]
				if hit in players:
					players[hit].take_damage(WEAPON_DAMAGE)
				
				
func _after_process_inputs():
#	ShotManager.clear_shots()
	pass
	
########################################################
### Required Client Implementation Functions ###########
########################################################	
	
func _on_connection_failed():
	pass
	
func _on_connection_succeeded():
	pass
	
func _on_confirm_connection(peer_id : int):
	local_peer_id = peer_id
	var local_player = Player.instantiate()
	local_player.is_local_player = true
	local_player.player_id = local_peer_id
	players[local_peer_id] = local_player
	add_child(local_player)
	local_player.weapon_manager.ui_node = $UI
	local_player.players = players
	local_player.set_camera_active()
	if peer_id == 0:
		local_player.is_bot = false
	
func _on_snapshot_recieved(snapshot : Snapshot):
	for entity in snapshot.state.values():
		if entity is ShotEntity:
			if entity.peer_id == local_peer_id && entity.hit:
				$UI.show_hitmarker()
	
func _on_update_local_entity(delta : float, entity : Entity):
	if entity is PlayerEntity:
		if local_peer_id != null && local_peer_id in players:
			if !entity.id in players:				
				_on_peer_connected(entity.id)
			if local_peer_id == entity.id:
				players[entity.id].update_local_player_from_server(entity)
			else:
				players[entity.id].update_peer_player_from_server(entity)
				
	if entity is ShotEntity:
		if entity.peer_id != local_peer_id:
			ShotManager.fire_client_shot(entity, true)
	
func _on_peer_disconnect_reported(peer_id):
	if peer_id in players:
		players[peer_id].queue_free()
		players.erase(peer_id)
	
func _on_input_data_requested() -> NetworkInput:
	var input = GameNetworkInput.new()
	
	if local_peer_id != null && local_peer_id in players:
		input["player_id"] = local_peer_id
		
	if Input.is_action_pressed("m_up"):
		input["m_forward"] = true
	if Input.is_action_pressed("m_down"):
		input["m_backward"] = true
	if Input.is_action_pressed("m_left"):
		input["m_left"] = true
	if Input.is_action_pressed("m_right"):
		input["m_right"] = true
	if Input.is_action_just_pressed("equip_weapon_0"):
		input["equip_weapon"] = Enums.WeaponSlot.WEAPON_SLOT_0
	if Input.is_action_just_pressed("equip_weapon_1"):
		input["equip_weapon"] = Enums.WeaponSlot.WEAPON_SLOT_1
	if Input.is_action_pressed("jump"):
		input["jump"] = true
	if Input.is_action_pressed("shoot"):
		input["shooting"] = true
		if local_peer_id in players:
#			var player_camera = players[local_peer_id].get_camera_2d()
#			var shooting_origin = player_camera.project_ray_origin(Vector2(get_viewport().size.x / 2, get_viewport().size.y / 2))
#			var shooting_normal = player_camera.project_ray_normal(Vector2(get_viewport().size.x / 2, get_viewport().size.y / 2))
#			input["shooting_origin"] = shooting_origin
#			input["shooting_normal"] = shooting_normal
			$UI/ShootLabel.text = "Shooting!"
#			$UI/ShootDataLabel.text = str(shooting_origin) + "\n" + str(shooting_normal)
#			players[local_peer_id].weapon_manager.pull_trigger(input["shooting_origin"], input["shooting_normal"])
	else:
		if local_peer_id in players:
			players[local_peer_id].weapon_manager.release_trigger()
			$UI/ShootLabel.text = ""
		
			var hits = players[local_peer_id].weapon_manager.get_and_clear_hits()
			if hits.size() > 0:
				input["hit"] = hits[0]
	
	return input
		
func _on_client_side_predict(delta : float, input : NetworkInput):
	if local_peer_id in players:
		players[local_peer_id].move(input, delta)
		
		if input["equip_weapon"] != Enums.WeaponSlot.NONE:
			players[local_peer_id].equip_weapon(input["equip_weapon"])

func _on_server_reconcile(delta : float, latest_server_snapshot : Snapshot, closest_client_snaphot : InterpolatedSnapshot, input_buffer : Array):
	var server_entity : Entity
	var client_entity : Entity
	if local_peer_id in players:
		if local_peer_id in latest_server_snapshot.state:
			server_entity = latest_server_snapshot.state[local_peer_id]
		if local_peer_id in closest_client_snaphot.state:
			client_entity = closest_client_snaphot.state[local_peer_id]
				
		if server_entity != null && client_entity != null:
			# calculate the offset between server and client
			var offset_x = abs(players[local_peer_id].transform.origin.x - server_entity.transform.origin.x)
			var offset_y = abs(players[local_peer_id].transform.origin.y - server_entity.transform.origin.y)

			if offset_x > RECONCILIATION_TOLERANCE || offset_y > RECONCILIATION_TOLERANCE:
				reconciliations += 1
				var local_origin = players[local_peer_id].transform.origin
				var server_origin = server_entity.transform.origin
				players[local_peer_id].transform.origin = lerp(local_origin, server_origin, RECONCILIATION_FACTOR)
	
func _on_message_received_from_server():
	pass
	
########################################################
### Required Both Implementation Functions #############
########################################################	
	
func _on_request_entity_classes() -> Array:
	return [PlayerEntity, ShotEntity]
	
func _on_request_network_input_class():
	return GameNetworkInput
	
func _on_request_entities() -> Dictionary:
	var entities = {}
	for peer_id in players.keys():
		var player_entity = PlayerEntity.new({ 
			"id": peer_id, 
			"transform": players[peer_id].transform, 
			"velocity": players[peer_id].velocity, 
			"health": players[peer_id].health,
		})
		entities[player_entity.id] = player_entity
		
	for shot_entity in ShotManager.get_server_shots():
		entities[shot_entity.id] = shot_entity
		
	return entities
	
########################################################
### Non-required Implementation Functions ##############
########################################################	
func _on_after_physics_process():
	ShotManager.clear_shots()
	
