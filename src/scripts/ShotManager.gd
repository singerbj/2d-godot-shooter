extends Node3D

var shot_id_counter : int = 0
@onready var server_shots : Array = []
var shot_starting_distance = 2
var ray_length = 100

func clear_shots() -> void:
	server_shots = []

func get_server_shots() -> Array:
	return server_shots
	
#func fire_server_shot(shot : ShotEntity, exclude : Array = []) -> ShotEntity:
#	var from : Vector3 = shot.origin + shot.normal * shot_starting_distance
#	var to : Vector3  = shot.origin + shot.normal * ray_length
#
#	# use global coordinates, not local to node
#	var space_state = get_world_3d().direct_space_state
#	var all_results = []
#	var all_colliders = []
#	var hit_player = false
#	var continue_casting = true
#
#	while(continue_casting):		
#		var result = space_state.intersect_ray(from, to, exclude + all_colliders)
#		if 'collider_id' in result:
#			all_results.append(result)
#			all_colliders.append(result.collider)
#		else:
#			continue_casting = false
#
#	var color : Color = Color(0, 0, 0.5)
#	if all_results.size() > 0:
#		color = Color(0.5, 0, 0)
#		to = all_results[0].position
#
#		if "is_player" in all_colliders[0]:
#			hit_player = true
#			color = Color(0, 0.5, 0.5)
#
#	shot.color = color
#	shot.hit = hit_player
#
#	server_shots.append(shot)
#	_render_shot(from, to, color)
#
#	return shot

func fire_client_shot(shot : ShotEntity, server_debug : bool = false) -> void:
	var from : Vector3 = shot.origin + shot.normal * shot_starting_distance
	var to : Vector3 = shot.origin + shot.normal * ray_length
	var color : Color = shot.color
	if server_debug:
		color = Color.AQUA
	
	_render_shot(from, to, color)

func fire_client_detection_shot(shot : ShotEntity, exclude : Array = [], server_debug : bool = false) -> ShotEntity:
	var from : Vector3 = shot.origin + shot.normal * shot_starting_distance
	var to : Vector3 = shot.origin + shot.normal * ray_length
	var color : Color = shot.color
	if server_debug:
		color = Color.AQUA
		
	# use global coordinates, not local to node
	var space_state = get_world_3d().direct_space_state
	var all_results = []
	var all_colliders = []
	var hit_player : int = -1
	var continue_casting = true
	
	while(continue_casting):		
		var result = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(from, to, exclude + all_colliders))
		if 'collider_id' in result:
			all_results.append(result)
			all_colliders.append(result.collider)
		else:
			continue_casting = false
		
	if all_results.size() > 0:
		color = Color(0.5, 0, 0)
		to = all_results[0].position
		
		if "player_id" in all_colliders[0]:
			hit_player = all_colliders[0]["player_id"]
			color = Color(0, 0.5, 0.5)
	
	shot.color = color
	shot.hit = hit_player
	
	server_shots.append(shot)
	_render_shot(from, to, color)
	return shot
	
func _render_shot(from : Vector3, to : Vector3, color : Color) -> void:
	# Lower the drawing of the shot just a touch so we can see it when we are not moving
	DrawLine3d.draw_line_3d(from - Vector3(0, 0.05, 0), to, color)
	
func get_new_shot_id() -> int:
	shot_id_counter += 1
	return shot_id_counter
	
