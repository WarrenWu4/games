extends Area2D

class_name Item

var rng = RandomNumberGenerator.new()
var item_types = ["melatonin_pill", "headband", "homework_piece"]
var item = ""
var initial_y_position = 0
var time = 0

@onready var sprite_2d = $Sprite2D
@onready var game_manager = get_parent().get_parent()
@onready var label = $Label

func _ready():
	# for each item, randomly decide on what type it is	
	item = item_types[rng.randi_range(0, len(item_types)-1)]
	# update texture to item
	sprite_2d.texture = load("res://assets/items/"+item+".png")
	# set initial position
	initial_y_position = position.y
	# update item label
	label.text = format_text(item)

func _process(delta):
	# have item move up and down a slight amount
	var amplitude = 2
	var frequency = 4
	time += delta * frequency
	position.y = initial_y_position + sin(time) * amplitude

func _on_body_entered(_body):
	# apply effect to the player or game
	game_manager.apply_item_effect(item)
	# delete item from tree
	queue_free()

func format_text(item_name):
	# replace underscore with space
	return item_name.replace("_", " ")

