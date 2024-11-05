extends Area2D

var time = 0
var initial_y_position = 0

signal is_game_over

func _ready():
	initial_y_position = position.y

func _process(delta):
	# have item move up and down a slight amount
	var amplitude = 2
	var frequency = 4
	time += delta * frequency
	position.y = initial_y_position + sin(time) * amplitude

func _on_body_entered(_body):
	# send signal to game manager that the player has completed the game
	is_game_over.emit()
