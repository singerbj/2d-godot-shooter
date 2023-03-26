extends CharacterBody2D

const acceleration = 40
const ground_decceleration = 20
const air_decceleration = 0
const grab_decceleration_ratio = 2.25
const grab_slide_speed = 60
const decceleration = 20
const max_speed = 300
const vertical_jump_speed = -1250
const horizontal_jump_speed = 1000
const gravity = 4000
const max_lean_degrees = 2.5
const lean_speed = 0.25
const min_step_distance = 5
const action_wait_time_s = 0.35

var target_rotation_degrees = rotation_degrees
var wait_time = 0

func _ready():
	pass

func _physics_process(_delta):
	$RayCast2DLeft.force_raycast_update()
	$RayCast2DRight.force_raycast_update()
	$RayCast2DBottom.force_raycast_update()
	
	if wait_time == 0:
		if (Input.is_action_pressed("m_right") && Input.is_action_pressed("m_left")) || (!Input.is_action_pressed("m_right") && !Input.is_action_pressed("m_left")):
			if velocity.x > 0:
				velocity.x -= ground_decceleration if is_on_floor() else air_decceleration
			elif velocity.x < 0:
				velocity.x += ground_decceleration if is_on_floor() else air_decceleration
		elif Input.is_action_pressed("m_left"):
			velocity.x -= acceleration
		elif Input.is_action_pressed("m_right"):
			velocity.x += acceleration
	
	if velocity.x > max_speed:
		velocity.x = max_speed
	if velocity.x < -max_speed:
		velocity.x = -max_speed
				
	if Input.is_action_just_pressed("jump"):
		if _is_on_left_wall() && wait_time == 0:
			velocity.y = vertical_jump_speed
			velocity.x = horizontal_jump_speed
			wait_time = action_wait_time_s
		elif _is_on_right_wall() && wait_time == 0:
			velocity.y = vertical_jump_speed
			velocity.x = -horizontal_jump_speed
			wait_time = action_wait_time_s
		elif is_on_floor():
			velocity.y = vertical_jump_speed
			
	velocity.y += gravity * _delta
	
	var grabbing_left_wall: bool = _is_close_to_left_wall() && Input.is_key_pressed(KEY_A) && velocity.y >= 0
	var grabbing_right_wall: bool = _is_close_to_right_wall() && Input.is_key_pressed(KEY_D) && velocity.y >= 0
	if grabbing_left_wall || grabbing_right_wall:
		velocity.y = velocity.y / grab_decceleration_ratio
		if velocity.y <= grab_slide_speed:
			velocity.y = grab_slide_speed
		
	move_and_slide()
	
	target_rotation_degrees = (velocity.x / max_speed) * max_lean_degrees
	
	wait_time -= _delta * 1
	if wait_time < 0: wait_time = 0
	
	$TextEdit.text = str(wait_time)
	
func _process(_delta):
	rotation_degrees = lerp(rotation_degrees, target_rotation_degrees, lean_speed)
	
func _draw():
	$CollisionShape2D.shape.draw(get_canvas_item(), Color(1, 1, 1, 0.25))
	
func _is_on_left_wall() -> bool:
	return _is_close_to_left_wall() && velocity.x <= -acceleration && velocity.y <= grab_slide_speed 
	
func _is_on_right_wall() -> bool:
	return _is_close_to_right_wall() && velocity.x >= acceleration && velocity.y <= grab_slide_speed 

func _is_close_to_left_wall() -> bool:
	return $RayCast2DLeft.is_colliding() && !_is_close_to_floor()

func _is_close_to_right_wall() -> bool:
	return $RayCast2DRight.is_colliding() && !_is_close_to_floor()
	
func _is_close_to_floor() -> bool:
	return $RayCast2DBottom.is_colliding()
