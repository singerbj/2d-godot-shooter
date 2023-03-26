extends CharacterBody3D

var players : Dictionary
var player_id : int

const SPEED : float = 8.0
const ACCELERATION_DEFAULT : float = 7.0
const ACCELERATION_AIR : float = 1.0
const GRAVITY : float = 25.0
const DEFAULT_JUMP_INERTIA : float = 200.0
const SENS_MULTIPLIER : float = 0.03
const STARTING_HEAD_ANGLE : float = 0.0
const JUMP_FORCE : float = 10.0
const MAX_HEALTH : float = 1000.0

var weapon_manager : WeaponManager

const MAX_BOT_MOVE_TIME = 60
var is_bot = false
var bot_move_time = 0
var bot_move_key = "m_left"

var is_local_player : bool = false
var head_nod_angle : float = STARTING_HEAD_ANGLE
#var velocity = Vector3.ZERO

@onready var accel : float = ACCELERATION_DEFAULT
var mouse_sense = 0.1
var snap
var direction = Vector3()
var gravity_direction = Vector3()
var movement = Vector3()

var last_transform : Transform3D
var last_rotation : Vector3
var last_head_nod_angle : float
var current_transform : Transform3D
var current_rotation : Vector3
var current_head_nod_angle : float

var health : float = MAX_HEALTH

func _ready():
	weapon_manager = WeaponManager.new(self, $Camera3D)

func _enter_tree():
	last_transform = transform
	last_rotation = rotation
	last_head_nod_angle = head_nod_angle
	
#	if is_local_player:
#		set_physics_interpolation_mode(Node.PHYSICS_INTERPOLATION_MODE_OFF)
		
func _process(delta):
	$HealthBar/SubViewport/TextureProgressBar.value = (health / MAX_HEALTH) * 100

func rotate_player_with_input(mouse_motion : Vector2):
	last_rotation = rotation
	last_head_nod_angle = head_nod_angle
	
	# Rotate body around the vertical axis
	rotation_degrees.y -= SENS_MULTIPLIER * mouse_motion.x
	# Rotate head around the horizontal (like nodding)
	head_nod_angle -= SENS_MULTIPLIER * mouse_motion.y
	head_nod_angle = clamp(head_nod_angle, STARTING_HEAD_ANGLE - 80, STARTING_HEAD_ANGLE + 80)
	if $Camera3D != null:
		$Camera3D.rotation_degrees.x = head_nod_angle
		
func rotate_player_with_values(rotation_degrees_from_server : float, head_nod_angle_from_server : float):
	last_rotation = rotation
	last_head_nod_angle = head_nod_angle
	
	rotation_degrees.y = rotation_degrees_from_server
	head_nod_angle = head_nod_angle_from_server
	if $Camera3D != null:
		$Camera3D.rotation_degrees.x = head_nod_angle_from_server

func move(input : NetworkInput, local_delta : float):
	last_transform = transform
	
	var move_vector = Vector3.ZERO
	var jump = false
	
	if self.is_bot:
		bot_move_time += 1
		if bot_move_time > MAX_BOT_MOVE_TIME:
			bot_move_time = 0
			if bot_move_key == "m_left":
				bot_move_key = "m_right"
			else:
				bot_move_key = "m_left"
		input[bot_move_key] = true
	
	if input["m_forward"]:
		move_vector += -global_transform.basis.z
	if input["m_backward"]:
		move_vector += global_transform.basis.z
	if input["m_left"]:
		move_vector += -global_transform.basis.x
	if input["m_right"]:
		move_vector += global_transform.basis.x
	if input["jump"]: # && is_on_floor():
		jump = true
	
	#jumping and gravity
	if is_on_floor():
		snap = -get_floor_normal()
		accel = ACCELERATION_DEFAULT
		gravity_direction = Vector3.ZERO
	else:
		snap = Vector3.DOWN
		accel = ACCELERATION_AIR
		gravity_direction += Vector3.DOWN * GRAVITY * local_delta
		
	if jump and is_on_floor():
		snap = Vector3.ZERO
		gravity_direction = Vector3.UP * JUMP_FORCE
	
	# make it move
	velocity = velocity.lerp(move_vector * SPEED, accel * local_delta)
	movement = velocity + gravity_direction
	movement = movement * (input.delta / local_delta)
	
	set_velocity(movement)
	# TODOConverter40 looks that snap in Godot 4.0 is float, not vector like in Godot 3 - previous value `snap`
	set_up_direction(Vector3.UP)
	move_and_slide()
	
func update_local_player_from_server(entity : PlayerEntity):
	health = entity.health
		
func update_peer_player_from_server(entity : PlayerEntity):
	transform = entity.transform
	rotation = entity.rotation
	head_nod_angle = entity.head_nod_angle
	if $Camera3D != null:
		$Camera3D.rotation_degrees.x = entity.head_nod_angle
		
	health = entity.health
		
func take_damage(damage : float):
	health -= damage
	
func equip_weapon(weapon_index):
	weapon_manager.ready_weapon(weapon_index)
	
func get_camera_3d() -> Node:
	return $Camera3D

func set_camera_active():
	if $Camera3D != null:
		$Camera3D.make_current()
	
	
