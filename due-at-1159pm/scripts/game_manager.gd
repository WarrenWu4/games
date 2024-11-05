extends Node

class_name GameManager

@onready var player = $Player
@onready var timer = $Timer
@onready var hud = $HUD

var elapsed_time = 0

func _ready():
	timer.start()

func apply_item_effect(item_type):
	if (item_type == "melatonin_pill"):
		player.update_state("frozen")
	elif (item_type == "headband"):
		player.update_speed(Vector2(200, -350))
	elif (item_type == "homework_piece"):
		player.launch_player(1)

func _on_timer_timeout():
	elapsed_time += 1
	hud.update_label(elapsed_time)
	if (elapsed_time >= 120):
		you_are_a_failure()

func _on_complete_homework_is_game_over():
	var completion_time = hud.get_label_text()
	for child in self.get_children():
		remove_child(child)
		child.queue_free()
	var menu_scene = load("res://scenes/menu.tscn")
	var menu_instance = menu_scene.instantiate()
	add_child(menu_instance)
	menu_instance.update_completion_time(completion_time+"!")

func you_are_a_failure():
	for child in self.get_children():
		remove_child(child)
		child.queue_free()
	var menu_scene = load("res://scenes/menu.tscn")
	var menu_instance = menu_scene.instantiate()
	add_child(menu_instance)
	menu_instance.update_completion_time("")
	menu_instance.update_description_label("uh oh, you didn't\nturn in your\nassignment on time :(")
