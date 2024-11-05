extends CanvasLayer

class_name Menu

@onready var label = $Label
@onready var time_label = $Label2

func update_description_label(new_text_label):
	label.text = new_text_label

func update_completion_time(new_time_label):
	time_label.text = new_time_label

func _on_restart_button_pressed():
	get_tree().reload_current_scene()
