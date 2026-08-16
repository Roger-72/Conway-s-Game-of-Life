extends Panel

@onready var run_button = $RunButton
@onready var direction_button = $DirectionButton

func _ready():
	
	run_button.texture_normal = load("res://run.png")
	direction_button.texture_normal = load("res://r.png")
	direction_button.position = Vector2(size.x+11, 0)

func _process(delta):
	pass
