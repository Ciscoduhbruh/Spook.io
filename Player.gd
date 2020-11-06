extends RigidBody

export var movement_speed = 3
export var movement_input_acceleration = 7

export var crouch_speed_multiplier = 2.0/3
export var crouch_input_acceleration = 7

export var sprint_speed_multiplier = 4.0/3
export var sprint_input_acceleration = 7

export var minimum_view_angle = -90
export var maximum_view_angle =  90
export var head_rotation_acceleration = Vector2( 14, 14)
export var hand_rotation_acceleration = Vector2(  7 , 7)

var _movement_input_0 = Vector2()
var _movement_input_1 = Vector2()
var _movement_input_acceleration

var _crouch_input_0 = 0.0
var _crouch_input_1 = 0.0
var _crouch_input_acceleration

var _sprint_input_0 = 0.0
var _sprint_input_1 = 0.0
var _sprint_input_acceleration

var _view_rotation = Vector2()
var _minimum_view_angle
var _maximum_view_angle

var _head_rotation_0 = Vector2()
var _head_rotation_1 = Vector2()
var _head_rotation_acceleration = Vector2()

var _hand_rotation_0 = Vector2()
var _hand_rotation_1 = Vector2()
var _hand_rotation_acceleration = Vector2()

var _previous_translation

var maximum_stride = 2.25
var current_stride = 2.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)	
	_movement_input_acceleration = _acceleration(movement_input_acceleration)
	_crouch_input_acceleration   = _acceleration(crouch_input_acceleration )
	_sprint_input_acceleration   = _acceleration(sprint_input_acceleration )
	_head_rotation_acceleration  = _acceleration(head_rotation_acceleration)
	_hand_rotation_acceleration  = _acceleration(hand_rotation_acceleration)
	
	_minimum_view_angle = deg2rad(minimum_view_angle)
	_maximum_view_angle = deg2rad(maximum_view_angle)
	
	_previous_translation = translation
	
func set_movement_input_acceleration(value):
	movement_input_acceleration = value
	_movement_input_acceleration = _acceleration(value)
	
func set_crouch_input_acceleration(value):
	crouch_input_acceleration = value
	_crouch_input_acceleration = _acceleration(value)
	
func set_sprint_input_acceleration(value):
	sprint_input_acceleration = value
	_sprint_input_acceleration = _acceleration(value)
	
func set_head_rotation_acceleration(value):
	head_rotation_acceleration = value
	_head_rotation_acceleration = _acceleration(value)
	
func set_hand_rotation_acceleration(value):
	hand_rotation_acceleration = value
	_hand_rotation_acceleration = _acceleration(value)
	
func _acceleration(value):
	var type = typeof(value)
	
	if type == TYPE_INT || type == TYPE_REAL:
		return 1 - exp(-value)
	elif type == TYPE_VECTOR2:
		return Vector2(
			1 - exp(-value.x),
			1 - exp(-value.y)
		)
	elif type == TYPE_VECTOR3:
		return Vector3(
			1 - exp(-value.x),
			1 - exp(-value.y),
			1 - exp(-value.z)
		)
	
func dt(acceleration, delta):
	var type = typeof(acceleration)
	if type == TYPE_INT || type == TYPE_REAL:
		return 1 - pow(1 - acceleration, delta)
	elif TYPE_VECTOR2:
		return Vector2(
			1 - pow(1 - acceleration.x, delta),
			1 - pow(1 - acceleration.y, delta)
		)
	elif TYPE_VECTOR3:
		return Vector3(
			1 - pow(1 - acceleration.x, delta),
			1 - pow(1 - acceleration.y, delta),
			1 - pow(1 - acceleration.z, delta)
		)

func _process(delta):	
	_view_rotation.y = clamp(
		_view_rotation.y,
		_minimum_view_angle,
		_maximum_view_angle
	)
	_head_rotation_0 = _view_rotation
	_hand_rotation_0 = _view_rotation
	
	var dt
	
	dt = dt(_movement_input_acceleration, delta)
	_movement_input_1 += (_movement_input_0 - _movement_input_1) * dt
	
	dt = dt(_crouch_input_acceleration, delta)
	_crouch_input_1 += (_crouch_input_0 - _crouch_input_1) * dt
	
	dt = dt(_sprint_input_acceleration, delta)
	_sprint_input_1 += (_sprint_input_0 - _sprint_input_1) * dt
	
	dt = dt(_head_rotation_acceleration, delta)
	_head_rotation_1 += (_head_rotation_0 - _head_rotation_1) * dt
	
	dt = dt(_hand_rotation_acceleration, delta)
	_hand_rotation_1 += (_hand_rotation_0 - _hand_rotation_1) * dt

func _integrate_forces(state):
	rotation.y = _view_rotation.x
	$Head.rotation.y = _head_rotation_1.x - _view_rotation.x
	$Hand.rotation.y = _hand_rotation_1.x - _view_rotation.x
	
	for child in $Head.get_children():
		child.rotation.x = _head_rotation_1.y
		
	for child in $Hand.get_children():
		child.rotation.x = _hand_rotation_1.y
	
	var z_movement_input = global_transform.basis.z * _movement_input_1.x
	var x_movement_input = global_transform.basis.x * _movement_input_1.y
	
	var movement_input = z_movement_input + x_movement_input
	if movement_input.dot(movement_input) > 1:
		movement_input = movement_input.normalized()
		
	var _movement_speed = movement_speed
	if _crouch_input_1 > .5:
		_movement_speed *= crouch_speed_multiplier
	if _sprint_input_1 > .5:
		_movement_speed *= sprint_speed_multiplier
	
	state.linear_velocity.x = movement_input.x * _movement_speed
	state.linear_velocity.z = movement_input.z * _movement_speed
	
	var stride_delta_vector = translation - _previous_translation
	var stride_delta_amount = sqrt(stride_delta_vector.dot(stride_delta_vector))
	
	current_stride += stride_delta_amount
	if current_stride >= maximum_stride:
		current_stride = 0
		$SFX.play("Footstep")
		
	_previous_translation = translation
	
func do_primary_action():
	pass
	
func do_secondary_action():
	$Hand/Spotlight.visible = !$Hand/Spotlight.visible
	$Hand/Spotlight/Flashlight_Switch_3.play()
	pass
	
func do_auxiliary_action():
	pass


func _on_head_acceleration_x_changed(value):
	set_head_rotation_acceleration(Vector2(
		value,
		head_rotation_acceleration.y
	))


func _on_head_acceleration_y_changed(value):
	set_head_rotation_acceleration(Vector2(
		head_rotation_acceleration.x,
		value
	))


func _on_hand_acceleration_x_changed(value):
	set_hand_rotation_acceleration(Vector2(
		value,
		hand_rotation_acceleration.y
	))


func _on_hand_acceleration_y_changed(value):
	set_hand_rotation_acceleration(Vector2(
		hand_rotation_acceleration.x,
		value
	))
