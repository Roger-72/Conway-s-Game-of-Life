extends Panel

@onready var back_button = $BackButton
@onready var symmetry_button = $SymmetryButton
@onready var shadow_button = $ShadowButton
@onready var layers_label = $LayersLabel
@onready var layers_button = $LayersButton
@onready var type_label = $TypeLabel
@onready var type_button = $TypeButton
@onready var colour1_label = $ColourLabel1
@onready var colour1_button = $ColourButton1
@onready var colour2_label = $ColourLabel2
@onready var colour2_button = $ColourButton2
@onready var colour3_label = $ColourLabel3
@onready var colour3_button = $ColourButton3
@onready var colour4_label = $ColourLabel4
@onready var colour4_button = $ColourButton4
@onready var colour5_label = $ColourLabel5
@onready var colour5_button = $ColourButton5

var my_layers = 1
var type_away = 'User Arranged'
var my_colours = ['Violet', 'Blue', 'Green', 'Yellow', 'Red']
var my_col_nums = [6,3,2,5,4]
var colour_buttons
var colour_labels

func _ready():
	
	back_button.text = 'Back'
	back_button.add_theme_font_size_override("font_size", 20)
	back_button.size = Vector2(100, 40)
	back_button.position = Vector2(270, 470)
	
	symmetry_button.text = 'Wallpaper
	Symmetry   '
	symmetry_button.add_theme_font_size_override("font_size", 22)
	symmetry_button.position = Vector2(400, 50)
	
	shadow_button.text = 'Shadow'
	shadow_button.add_theme_font_size_override("font_size", 22)
	shadow_button.position = Vector2(90, 65)
	
	layers_label.position = Vector2(90 , 180)
	layers_label.text = "Select Layers 
	of Shadow"
	layers_label.add_theme_font_size_override("font_size", 22)
	layers_label.visible = false
	
	layers_button.position = Vector2(90, 250)
	layers_button.visible = false
	layers_button.add_item("1 Layer")
	layers_button.add_item("2 Layers")
	layers_button.add_item("3 Layers")
	layers_button.add_item("4 Layers")
	layers_button.add_item("5 Layers")
	layers_button.select(0)
	
	type_label.position = Vector2(90 , 330)
	type_label.text = "Chromophoric
	Effect"
	type_label.add_theme_font_size_override("font_size", 22)
	type_label.visible = false
	
	type_button.position = Vector2(90, 400)
	type_button.visible = false
	type_button.add_item('User Arranged')
	type_button.add_item('Spectrum')
	type_button.add_item('Inverse Spectrum')
	type_button.add_item('Kaleidoscopic')
	type_button.select(0)
	
	colour1_label.position = Vector2(400 , 200)
	colour1_label.text = "Colour 1"
	colour1_label.add_theme_font_size_override("font_size", 22)
	colour1_button.position = Vector2(500, 200)
	
	colour2_label.position = Vector2(400 , 250)
	colour2_label.text = "Colour 2"
	colour2_label.add_theme_font_size_override("font_size", 22)
	colour2_button.position = Vector2(500, 250)
	
	colour3_label.position = Vector2(400 , 300)
	colour3_label.text = "Colour 3"
	colour3_label.add_theme_font_size_override("font_size", 22)
	colour3_button.position = Vector2(500, 300)
	
	colour4_label.position = Vector2(400 , 350)
	colour4_label.text = "Colour 4"
	colour4_label.add_theme_font_size_override("font_size", 22)
	colour4_button.position = Vector2(500, 350)
	
	colour5_label.position = Vector2(400 , 400)
	colour5_label.text = "Colour 5"
	colour5_label.add_theme_font_size_override("font_size", 22)
	colour5_button.position = Vector2(500, 400)
	
	colour_buttons = [colour1_button, colour2_button, colour3_button, colour4_button, colour5_button]
	colour_labels = [colour1_label, colour2_label, colour3_label, colour4_label, colour5_label]
	
	for button in colour_buttons:
		for colour in my_colours:
			button.add_item(colour)
		button.select(0)
		button.visible = false
	
	for label in colour_labels:
		label.visible = false

	
	back_button.pressed.connect(go_back)
	symmetry_button.toggled.connect(symmetry_me)
	shadow_button.toggled.connect(shadow_me)
	layers_button.item_selected.connect(layer_me)
	type_button.item_selected.connect(type_me)
	for button in colour_buttons:
		button.item_selected.connect(sauce_me)
	
	layers_button.select(0)
	colour1_button.select(0)
	sauce_me()

