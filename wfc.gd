extends Spatial

export var grid_w = 16
export var grid_h = 16

var modules = []
var rules = []
var grid

func _ready():
	load_modules("res://afd_modules/afd_modules.json")	
	reset_grid()
	pass
	
func _process(delta):
	if Input.is_action_just_pressed("wfc_step"):
		if !solve_grid():
			reset_grid()
			solve_grid()
	pass	

	
func load_modules(path):
	modules = []
	rules = []	
	
	var file = File.new()
	if file.open(path, File.READ) != OK:
		return
	
	var text = file.get_as_text()
	file.close()
	var json = JSON.parse(text)
	
	if json.error != OK:
		return
	
	for module in json.result.modules:
		var sockets = []
		for socket in module.sockets:
			sockets.append(module.sockets[socket])
			
		for unique_transform in module.unique_transforms:
			var _sockets = []
			_sockets.resize(4)
			for i in range(4):
				var a = (i + 0               ) % 4
				var b = (i + unique_transform) % 4
				_sockets[a] = sockets[b]
				
			var _module = {}
			_module.name = module.name + "_" + str(unique_transform)
			_module.mesh = module.mesh
			_module.sockets = _sockets
			_module.rotation_degrees = unique_transform * -90
			
			modules.append(_module)	
		
	for rule in json.result.rules:
		rules.append(rule)
		
	pass

func is_solved():
	for x in range(grid_w):
		for y in range(grid_h):
			if grid[x][y].modules.size() > 1:
				return false
	return true
	
func reset_grid():
	randomize()
	for child in get_children():
		child.queue_free()
	
	var rows = []
	for x in range(grid_w):
		var cols = []
		rows.append(cols)
		for y in range(grid_h):
			cols.append({})
			cols[y].x = x
			cols[y].y = y
			cols[y].collapsed = false
			cols[y].modules = modules.duplicate()
			
						
	grid = rows

func solve_grid():	
	var current_entropy = modules.size()
	var minimum_entropy = modules.size()
	var candidates = []
	
	for x in range(grid_w):
		for y in range(grid_h):
			current_entropy = grid[x][y].modules.size()
			if current_entropy > 1:
				if current_entropy <= minimum_entropy:
					if current_entropy < minimum_entropy:
						candidates = []
						minimum_entropy = current_entropy
					candidates.append(grid[x][y])
	
	if candidates.size() < 1:
		return false
		
	var candidate = candidates[randi() % candidates.size()]
	var candidate_module = candidate.modules[randi() % candidate.modules.size()]
	candidate.modules = [candidate_module]
	
	collapse(candidate)
	
	return true
	
func collapse(from):
	var back = [from]
	while back.size():
		var next = back.pop_back()
		var next_module = next.modules[0]
		
		next.collapsed = true

		var mesh_instance = MeshInstance.new()
		var mesh = load("res://afd_modules/" + next_module.mesh)
		
		mesh_instance.set_mesh(mesh)
		mesh_instance.translation.x = next.x
		mesh_instance.translation.z = next.y
		mesh_instance.rotation_degrees.y = next_module.rotation_degrees
		
		add_child(mesh_instance)
		
		var neighbors = [
			neighbor(next,  1,  0),
			neighbor(next,  0, -1),
			neighbor(next, -1,  0),
			neighbor(next,  0,  1)
		]
		
		for i in neighbors.size():
			var neighbor = neighbors[i]
			
			if neighbor != null:
				var compatible_modules = compatible_modules(
					next_module.sockets[i],
					neighbor.modules,
					(i + 2) % 4
				)
				
				if compatible_modules.size() <  1:
					return false
					
				neighbor.modules = compatible_modules
				if neighbor.modules.size() == 1 && !neighbor.collapsed:
					back.push_back(neighbor)
	
func neighbor(from, dx, dy):
	var x = from.x + dx
	var y = from.y + dy
	if x >= 0 && y >= 0 && x < grid_w && y < grid_h:
		return grid[x][y]
	return null
	
func compatible_modules(socket, modules, index):
	var compatible_modules = []
	
	for module in modules:
		if is_compatible(socket, module.sockets[index]):
			compatible_modules.append(module)
	
	return compatible_modules
	
func is_compatible(socket_a, socket_b):
	for rule in rules:
		var orientation_0 = socket_a == rule[0] && socket_b == rule[1]
		var orientation_1 = socket_a == rule[1] && socket_b == rule[0]
		if orientation_0 || orientation_1:
			return true
	return false

