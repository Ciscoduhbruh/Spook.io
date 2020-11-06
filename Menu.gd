extends Control

func _process(delta):
	if Input.is_action_just_pressed("pause"):
		visible = !visible
		
		var controller = get_node("/root/Game/Scene/Player/Controller")
		
		controller.set_process(!visible)
		controller.set_process_input(!visible)
		
		if visible:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