func _process(delta):
	pass

func go_back():
	visible = false
	$"../../CanvasLayer/Menu".visible = true
	sauce_me()

func symmetry_me(toggle_on: bool):
	if toggle_on:
		$"../..".symmetrical = true
	else:
		$"../..".symmetrical = false
	sauce_me()

func shadow_me(toggle_on: bool):
	if toggle_on:
		$"../..".shadowing = true
		layers_button.visible = true
		layers_label.visible = true
		type_button.visible = true
		type_label.visible = true
	else:
		$"../..".shadowing = false
		my_layers = 0
		layers_button.visible = false
		layers_label.visible = false
		type_button.visible = false
		type_label.visible = false
		my_layers = layers_button.selected + 1
		for x in $"../..".width:
			for y in $"../..".height:
				if $"../..".my_field[x][y] != 1:
					$"../..".my_field[x][y] = 0
	
	sauce_me()
	
func layer_me(index):
	if index!= -1 and $"../..".shadowing:
		my_layers = index + 1
		
	sauce_me()

func type_me(index):
	if index != -1 and $"../..".shadowing:
		if index == 0:
			type_away = 'User Arranged'
		elif index == 1:
			type_away = 'Spectrum'
		elif index == 2:
			type_away = 'Inverse Spectrum'
		else:
			type_away = 'Kaleidoscopic'
			
	sauce_me()

func sauce_me(_index=0):
	
	if $"../..".shadowing:
		for n in range(len(colour_buttons)):
			if n < my_layers:
				colour_buttons[n].visible = true
				colour_labels[n].visible = true
			else:
				colour_buttons[n].visible = false
				colour_labels[n].visible = false
	else:
		for button in colour_buttons:
			button.visible = false
		for label in colour_labels:
			label.visible = false
	
	
	if type_away == 'Spectrum' and my_layers > 0:
		for value in range(my_layers):
			var colour = value
			colour_buttons[value].select(colour)
	elif type_away == 'Inverse Spectrum' and my_layers > 0:
		for value in range(my_layers):
			var colour = len(my_colours) - value - 1
			colour_buttons[value].select(colour)
	elif type_away == 'Kaleidoscopic':
		$"../..".ninjas = [2,3,4,5,6]
		$"../..".ninja_type = type_away
		$"../..".ninja_layers = my_layers
	
		return 1
			
	
	var result = []
	if my_layers > 0:
		for value in range(my_layers):
			var selected_index = colour_buttons[value].selected
			if selected_index != -1:
				var colour = colour_buttons[value].get_item_text(selected_index)
				if colour == 'Green':
					result.append(2)
				elif colour == 'Blue':
					result.append(3)
				elif colour == 'Red':
					result.append(4)
				elif colour == 'Yellow':
					result.append(5)
				elif colour == 'Violet':
					result.append(6)
	
	var sequence = []
	for num in result:
		if num not in sequence:
			sequence.append(num)
		else:
			var looping = true
			var new_num = 2
			while looping:
				if new_num not in sequence:
					sequence.append(new_num)
					looping = false
				else:
					new_num += 1
	for n in range(my_layers):
		for m in range(len(my_col_nums)):
			if sequence[n] == my_col_nums[m]:
				colour_buttons[n].select(m)
				
	$"../..".ninjas = sequence
	$"../..".ninja_type = type_away
