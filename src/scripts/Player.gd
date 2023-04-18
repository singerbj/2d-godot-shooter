extends CharacterBody2D

const acceleration: float = 20.0 #2000 / 10
const decceleration: float = 3.5 #1000 / 10
const ground_decceleration: float = 3.5 #1000 / 10
const air_decceleration: float = 1.75 #500 / 10
const gravity_acceleration: float = 14.0 #4000 / 5

const vertical_jump_speed: float = 700  #1500 / 3
const grab_slide_speed: float = 0.21 #60 / 10
const horizontal_jump_speed: float = 500 #800 / 10

const MAX_HEALTH : float = 1000.0
const grab_decceleration_ratio: int = 2.25
const max_speed: int = 300
const max_lean_degrees: float = 2.5
const lean_speed: float = 0.25
const min_step_distance: int = 5

const wall_jump_cooldown_time_s: float = 0.35
const wall_grab_energy_time_s: float = 1.4

var target_rotation_degrees = rotation_degrees
var wall_jump_cooldown = 0
var wall_grab_energy = wall_grab_energy_time_s

var players : Dictionary
var player_id : int
var is_local_player : bool = false
var weapon_manager : WeaponManager

var health : float = MAX_HEALTH

const MAX_BOT_MOVE_TIME = 60
var is_bot = false
var bot_move_time = 0
var bot_move_key = "m_left"

func _ready():
	weapon_manager = WeaponManager.new(self, self)
	
	
var gravity_vec = Vector2()
var temp_velocity = Vector2()
func move(input : NetworkInput, local_delta : float):
	var move_vector = Vector2.ZERO
	var jump = false
	
	if input["m_left"]:
		move_vector.x = -1
	if input["m_right"]:
		move_vector.x = 1
	if input["jump"]:
		jump = true
		
	if is_on_floor():
		gravity_vec = Vector2.ZERO
	else:
		gravity_vec += Vector2.DOWN * gravity_acceleration
		
	if jump and is_on_floor():
		gravity_vec = Vector2.UP * vertical_jump_speed
	
	# make it move
	temp_velocity = lerp(temp_velocity, move_vector * max_speed, acceleration / max_speed)
	velocity = temp_velocity + gravity_vec
	velocity = velocity * (input.delta / local_delta)
	
	move_and_slide()
		
#	velocity.y += local_delta * gravity_acceleration
#
#	if input["m_left"]:
#		velocity.x = -max_speed * 100 * local_delta
#	elif input["m_right"]:
#		velocity.x =  max_speed * 100 * local_delta
#	else:
#		velocity.x = 0
#
#	move_and_slide()
		
#func move(input : NetworkInput, local_delta : float):
#	print(player_id, " -> ", local_delta)
#	$RayCast2DLeft.force_raycast_update()
#	$RayCast2DRight.force_raycast_update()
#	$RayCast2DBottom.force_raycast_update()
#
#	var move_vector = Vector2.ZERO
#	var jump = false
#
#	# Move like a bot
#	if self.is_bot:
#		bot_move_time += 1
#		if bot_move_time > MAX_BOT_MOVE_TIME:
#			bot_move_time = 0
#			if bot_move_key == "m_left":
#				bot_move_key = "m_right"
#			else:
#				bot_move_key = "m_left"
#		input[bot_move_key] = true
#
#	if wall_jump_cooldown == 0:
##		if (input["m_left"] && input["m_right"]) || (!input["m_left"] && !input["m_right"]):
##			if velocity.x > 0:
##				velocity.x -= ground_decceleration if is_on_floor() else air_acceleration
##			elif velocity.x < 0:
##				velocity.x += ground_decceleration if is_on_floor() else air_acceleration
##		el
##		if is_on_floor():
#		if input["m_left"] && velocity.x > -max_speed:
#			velocity.x -= acceleration * local_delta
#		elif input["m_right"] && velocity.x < max_speed:
#			velocity.x += acceleration * local_delta
##		elif !is_on_floor():
##			if input["m_left"] && velocity.x > -max_speed:
##				velocity.x -= air_acceleration
##			elif input["m_right"] && velocity.x < max_speed:
##				velocity.x += air_acceleration
#
#		if velocity.x > 0:
#			velocity.x -= (ground_decceleration * local_delta) if is_on_floor() else (air_decceleration * local_delta)
#		elif velocity.x < 0:
#			velocity.x += (ground_decceleration * local_delta) if is_on_floor() else (air_decceleration * local_delta)
#
#	if input["jump"]: # TODO: should be just pressed
#		if _is_on_left_wall() && wall_jump_cooldown == 0 && wall_grab_energy > 0:
#			velocity.y = vertical_jump_speed
#			velocity.x = horizontal_jump_speed
#			wall_jump_cooldown = wall_jump_cooldown_time_s
#		elif _is_on_right_wall() && wall_jump_cooldown == 0 && wall_grab_energy > 0:
#			velocity.y = vertical_jump_speed
#			velocity.x = -horizontal_jump_speed
#			wall_jump_cooldown = wall_jump_cooldown_time_s
#		elif is_on_floor():
#			velocity.y = vertical_jump_speed
#
#	velocity.y += gravity_acceleration * local_delta
#
#	var grabbing_left_wall: bool = _is_close_to_left_wall() && Input.is_key_pressed(KEY_A) && velocity.y >= 0 && wall_grab_energy > 0
#	var grabbing_right_wall: bool = _is_close_to_right_wall() && Input.is_key_pressed(KEY_D) && velocity.y >= 0&& wall_grab_energy > 0
#	if grabbing_left_wall || grabbing_right_wall:
#		wall_grab_energy -= local_delta * 1
#		velocity.y = velocity.y / grab_decceleration_ratio
#		if velocity.y <= grab_slide_speed:
#			velocity.y = grab_slide_speed
#
#	move_and_slide()
#
#	target_rotation_degrees = (velocity.x / max_speed) * max_lean_degrees
#
#	# modify cooldowns properly
#	wall_jump_cooldown -= local_delta * 1
#	if wall_jump_cooldown < 0: wall_jump_cooldown = 0
#	if is_on_floor(): wall_grab_energy = wall_grab_energy_time_s
#
#	$TextEdit.text = str(wall_grab_energy)
	
func _process(_delta):
	rotation_degrees = lerp(rotation_degrees, target_rotation_degrees, lean_speed)
	
func _draw():
	$CollisionShape2D.shape.draw(get_canvas_item(), Color(1, 1, 1, 0.25))
	
func _is_on_left_wall() -> bool:
	return _is_close_to_left_wall() && abs(velocity.x) <= acceleration && velocity.y <= grab_slide_speed 
	
func _is_on_right_wall() -> bool:
	return _is_close_to_right_wall() && abs(velocity.x) <= acceleration && velocity.y <= grab_slide_speed 

func _is_close_to_left_wall() -> bool:
	return $RayCast2DLeft.is_colliding() && !_is_close_to_floor()

func _is_close_to_right_wall() -> bool:
	return $RayCast2DRight.is_colliding() && !_is_close_to_floor()
	
func _is_close_to_floor() -> bool:
	return $RayCast2DBottom.is_colliding()
	
func update_local_player_from_server(entity : PlayerEntity):
	health = entity.health

func update_peer_player_from_server(entity : PlayerEntity):
	transform.origin = entity.transform.origin
	health = entity.health

func take_damage(damage : float):
	health -= damage

func equip_weapon(weapon_index):
	weapon_manager.ready_weapon(weapon_index)
#
func get_camera_2d() -> Node:
	return $Camera2D

func set_camera_active():
	if $Camera2D != null:
		$Camera2D.make_current()
