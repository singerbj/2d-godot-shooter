extends Node2D

class_name LineDrawer

var DEFAULT_THICKNESS : float = 4.0
var LINE_SHRINK_AMOUNT : int = 10

class Line:
	var color
	var thickness = 4.0
	var start
	var end
	var time
	
var lines : Dictionary = {}
var camera : Camera3D
var next_id : int = 0

func _ready():
	set_process(true)

func _draw():
	camera = get_viewport().get_camera_3d()
	var line : Line
	for key in lines.keys():
		line = lines[key]
		var adjusted_start = camera.unproject_position(line.start)
		var adjusted_end = camera.unproject_position(line.end)
		
		draw_line(adjusted_start, adjusted_end, line.color, line.thickness)

func _process(delta):
	var to_delete = []
	var line : Line
	for key in lines.keys():
		line = lines[key]
		line.thickness = line.thickness - (delta * LINE_SHRINK_AMOUNT)
		if line.thickness < 1:
			lines.erase(key)

func draw_line_3d(start : Vector3, end : Vector3, color : Color, thickness : float = DEFAULT_THICKNESS, time : int = Time.get_ticks_msec()):
	var new_line = Line.new()
	new_line.color = color
	new_line.start = start
	new_line.end = end
	new_line.thickness = thickness
	new_line.time = time
	
	next_id += 1
	lines[next_id] = new_line
