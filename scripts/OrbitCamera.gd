extends Spatial

export var input_button: String

var old_rotation
var click_position
func _process(_delta):
	if Input.is_action_just_pressed(input_button):
		old_rotation = rotation_degrees
		click_position = get_viewport().get_mouse_position()
	if Input.is_action_pressed(input_button):
		var rot_x = clamp(old_rotation.x - (get_viewport().get_mouse_position().y - click_position.y), -90, 90)
		var rot_y = old_rotation.y - (get_viewport().get_mouse_position().x - click_position.x)
		rotation_degrees = Vector3(rot_x, rot_y, 0)
