extends Camera3D

# Node that the camera will follow
var _target

# We will smoothly lerp to follow the target
# rather than follow exactly
var _target_pos : Vector3 = Vector3()

func _ready():
	_target = get_node("../CharacterBody3D")
	

func _process(delta: float) -> void:
	# Find the current interpolated transform of the target
	var tr : Transform3D = _target.get_global_transform_interpolated()

	# Provide some delayed smoothed lerping towards the target position
	_target_pos = lerp(_target_pos, tr.origin, min(delta, 1.0))

	# Fixed camera position, but it will follow the target
#	look_at(_target_pos, Vector3(0, 1, 0))
	transform.origin = _target_pos
