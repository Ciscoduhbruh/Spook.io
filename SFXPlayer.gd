extends Spatial

func play(sfx = null):
	if sfx != null:
		get_node(sfx).play()
	else:
		get_child(randi() % get_child_count()).play()	
	pass
