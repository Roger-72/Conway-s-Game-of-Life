extends Panel

@onready var title = $Title
@onready var random_label = $RandomLabel
@onready var random_button = $RandomButton
@onready var erase_button = $EraseButton
@onready var erase_label = $EraseLabel
@onready var cell_button =  $CellButton
@onready var cell_label = $CellLabel
@onready var left_button =  $LeftButton
@onready var right_button =  $RightButton
@onready var climber_button = $ClimberButton
@onready var climber_label = $ClimberLabel
@onready var pulsar_button = $PulsarButton
@onready var pulsar_label = $PulsarLabel
@onready var blinker_button = $BlinkerButton
@onready var blinker_label = $BlinkerLabel
@onready var hatter_button = $HatterButton
@onready var hatter_label = $HatterLabel
@onready var flower_button = $FlowerButton
@onready var flower_label = $FlowerLabel
@onready var ship_button = $ShipButton
@onready var ship_label = $ShipLabel
@onready var brush_button = $BrushButton
@onready var brush_label = $BrushLabel
@onready var bomb_button = $BombButton
@onready var bomb_label = $BombLabel
@onready var clover_button = $CloverButton
@onready var clover_label = $CloverLabel
@onready var sunflower_button = $SunflowerButton
@onready var sunflower_label = $SunflowerLabel
@onready var wallpaper_button = $WallpaperButton
@onready var wallpaper_label = $WallpaperLabel
@onready var twoclover_button = $TwoCloverButton
@onready var twoclover_label = $TwoCloverLabel
@onready var options_button = $OptionsButton
@onready var options_label = $OptionsLabel
@onready var lily_button = $LilyButton
@onready var lily_label = $LilyLabel


var num = 0
var conway_buttons = []
var conway_labels = []

