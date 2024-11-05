extends CanvasLayer

@onready var label = $Label

func update_label(time_elapsed):
	var hour_mark = 10 + int(time_elapsed / 60)
	var min_mark = time_elapsed % 60
	
	var hour_str = str(hour_mark)
	if (hour_mark < 10):
		hour_str = "0"+hour_str
	var min_str = str(min_mark)
	if (min_mark < 10):
		min_str = "0"+min_str
	
	var time_section = "am" if (time_elapsed >= 120) else "pm"
	label.text = hour_str+":"+min_str+" "+time_section

func get_label_text():
	return label.text
