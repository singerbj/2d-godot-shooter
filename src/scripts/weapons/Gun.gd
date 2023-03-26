extends Node

class_name Gun

const ANIMATION_STEP : float = 0.001
const SECONDS_IN_A_MINUTE : float = 60.0

var weapon_manager # cant use WeaponManager as type because cyclical reference?
var animation_player : AnimationPlayer

var fire_rate_rpm : int

func _init():
	if !has_method("get_class_name"):
		push_error("This entity does not have a get_class_name function")
	elif typeof(call("get_class_name")) != TYPE_STRING:
		push_error("get_class_name does not return string for this entity")
	
func setup_animations():
	animation_player = AnimationPlayer.new()
	add_child(animation_player)
	
	var animation = Animation.new()
	animation_player.add_animation_library("fire_gun", animation)
	var idx = animation.add_track(Animation.TYPE_METHOD, 0)
	animation.track_set_path(idx, ".")
	animation.length = SECONDS_IN_A_MINUTE / fire_rate_rpm
	animation.step = ANIMATION_STEP
	animation.loop = true
	animation.track_insert_key(idx, 0, { "method" : "fire_gun" , "args" : [] })
	
func fire_gun():
	weapon_manager.fire_shot()