func _ready():
	
	title.position = Vector2(300 , 20)
	title.text = "Conway's Game Of Life"
	title.add_theme_font_size_override("font_size", 35)
	
	random_label.position = Vector2(430 , 420)
	random_label.text = "Random"
	random_label.add_theme_font_size_override("font_size", 30)
	random_label.visible = false
	
	wallpaper_label.position = Vector2(70 , 420)
	wallpaper_label.text = "Wallpaper"
	wallpaper_label.add_theme_font_size_override("font_size", 30)
	
	options_label.position = Vector2(850 , 33)
	options_label.text = "Options"
	options_label.add_theme_font_size_override("font_size", 25)
	
	erase_label.position = Vector2(790 , 420)
	erase_label.text = "Erase"
	erase_label.add_theme_font_size_override("font_size", 30)
	
	cell_label.position = Vector2(417 , 420)
	cell_label.text = "Single cell"
	cell_label.add_theme_font_size_override("font_size", 30)
	
	climber_label.position = Vector2(435 , 420)
	climber_label.text = "Climber"
	climber_label.add_theme_font_size_override("font_size", 30)
	climber_label.visible = false
	
	hatter_label.position = Vector2(442 , 420)
	hatter_label.text = "Hatter"
	hatter_label.add_theme_font_size_override("font_size", 30)
	hatter_label.visible = false
	
	pulsar_label.position = Vector2(445 , 420)
	pulsar_label.text = "Pulsar"
	pulsar_label.add_theme_font_size_override("font_size", 30)
	pulsar_label.visible = false
	
	blinker_label.position = Vector2(439 , 420)
	blinker_label.text = "Blinker"
	blinker_label.add_theme_font_size_override("font_size", 30)
	blinker_label.visible = false
	
	flower_label.position = Vector2(442 , 420)
	flower_label.text = "Clover"
	flower_label.add_theme_font_size_override("font_size", 30)
	flower_label.visible = false
	
	ship_label.position = Vector2(457 , 420)
	ship_label.text = "Ship"
	ship_label.add_theme_font_size_override("font_size", 30)
	ship_label.visible = false

	brush_label.position = Vector2(392 , 420)
	brush_label.text = "Brush (eraser)"
	brush_label.add_theme_font_size_override("font_size", 30)
	brush_label.visible = false
	
	bomb_label.position = Vector2(445 , 420)
	bomb_label.text = "Bomb"
	bomb_label.add_theme_font_size_override("font_size", 30)
	bomb_label.visible = false
	
	clover_label.position = Vector2(435 , 420)
	clover_label.text = "Clover 2"
	clover_label.add_theme_font_size_override("font_size", 30)
	clover_label.visible = false
	
	sunflower_label.position = Vector2(417 , 420)
	sunflower_label.text = "Sunflower"
	sunflower_label.add_theme_font_size_override("font_size", 30)
	sunflower_label.visible = false
	
	twoclover_label.position = Vector2(460 , 420)
	twoclover_label.text = "Bug"
	twoclover_label.add_theme_font_size_override("font_size", 30)
	twoclover_label.visible = false
	
	lily_label.position = Vector2(448 , 420)
	lily_label.text = "Lotus"
	lily_label.add_theme_font_size_override("font_size", 30)
	lily_label.visible = false
	
	
	
	
	
	
	
	random_button.texture_normal = load("res://dice.png")
	random_button.texture_hover = load("res://dice2.png")
	random_button.position = Vector2(370, 150)
	random_button.visible = false
	
	wallpaper_button.texture_normal = load("res://W.png")
	wallpaper_button.position = Vector2(20, 150)
	
	options_button.texture_normal = load("res://settings_logo.png")
	options_button.texture_hover = load("res://settings_logo2.png")
	options_button.position = Vector2(790,25)
	
	erase_button.texture_normal = load("res://eraser.png")
	erase_button.texture_hover = load("res://eraser.png")
	erase_button.position = Vector2(710, 150)
	
	left_button.texture_normal = load("res://left.png")
	left_button.texture_hover = load("res://left2.png")
	left_button.position = Vector2(310, 225)
	
	right_button.texture_normal = load("res://right.png")
	right_button.texture_hover = load("res://right2.png")
	right_button.position = Vector2(620, 225)

	cell_button.texture_normal = load("res://single_cell.png")
	cell_button.texture_hover = load("res://single_cell2.png")
	cell_button.position = Vector2(370, 150)
	
	climber_button.texture_normal = load("res://climber.png")
	climber_button.texture_hover = load("res://climber2.png")
	climber_button.position = Vector2(370, 150)
	climber_button.visible = false
	
	hatter_button.texture_normal = load("res://hatter.png")
	hatter_button.texture_hover = load("res://hatter2.png")
	hatter_button.position = Vector2(370, 150)
	hatter_button.visible = false
	
	pulsar_button.texture_normal = load("res://pulsar.png")
	pulsar_button.texture_hover = load("res://pulsar2.png")
	pulsar_button.position = Vector2(370, 150)
	pulsar_button.visible = false
	
	blinker_button.texture_normal = load("res://blinker.png")
	blinker_button.texture_hover = load("res://blinker2.png")
	blinker_button.position = Vector2(370, 150)
	blinker_button.visible = false
	
	flower_button.texture_normal = load("res://clover.png")
	flower_button.texture_hover = load("res://clover2.png")
	flower_button.position = Vector2(370, 150)
	flower_button.visible = false
	
	ship_button.texture_normal = load("res://ship.png")
	ship_button.texture_hover = load("res://ship2.png")
	ship_button.position = Vector2(370, 150)
	ship_button.visible = false
	
	brush_button.texture_normal = load("res://brush.png")
	brush_button.position = Vector2(370, 150)
	brush_button.visible = false
	
	bomb_button.texture_normal = load("res://bomb.png")
	bomb_button.texture_hover = load("res://bomb2.png")
	bomb_button.position = Vector2(370, 150)
	bomb_button.visible = false
	
	clover_button.texture_normal = load("res://clover3.png")
	clover_button.texture_hover = load("res://clover4.png")
	clover_button.position = Vector2(370, 150)
	clover_button.visible = false

	sunflower_button.texture_normal = load("res://sunflower.png")
	sunflower_button.texture_hover = load("res://sunflower2.png")
	sunflower_button.position = Vector2(370, 150)
	sunflower_button.visible = false
	
	twoclover_button.texture_normal = load("res://clovers.png")
	twoclover_button.texture_hover = load("res://clovers2.png")
	twoclover_button.position = Vector2(370, 150)
	twoclover_button.visible = false
	
	lily_button.texture_normal = load("res://lotus.png")
	lily_button.texture_hover = load("res://lotus2.png")
	lily_button.position = Vector2(370, 150)
	lily_button.visible = false
	
	conway_buttons = [cell_button, climber_button, hatter_button, brush_button, pulsar_button, blinker_button, bomb_button, ship_button, flower_button, clover_button, twoclover_button, lily_button, sunflower_button, random_button]
	conway_labels = [cell_label, climber_label, hatter_label, brush_label, pulsar_label, blinker_label,bomb_label, ship_label, flower_label, clover_label, twoclover_label, lily_label, sunflower_label, random_label]
	
	random_button.pressed.connect(randomise)
	erase_button.pressed.connect(erase)
	cell_button.pressed.connect(cell)
	climber_button.pressed.connect(climb)
	hatter_button.pressed.connect(hat_up)
	pulsar_button.pressed.connect(pulse)
	blinker_button.pressed.connect(blink)
	flower_button.pressed.connect(sprout)
	ship_button.pressed.connect(sail)
	brush_button.pressed.connect(brush_it)
	bomb_button.pressed.connect(bomb_it)
	clover_button.pressed.connect(lucky)
	sunflower_button.pressed.connect(inflorescence)
	wallpaper_button.pressed.connect(screen_saver)
	twoclover_button.pressed.connect(lucky_twice)
	options_button.pressed.connect(open_other_menu)
	lily_button.pressed.connect(lily_me)
	
	left_button.pressed.connect(change_down)
	right_button.pressed.connect(change_up)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	transform()

