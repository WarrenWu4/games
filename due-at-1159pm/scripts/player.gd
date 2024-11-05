extends CharacterBody2D

class_name Player

var speed = Vector2(150, -300)
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var states = ["normal", "frozen", "launching"]
var curr_state = states[0]
var original_position = Vector2(0, 0)

@onready var timer = $Timer
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var label = $Label
@onready var texture_rect = $TextureRect

func _ready():
	label.hide()
	texture_rect.hide()
	original_position = position

func _physics_process(delta):
	# check if player is falling off the face of the earth
	if position.y >= 200:
		position = original_position
	
	if curr_state == "launching":
		animated_sprite_2d.play("default")
		velocity.y += gravity * delta
		move_and_slide()
		if is_on_floor():
			curr_state = states[0]
			label.hide()
			texture_rect.hide()
		return
	
	# don't move if frozen
	if curr_state == "frozen":
		# make sure to still apply gravity
		if !is_on_floor():
			velocity.y += gravity*delta
			move_and_slide()
			animated_sprite_2d.play("default")
		return
	
	# horizontal movement
	if Input.is_action_pressed("move_left"):
		velocity.x = -speed.x
		animated_sprite_2d.flip_h = true
		animated_sprite_2d.play("run")
	elif Input.is_action_pressed("move_right"):
		velocity.x = speed.x
		animated_sprite_2d.flip_h = false	
		animated_sprite_2d.play("run")	
	else:
		velocity.x = move_toward(velocity.x, 0, speed.x)
		animated_sprite_2d.play("default")			

	# vertical movement (jump and gravity)
	if is_on_floor() and Input.is_action_just_pressed("jump"):
			velocity.y = speed.y
	else:
		velocity.y += gravity * delta

	move_and_slide()

func update_state(state):
	curr_state = state
	timer.start(5)
	label.text = "zzz"
	label.show()
	texture_rect.show()

func update_speed(new_speed):
	speed = new_speed
	timer.start(5)
	label.text = "SPED!"
	label.show()
	texture_rect.show()
		
func launch_player(_direction):
	curr_state = "launching"
	var radians = deg_to_rad(45)
	var launch_speed = 400
	velocity.x = launch_speed*cos(radians)
	velocity.y = -launch_speed*sin(radians)
	label.text = "WEE"
	label.show()
	texture_rect.show()
	
func _on_timer_timeout():
	label.hide()
	texture_rect.hide()
	speed = Vector2(150, -300)
	curr_state = states[0]
