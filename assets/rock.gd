extends RigidBody2D

var pos
var addFakeSpeed = false

func _ready():
	set_physics_process(true)
	pass

func _on_Area2D_body_entered( body ):
	if body.is_in_group("ground") and get_parent().get_name()=="rockShower":
		addFakeSpeed = true

func changeParent(_parent):
	pos = global_position
	var newParent = _parent.constMovementNode
	_parent.remove_child(self)
	newParent.add_child(self)
	global_translate(pos+Vector2(newParent.global_position.x,0))
	print(get_parent())

func _physics_process(delta):
	if is_inside_tree() and addFakeSpeed:
		global_position.x-=get_parent().game.fakeSpeed*delta
	elif !is_inside_tree():
		set_physics_process(false)
		
func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
	pass # replace with function body
