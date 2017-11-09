extends Node2D

var rumbleEnd = false
var isRumbling = false


onready var animPlayer = get_node("AnimationPlayer")
onready var cam = get_node("Camera2D")


##process vars
var cnt = 0
var displace = 0
var hitDisplace = 0
var quakeDisplace = 0
var isQuaking = false

######tweenvars
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

func killedRumble():
	cnt += 3
	displace = 700

func bigHit():
	cnt += 10
	hitDisplace = 250

func quake(): #medium quake
	cnt += 650
	quakeDisplace = 350
	
func jumpRumble():
	cnt += 10
	displace = 70
	
func landRumble(_velocity):
	cnt += 12
	displace = 160
	

func _ready():
	startPosition = cam.position
#	rotationTween.connect("tween_completed",self,"_rotationTween_complete")
	positionTween.connect("tween_completed",self,"_positionTween_complete")
	
	animPlayer.connect("animation_started",self,"_animation_started")
	animPlayer.connect("animation_finished",self,"_animation_finished")
	cam.add_child(positionTween)
#	add_child(rotationTween)
	
#	startRotation = cam.rotation
#	rumble(1)

func _process(delta):
	var addForce
	if cnt > 0:
		addForce = Vector2(0,0)
		cnt -= 1
		# Called every frame. Delta is time since last frame.
		# Update game logic here.
		var off = Vector2(rand_range(-displace, displace), rand_range(-displace, displace))
	#	cam.offset = cam.offset + (off * delta)
		
		if isQuaking:
			addForce = Vector2(rand_range(-quakeDisplace, quakeDisplace), rand_range(-quakeDisplace, quakeDisplace))

		cam.offset = (addForce+off) * delta
	elif isQuaking:
		isQuaking=false
		addForce = Vector2(0,0)
	else:
		cam.offset = Vector2(0,0)

































##tweenshit


func _positionTween_complete (_a,_b):
	positionTween.stop_all()
	positionTween.reset_all()
#	positionTween.remove_all()
#	positionTween.reset_all()
#	positionTween.stop(cam,"position")
	if tweendCount<maxBounces and !rumbleEnd and isRumbling:
		var myOffset = randomOffset(intensity)
		tweendCount+=1
		print("aaagaaaaainnnn",cam.position,myOffset,startPosition)
		positionTween.interpolate_property(
			cam, #object to lerp
			"position", #property
			cam.position,
			myOffset+cam.position,
			timeScale,
			Tween.TRANS_LINEAR,Tween.EASE_IN
		)
		positionTween.start()
	elif !rumbleEnd and isRumbling:
		print("backtostart")
		##goback to start
		positionTween.interpolate_property(
			cam, #object to lerp
			"position", #property
			cam.position,
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
			cam, #object to lerp
			"position", #property
			startPosition,
			randomOffset(intensity)+cam.position,
			timeScale,
			Tween.TRANS_LINEAR,Tween.EASE_IN
		)
		isRumbling=true
		positionTween.start()
	#	animPlayer.play("rumbleJump")
	pass