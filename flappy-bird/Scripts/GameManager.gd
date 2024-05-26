extends Node

@onready var pipe_spawner_node = $"../PipeSpawner"
@onready var bird_node = $"../bird"
@onready var ground_node = $"../ground"
@onready var fade = $"../Fade"
@onready var ui = $"../UI"

var points = 0

func _ready():
	bird_node.game_start.connect(on_game_start)
	ground_node.bird_crashed.connect(on_end_game)
	pipe_spawner_node.bird_crashed.connect(on_end_game)
	pipe_spawner_node.point_scored.connect(on_add_point)

func on_game_start():
	pipe_spawner_node.start_spawner()

func on_end_game():
	if (fade != null):
		fade.play()
	ground_node.stop()
	bird_node.kill()
	pipe_spawner_node.stop()
	ui.on_game_over()

func on_add_point():
	points += 1
	ui.update_points(points)
