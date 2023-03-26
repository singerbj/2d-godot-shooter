extends Node

class_name WeaponManager

var player : CharacterBody3D
var weapon_parent_node : Node
var ui_node : Control

var weapon_map : Dictionary = {}
var current_weapon : Gun

var firing = false
var current_shooting_origin : Vector3
var current_shooting_normal : Vector3
var hits = []

func _init(player_arg : CharacterBody3D, weapon_parent_node_arg : Node):
	player = player_arg
	weapon_parent_node = weapon_parent_node_arg
	
	_setup_gun(preload("res://src/scenes/Pistol.tscn"))
	_setup_gun(preload("res://src/scenes/AssaultRifle.tscn"))
	
	current_weapon = weapon_map[weapon_map.keys()[0]]
	weapon_parent_node.add_child(current_weapon)
	
func _setup_gun(gun):
	var gun_instance = gun.instantiate()
	gun_instance.weapon_manager = self
	gun_instance.setup_animations()
	
	weapon_map[gun_instance.get_class_name()] = gun_instance

func ready_weapon(weapon_slot):
	if weapon_slot != Enums.WeaponSlot.NONE:
		if current_weapon:
			if weapon_map[current_weapon.get_class_name()] == weapon_map[weapon_map.keys()[weapon_slot]]:
				return
			else:
				# TODO: lower current weapon
				weapon_parent_node.remove_child(current_weapon)
			
		current_weapon = weapon_map[weapon_map.keys()[weapon_slot]]
		weapon_parent_node.add_child(current_weapon) # TODO: there is an issue with the location the gun is rendered on the server for the client. also its not rendering the server players guns for the client at all
	
func stow_weapon():
	pass
	
func reload_weapon():
	pass
	
func pull_trigger(shooting_origin, shooting_normal):
	current_shooting_origin = shooting_origin
	current_shooting_normal = shooting_normal
	if !firing:
		if current_weapon:
			current_weapon.animation_player.play("fire_gun")
	firing = true
#	_fire_shot_from_client(players, shooting_origin, shooting_normal)
	
func release_trigger():
#	print("release_trigger")
	if current_weapon && current_weapon.animation_player && current_weapon.animation_player.is_playing():
		current_weapon.animation_player.stop(true)
	firing = false
	
func fire_shot():
	if player.player_id == 0: #TODO: THIS IS BROKEN =======================
		fire_shot_from_client()
	else:
		fire_shot_on_server()
	
func fire_shot_from_client():
	var new_shot = ShotEntity.new({
		"id": "s" + str(player.player_id) + str(ShotManager.get_new_shot_id()),
		"peer_id": player.player_id, 
		"time": 0, # not relevant for the local simulation of the shot
		"origin": current_shooting_origin,
		"normal": current_shooting_normal,
		"hit": -1,
		"color": ShotEntity.DEFAULT_COLOR
	})

	new_shot = ShotManager.fire_client_detection_shot(new_shot, [player])
	if new_shot.hit != -1:
		hits.append(new_shot.hit)
		ui_node.show_hitmarker()
		
func fire_shot_on_server():
	var new_shot = ShotEntity.new({
		"id": "s" + str(player.player_id) + str(ShotManager.get_new_shot_id()),
		"peer_id": player.player_id, 
		"time": 0, # not relevant for the local simulation of the shot
		"origin": current_shooting_origin,
		"normal": current_shooting_normal,
		"hit": -1,
		"color": ShotEntity.DEFAULT_COLOR
	})

	ShotManager.fire_client_shot(new_shot, true)
	ShotManager.server_shots.append(new_shot)
		
func get_and_clear_hits() -> Array:
	var to_return = [] + hits
	hits = []
	return to_return
	
