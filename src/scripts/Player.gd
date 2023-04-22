extends CharacterBody2D

const acceleration: float = 60.0 #2000 / 10
const ground_decceleration: float = 45.0 #1000 / 10
const air_decceleration: float = 55.0 #500 / 10
const gravity_acceleration: float = 18.0 #4000 / 5

const vertical_jump_speed: float = 700 #1100 #1500 / 3
const grab_slide_speed: float = 60 #60 / 10
const horizontal_jump_speed: float = 500 #800 / 10

const MAX_HEALTH : float = 1000.0
const grab_decceleration_ratio: int = 2.25
const max_speed: int = 325
const max_lean_degrees: float = 2.5
const lean_speed: float = 0.25
const min_step_distance: int = 5

const after_wall_jump_cooldown_time: float = 0.5
const wall_grab_energy_time: float = 1.0

var target_rotation_degrees = rotation_degrees
var after_wall_jump_cooldown = 0
var wall_grab_energy = wall_grab_energy_time

var players : Dictionary
var player_id : int
var is_local_player : bool = false
var weapon_manager : WeaponManager

var health : float = MAX_HEALTH

const MAX_BOT_MOVE_TIME = 60
var is_bot = false
var bot_move_time = 0
var bot_move_key = "m_left"

# temp variables for tracking velocity
var x_velocity : float = 0.0
var y_velocity : float = 0.0

func _ready():
	weapon_manager = WeaponManager.new(self, self)
	
#	floor_stop_on_slope = true
#	floor_constant_speed = true
#	floor_snap_length = 1.0
	
func move(local_delta : float, calculated_delta : float, input : NetworkInput):
	$RayCast2DLeft.force_raycast_update()
	$RayCast2DRight.force_raycast_update()
	$RayCast2DBottom.force_raycast_update()

	var move_vector = Vector2.ZERO
	var jump = false

	# Move like a bot
	if self.is_bot:
		bot_move_time += 1
		if bot_move_time > MAX_BOT_MOVE_TIME:
			bot_move_time = 0
			if bot_move_key == "m_left":
				bot_move_key = "m_right"
			else:
				bot_move_key = "m_left"
		input[bot_move_key] = true

	if after_wall_jump_cooldown == 0:
		if input["m_left"] && x_velocity > -max_speed:
			x_velocity -= acceleration
		elif input["m_right"] && x_velocity < max_speed:
			x_velocity += acceleration

		if x_velocity > 0:
			x_velocity -= ground_decceleration if is_on_floor() else air_decceleration
		elif x_velocity < 0:
			x_velocity += ground_decceleration if is_on_floor() else air_decceleration

	if is_on_floor():
		y_velocity = 0
	elif is_on_ceiling():
		y_velocity = 0
		y_velocity += gravity_acceleration
	else:
		y_velocity += gravity_acceleration
		

	if input["jump"]:
		if _is_on_left_wall() && after_wall_jump_cooldown == 0 && wall_grab_energy > 0:
			y_velocity = -vertical_jump_speed
			x_velocity = horizontal_jump_speed
			after_wall_jump_cooldown = after_wall_jump_cooldown_time
		elif _is_on_right_wall() && after_wall_jump_cooldown == 0 && wall_grab_energy > 0:
			y_velocity = -vertical_jump_speed
			x_velocity = -horizontal_jump_speed
			after_wall_jump_cooldown = after_wall_jump_cooldown_time
		elif is_on_floor():
			y_velocity = -vertical_jump_speed

	if _is_grabbing_wall():
		y_velocity = y_velocity / grab_decceleration_ratio
		if y_velocity <= grab_slide_speed:
			y_velocity = grab_slide_speed
			
	velocity = Vector2(x_velocity, y_velocity) * calculated_delta
	
	move_and_slide()

	$TextEdit.text = str(local_delta) + "  " + str(calculated_delta)
	
func _physics_process(_delta):
	# modify wall jump cooldown properly
	after_wall_jump_cooldown -= 1.0 * _delta 
	if after_wall_jump_cooldown < 0: after_wall_jump_cooldown = 0
	# modify wall grab cooldown properly
	if _is_grabbing_wall(): wall_grab_energy -= 1.0 * _delta
	if is_on_floor(): wall_grab_energy = wall_grab_energy_time	

func _process(_delta):
	# modify player tilt based on velocity
	target_rotation_degrees = (velocity.x / max_speed) * max_lean_degrees
	rotation_degrees = lerp(rotation_degrees, target_rotation_degrees, lean_speed)
	
	# redraw shapes
	queue_redraw()
	
func _draw():
	$CollisionShape2D.shape.draw(get_canvas_item(), Color(1, 1, 1, 0.25))
	
	draw_circle(get_local_mouse_position(), 20, Color(1, 0, 0, 0.25))
	
func _is_grabbing_wall() -> bool:
	return _is_grabbing_left_wall() || _is_grabbing_right_wall()
	
func _is_grabbing_left_wall() -> bool:
	return _is_close_to_left_wall() && y_velocity >= 0 && wall_grab_energy > 0

func _is_grabbing_right_wall() -> bool:
	return _is_close_to_right_wall() && y_velocity >= 0 && wall_grab_energy > 0	

func _is_on_left_wall() -> bool:
	return _is_close_to_left_wall() && abs(velocity.x) <= acceleration # && velocity.y <= grab_slide_speed 
	
func _is_on_right_wall() -> bool:
	return _is_close_to_right_wall() && abs(velocity.x) <= acceleration # && velocity.y <= grab_slide_speed 

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
	velocity = entity.velocity
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
