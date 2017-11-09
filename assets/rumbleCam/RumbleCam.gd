extends Node2D

var rumbleEnd = false
var isRumbling =false

onready var animPlayer = get_node("AnimationPlayer")
onready var camNode = get_node("Camera2D")

var startPosition
var startRotation
var tmpPosition
var tmpRotation
var timeScale = 1
var intensity = 100 #in pixels

var maxBounces = 5
var tweendCount = 0

#var rotationTween = Tween.new()
var positionTween = Tween.new()

func _ready():
	startPosition = camNode.position
#	rotationTween.connect("tween_completed",self,"_rotationTween_complete")
	positionTween.connect("tween_completed",self,"_positionTween_complete")
	
	animPlayer.connect("animation_started",self,"_animation_started")
	animPlayer.connect("animation_finished",self,"_animation_finished")
	camNode.add_child(positionTween)
#	add_child(rotationTween)
	
#	startRotation = camNode.rotation
	rumble(1)

func _positionTween_complete (_a,_b):
	positionTween.stop_all()
	positionTween.reset_all()
#	positionTween.remove_all()
#	positionTween.reset_all()
#	positionTween.stop(camNode,"position")
	if tweendCount<maxBounces and !rumbleEnd and isRumbling:
		var myOffset = randomOffset(intensity)
		tweendCount+=1
		print("aaagaaaaainnnn",camNode.position,myOffset,startPosition)
		positionTween.interpolate_property(
			camNode, #object to lerp
			"position", #property
			camNode.position,
			myOffset+camNode.position,
			timeScale,
			Tween.TRANS_LINEAR,Tween.EASE_IN
		)
		positionTween.start()
	elif !rumbleEnd and isRumbling:
		print("backtostart")
		##goback to start
		positionTween.interpolate_property(
			camNode, #object to lerp
			"position", #property
			camNode.position,
			startPosition,
			timeScale,
			Tween.TRANS_LINEAR,Tween.EASE_IN
		)
		positionTween.start()
#		positionTween.start()
	elif rumbleEnd and isRumbling:
		print("reset")
		tweendCount = 0
		isRumbling = false
		rumbleEnd =false
	pass
	
func _rotationTween_complete (_a,_b):
	pass

func _animation_started(_string):
#	isPlaying = true
	pass
func _animation_finished(_string):
#	isPlaying = false
	pass

func randomOffset(_range):
	var myOffset = Vector2(rand_range(-_range,_range),rand_range(-_range,_range))
	return myOffset
	
func rumble(_strength):
	if !isRumbling:
		positionTween.interpolate_property(
			camNode, #object to lerp
			"position", #property
			startPosition,
			randomOffset(intensity)+camNode.position,
			timeScale,
			Tween.TRANS_LINEAR,Tween.EASE_IN
		)
		isRumbling=true
		positionTween.start()
	#	animPlayer.play("rumbleJump")
	pass