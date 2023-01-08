extends Area

signal create_particle

var col = {}
var ent
var col_pos
var act = 0

func _on_LifeTimer_timeout():
	queue_free()

func _ready():
	var just_in_case = connect("create_particle",$"..","make_particle")
	if just_in_case:
		printerr("connect failed, bullet " + name + " will not create particles")
	act = 1

func _process(delta):
	if act:
		col = get_world().direct_space_state.intersect_ray(global_translation, $BulletFireMax.global_translation, [self])
		if len(col) != 0:
			ent = col["collider"]
			col_pos = col["position"]
			$Model.translation.z = col_pos.z/2
			$Model.mesh.mid_height = col_pos.z
			emit_signal("create_particle", col_pos, 0)
		act = 0