func randomise():
	$"../..".randomising = true
	visible = false
	get_tree().paused = false

func erase():
	if not $"../..".deleting:
		$"../..".deleting = true

func change_up():
	if num == len($"../..".cell_type) - 1:
		pass
	else:
		num += 1

func change_down():
	if num == 0:
		pass
	else:
		num -= 1
		

func transform():
	var the_button = conway_buttons[num]
	var the_label = conway_labels[num]
	
	for button in conway_buttons:
		if button == the_button:
			button.visible = true
		else:
			button.visible = false
	
	for label in conway_labels:
		if label == the_label:
			label.visible = true
		else:
			label.visible = false

func cell():
	var what = $"../..".cell_type
	for n in len(what):
		if n == 0:
			what[n] = 1
		else:
			what[n] = 0
	$"../..".cell_type = what
	visible = false
	get_tree().paused = false

func climb():
	var what = $"../..".cell_type
	for n in len(what):
		if n == 1:
			what[n] = 1
		else:
			what[n] = 0
	$"../..".cell_type = what
	visible = false
	get_tree().paused = false

func hat_up():
	var what = $"../..".cell_type
	for n in len(what):
		if n == 2:
			what[n] = 1
		else:
			what[n] = 0
	$"../..".cell_type = what
	visible = false

func brush_it():
	var what = $"../..".cell_type
	for n in len(what):
		if n == 3:
			what[n] = 1
		else:
			what[n] = 0
	$"../..".cell_type = what
	visible = false
	get_tree().paused = false

func pulse():
	var what = $"../..".cell_type
	for n in len(what):
		if n == 4:
			what[n] = 1
		else:
			what[n] = 0
	$"../..".cell_type = what
	visible = false
	get_tree().paused = false

func blink():
	var what = $"../..".cell_type
	for n in len(what):
		if n == 5:
			what[n] = 1
		else:
			what[n] = 0
	$"../..".cell_type = what
	visible = false
	get_tree().paused = false

func sprout():
	var what = $"../..".cell_type
	for n in len(what):
		if n == 6:
			what[n] = 1
		else:
			what[n] = 0
	$"../..".cell_type = what
	visible = false
	get_tree().paused = false

func sail():
	var what = $"../..".cell_type
	for n in len(what):
		if n == 7:
			what[n] = 1
		else:
			what[n] = 0
	$"../..".cell_type = what
	visible = false
	get_tree().paused = false

func bomb_it():
	var what = $"../..".cell_type
	for n in len(what):
		if n == 8:
			what[n] = 1
		else:
			what[n] = 0
	$"../..".cell_type = what
	visible = false
	get_tree().paused = false

func lucky():
	var what = $"../..".cell_type
	for n in len(what):
		if n == 9:
			what[n] = 1
		else:
			what[n] = 0
	$"../..".cell_type = what
	visible = false
	get_tree().paused = false
	
func lucky_twice():
	var what = $"../..".cell_type
	for n in len(what):
		if n == 10:
			what[n] = 1
		else:
			what[n] = 0
	$"../..".cell_type = what
	visible = false
	get_tree().paused = false

func lily_me():
	var what = $"../..".cell_type
	for n in len(what):
		if n == 11:
			what[n] = 1
		else:
			what[n] = 0
	$"../..".cell_type = what
	visible = false
	get_tree().paused = false

func inflorescence():
	var what = $"../..".cell_type
	for n in len(what):
		if n == 12:
			what[n] = 1
		else:
			what[n] = 0
	$"../..".cell_type = what
	visible = false
	get_tree().paused = false

func screen_saver():
	$"../..".wally = !$"../..".wally
	if $"../..".wally:
		$"../..".wally_generation = 48
		$"../..".running = true
		for x in $"../..".width:
			for y in $"../..".height:
				$"../..".my_field[x][y] = 0
	visible = false
	get_tree().paused = false

func shadow_me(toggled_on: bool):
	$"../..".shadowing = toggled_on

func symmetry_me(toggled_on: bool):
	$"../..".symmetrical = toggled_on

func open_other_menu():
	visible = false
	$"../../CanvasLayer3/Menu3".visible = true
