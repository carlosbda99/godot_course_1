extends ParallaxBackground
class_name Background

export(bool) var can_process
export(Array, int) var layers_speed

func _ready():
	if !can_process:
		set_physics_process(false)
		

func _physics_process(delta):
	for index in get_child_count():
		var child = get_child(index)
		
		if child is ParallaxLayer:
			child.motion_offset.x -= delta * layers_speed[index]
