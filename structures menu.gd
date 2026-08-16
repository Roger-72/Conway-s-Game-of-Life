extends PopupMenu


# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass

func _input(event):
	if visible:
		if event.is_action_pressed('M_button'):
			hide()


