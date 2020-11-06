extends Spatial

const PLAYER_PRIMARY_ACTION = "player_primary_action"
const PLAYER_SECONDARY_ACTION = "player_secondary_action"
const PLAYER_AUXILIARY_ACTION = "player_auxiliary_action"
const PLAYER_MOVE_POSITIVE_Z_ACTION = "player_move_positive_z"
const PLAYER_MOVE_NEGATIVE_Z_ACTION = "player_move_negative_z"
const PLAYER_MOVE_POSITIVE_X_ACTION = "player_move_positive_x"
const PLAYER_MOVE_NEGATIVE_X_ACTION = "player_move_negative_x"
const PLAYER_SPRINT_ACTION = "player_sprint"
const PLAYER_CROUCH_ACTION = "player_crouch"

export var mouse_sensitivity_x = .5
export var mouse_sensitivity_y = .5

export var crouch_toggle = false
export var sprint_toggle = false

var _player

func _ready():
	_player = get_parent()
	
func _input(event):
	if event is InputEventMouseMotion:
		var dx = deg2rad(event.relative.x) * mouse_sensitivity_x
		var dy = deg2rad(event.relative.y) * mouse_sensitivity_y
		
		_player._view_rotation.x -= dx
		_player._view_rotation.y -= dy
	
func _process(delta):
	if Input.is_action_just_pressed(PLAYER_PRIMARY_ACTION):
		_player.do_primary_action()
	if Input.is_action_just_pressed(PLAYER_SECONDARY_ACTION):
		_player.do_secondary_action()
	if Input.is_action_just_pressed(PLAYER_AUXILIARY_ACTION):
		_player.do_auxiliary_action()
	
	var negative_z = Input.get_action_strength(PLAYER_MOVE_NEGATIVE_Z_ACTION) # forward
	var positive_z = Input.get_action_strength(PLAYER_MOVE_POSITIVE_Z_ACTION) # backward
	var negative_x = Input.get_action_strength(PLAYER_MOVE_NEGATIVE_X_ACTION) # right
	var positive_x = Input.get_action_strength(PLAYER_MOVE_POSITIVE_X_ACTION) # left
	
	_player._movement_input_0 = Vector2(
		positive_z - negative_z,
		positive_x - negative_x
	)
	
	if crouch_toggle:
		if Input.is_action_just_pressed(PLAYER_CROUCH_ACTION):
			_player._crouch_input_0 = 0 if _player.crouch_input_0 > 0 else 1
	else:
		_player._crouch_input_0 = Input.get_action_strength(PLAYER_CROUCH_ACTION)
		
	if sprint_toggle:
		if Input.is_action_just_pressed(PLAYER_SPRINT_ACTION):
			_player._sprint_input_0 = 0 if _player.sprint_input_0 > 0 else 1
	else:
		_player._sprint_input_0 = Input.get_action_strength(PLAYER_SPRINT_ACTION)


func _on_mouse_sensitivity_x_changed(value):
	mouse_sensitivity_x = value

func _on_mouse_sensitivity_y_changed(value):
	mouse_sensitivity_y = value
