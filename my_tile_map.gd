extends TileMapLayer

const TILE_SIZE = 64

# Field size
const field_size = 5.5  #min=2 Max=&
const win_width = 1152
const win_height = 648
var width = int(win_width / TILE_SIZE) * field_size
var height = int(win_height / TILE_SIZE) * field_size
var width_px = width * TILE_SIZE
var height_px = height * TILE_SIZE
const OFFSETS = [-1, 0, 1]

# Is it running / randomising?
var running = false
var randomising = false
var deleting = false
var click = false
var mousey = false
var wally = false
var wally_generation = 48
var shadowing = false
var symmetrical = false
var ninjas = []
var ninja_type = ''
var ninja_layers = 1
var kaleido = 0
var direction = 'Right'
var cell_type = [1,0,0,0,0,0,0,0,0,0,0,0,0,0]
var reset = true

var update_timer = 0.0
var update_interval = 0.05  # Default speed
var speed_multiplier = 1

# The field
var my_field = []
var new_field = []

@onready var cam = $Camera2D
@onready var menu = $CanvasLayer/Menu
@onready var menu2 = $CanvasLayer2/Menu2
@onready var menu3 = $"CanvasLayer3/Menu3"
@onready var my_dialog = $MyAcceptDialog
func _ready():
	
	my_dialog.dialog_text = "This program is a version of Conway's Game of Life that I have created for fun. 
	
	It comes with some pre-set shapes to play around with, and a function I call 'Wallpaper' that allows you to set your screen running the game autonomously.
	
	To access the menu, press M. To change the direction of your selected structures, use the W,A,S, and D keys for Up, Left, Down, and Right directions respectively. To set your cells' field run amok, simply press the Spacebar, and press it again to stop it. The 'Wallpaper' function initialises automatically once pressed, and there's no need to press the Spacebar to initialise it. Only press the Spacebar to stop it. To re-initialise this 'Wallpaper' function, you have to select it again from the menu.
	
	Try the 'Shadow' setting for a more epileptic experience haha
	
	Enjoy! - Roger Nicolau"
	
	my_dialog.title = "Welcome!"
	my_dialog.dialog_autowrap = true
	my_dialog.min_size = Vector2(850,0)
	
	my_dialog.popup_centered()
	my_dialog.position.y = 70
	
	process_mode = Node.PROCESS_MODE_ALWAYS
	menu.process_mode = Node.PROCESS_MODE_DISABLED
	menu3.process_mode = Node.PROCESS_MODE_DISABLED
	
	menu.size = Vector2(width_px*0.15,height_px*0.15)
	menu.position = ((get_viewport_rect().size / 2) - (menu.size / 2))
	menu.visible = false
	
	menu2.size = Vector2((width_px*0.0075*2),width_px*0.0075)
	var screen = get_viewport_rect().size
	menu2.position = screen - menu2.size - Vector2(20, 20)
	
	menu3.size = Vector2(width_px*0.10,height_px*0.15)
	menu3.position = ((get_viewport_rect().size / 2) - (menu3.size / 2))
	menu3.visible = false

	cam.make_current()
	cam.position = Vector2(width_px / 2.0, height_px / 2.0)
	var viewport_size = get_viewport_rect().size
	var zoom_x = viewport_size.x / float(width_px)
	var zoom_y = viewport_size.y / float(height_px)
	var zoom = min(zoom_x, zoom_y)
	cam.zoom = Vector2(zoom, zoom)*1.012
	
	for x in range(width):
		var line = []
		for y in range(height):
			var cell = 0
			line.append(cell)
			set_cell(Vector2i(x,y), cell, Vector2i(0,0))
		my_field.append(line)
		new_field.append(line)

func _process(delta):
	if randomising:
		randomising = false
		randomise()
	
	if running:
		if reset:
			reset = false
			for x in width:
				for y in height:
					set_cell(Vector2i(x,y),my_field[x][y],Vector2i(0,0))
		update_timer += delta * speed_multiplier  # Apply speed multiplier
		if update_timer >= update_interval:
			update_timer = 0.0
			
			if running and wally:
				$CanvasLayer2/Menu2/RunButton.texture_normal = load("res://W2.png")
				run_field()
			elif running:
				run_field()
				$CanvasLayer2/Menu2/RunButton.texture_normal = load("res://run.png")
	else:
		$CanvasLayer2/Menu2/RunButton.texture_normal = load("res://pause.png")
		reset = true
	
	if deleting:
		deleting = false
		delete_it()
	
	if click and not running:
		click = false
		charon_cell(1)
	elif menu.visible == true or menu3.visible:
		for x in width:
			for y in height:
				set_cell(Vector2(x,y), my_field[x][y], Vector2(0,0))
	elif not running:
		charon_cell()


func _input(event):
	mousey = false
	if get_local_mouse_position()[0] >= 0 and get_local_mouse_position()[0] < width_px and get_local_mouse_position()[1] >= 0 and get_local_mouse_position()[1] < height_px:
		mousey = true
	if menu.visible or menu3.visible:
		if event.is_action_pressed("M_button"):
			menu.visible = false
			menu3.visible = false
			get_tree().paused = false
		return
	if event.is_action_pressed("Toggle_play"):
		if wally and running:
			wally = false
			running = false
			cell_type = [1,0,0,0,0,0,0,0,0,0,0,0,0,0]
		else:
			running = !running
		if not running:
			for x in width:
				for y in height:
					if my_field[x][y] != 1:
						my_field[x][y] = 0
	if event.is_action_pressed("M_button") and running == false:
		menu.visible = !menu.visible
		if menu.visible or menu3.visible:
			get_tree().paused = true
			menu.process_mode = Node.PROCESS_MODE_ALWAYS
			menu3.process_mode = Node.PROCESS_MODE_ALWAYS
		else:
			get_tree().paused = false
			menu.process_mode = Node.PROCESS_MODE_DISABLED
			menu3.process_mode = Node.PROCESS_MODE_DISABLED
			
	if event.is_action_pressed('Up'):
		direction = 'Up'
		$CanvasLayer2/Menu2/DirectionButton.texture_normal = load("res://u.png")
	if event.is_action_pressed('Down'):
		direction = 'Down'
		$CanvasLayer2/Menu2/DirectionButton.texture_normal = load("res://d.png")
	if event.is_action_pressed('Right'):
		direction = 'Right'
		$CanvasLayer2/Menu2/DirectionButton.texture_normal = load("res://r.png")
	if event.is_action_pressed('Left'):
		direction = 'Left'
		$CanvasLayer2/Menu2/DirectionButton.texture_normal = load("res://l.png")
		
	if event.is_action_pressed("Click") and running == false:
		if mousey:
			click = true
	
	if event.is_action_pressed('Print_it'):
		print_me()
	
	
	
func print_me():
	var origin = Vector2i(width, height)
	var destine = Vector2i(0, 0)

	for x in range(width):
		for y in range(height):
			if my_field[x][y] == 1:
				origin.x = min(origin.x, x)
				origin.y = min(origin.y, y)
				destine.x = max(destine.x, x)
				destine.y = max(destine.y, y)

	var result = []

	for y in range(origin.y, destine.y + 1):
		var row = []
		for x in range(origin.x, destine.x + 1):
			row.append(my_field[x][y])
		result.append(row)

	print(result)					
			


func randomise():
	
	new_field = []
	for x in  range(width):
		var line = []
		for y in range(height):
			var cell = randi_range(0,1)
			set_cell(Vector2i(x,y), cell, Vector2i(0,0))
			line.append(cell)
		new_field.append(line)
	
	my_field = new_field
	cell_type = [1,0,0,0,0,0,0,0,0,0,0,0,0]


func run_field():
	
	if wally:
		wally_generation += 1
	if wally_generation == 50:
		wally_generation = 0
		
		var location = [randi_range(2,48), randi_range(1,54)]
		if not symmetrical:
			location = [randi_range(2,98), randi_range(1,54)]
			
		var dire = ['Up', 'Down', 'Left', 'Right']
		
		var my_forms = [4,6,8,9,10,11,12]
		var my_numy2 = randi_range(0,5)
		for i in range(my_numy2):
			var my_numy = randi_range(0,5)
			var numy = my_forms[my_numy]
			for n in len(cell_type):
				if n == numy:
					cell_type[n] = 1
				else:
					cell_type[n] = 0
			direction = dire[randi_range(0,3)]
			if not symmetrical:
				location = [randi_range(5,95), randi_range(5,50)]
				charon_cell(1, location, true)
			else:
				location = [randi_range(5,45), randi_range(5,50)]
				charon_cell(1, location, true)
		if symmetrical:
			for y in height:
				var numerito = 48
				for x in range(50,99):
					my_field[x][y] = my_field[numerito][y]
					numerito -= 1
	
	
	new_field = []
	for x in range(width):
		var line = []
		
		for y in range(height):
			var alive_neighbours = 0
			
			# Count neighbours
			for x_off in OFFSETS:
				for y_off in OFFSETS:
					if x_off == 0 and y_off == 0:
						continue

					var nx = x + x_off
					var ny = y + y_off

					if nx >= 0 and nx < width and ny >= 0 and ny < height and my_field[nx][ny] == 1:
						alive_neighbours += 1
			
			
			# Apply Game of Life rules
			var old_cell = my_field[x][y]
			var cell = old_cell
			var should_cell_alive = false
			
			if old_cell == 1:
				if alive_neighbours in [2,3]:
					should_cell_alive = true
			else:
				if alive_neighbours == 3:
					should_cell_alive = true
			
			
			
			if should_cell_alive == true:
				cell = 1
			else:
				if shadowing and len(ninjas) > 0:
					# Check if the old cell was a shadow
					var is_shadow = false
					var shadow_index = -1
					for n in range(len(ninjas)):
						if old_cell == ninjas[n]:
							is_shadow = true
							shadow_index = n
							break
					if old_cell == 1:
						# Cell just died - start shadow with first colour
						cell = ninjas[0]
					elif is_shadow:
						# Cell is already a shadow - progress to next colour
						if shadow_index < len(ninjas) - 1:
							cell = ninjas[shadow_index + 1]
						else:
							# Last shadow - disappear
							cell = 0
					else:
						# Dead cell with no shadow
						cell = 0
				
				else:
					# No shadowing or no ninjas
					cell = 0
			
			
			line.append(cell)
			
			if old_cell != cell:
				if ninja_type == 'Kaleidoscopic' and cell not in [0,1]:
					if cell <= 1 + ninja_layers:
						set_cell(Vector2(x,y), ninjas[kaleido], Vector2(0,0))
					else:
						cell = 0
						set_cell(Vector2(x,y), cell, Vector2(0,0))
				else:
					set_cell(Vector2(x,y), cell, Vector2(0,0))
					
					
			
		new_field.append(line)
	my_field = new_field
	
	
	if ninja_type == 'Kaleidoscopic':
		kaleido += 1
		if kaleido >= len(ninjas):
			kaleido = 0

func delete_it():
	
	for x in width:
		for y in height:
			set_cell(Vector2i(x,y), 0, Vector2i(0,0))
			my_field[x][y] = 0


func charon_cell(light=2, my_mouse=get_local_mouse_position(), loc=false):
	var cells = []
	for x in width:
		for y in height:
			set_cell(Vector2(x,y), my_field[x][y], Vector2(0,0))
	var x
	var y
	if loc:
		x = my_mouse[0]
		y = my_mouse[1]
	else:
		x = int(floor(my_mouse[0]/TILE_SIZE))
		y = int(floor(my_mouse[1]/TILE_SIZE))
	
	if cell_type[0]:
		if light == 1:
			if my_field[x][y]:
				set_cell(Vector2i(x,y), 0, Vector2i(0,0))
				my_field[x][y] = 0
			else:
				set_cell(Vector2i(x,y), 1, Vector2i(0,0))
				my_field[x][y] = 1
				
		elif light == 2:
			set_cell(Vector2i(x,y), 2, Vector2i(0,0))
			
	else:
		if cell_type[1]:
			if direction == 'Right':
				cells = [
					[0,1,0],
					[0,0,1],
					[1,1,1]]
			elif direction == 'Down':
				cells = [
					[1,0,0],
					[1,0,1],
					[1,1,0]]
			elif direction == 'Left':
				cells = [
					[1,1,1],
					[1,0,0],
					[0,1,0]]
			elif direction == 'Up':
				cells = [
					[0,1,1],
					[1,0,1],
					[0,0,1]]
			
		elif cell_type[2]:
			if direction == 'Up':
				cells = [[0,1,0],[1,1,1]]
			elif direction == 'Down':
				cells = [[1,1,1],[0,1,0]]
			elif direction == 'Right':
				cells = [[1,0],[1,1],[1,0]]
			elif direction == 'Left':
				cells = [[0,1],[1,1],[0,1]]
		
		elif cell_type[3]:
			cells = [[0,0,0],[0,0,0],[0,0,0]]
				
		elif cell_type[4]:
			cells = [
				[0,0,0,0,1,0,0,0,0,0,1,0,0,0,0],
				[0,0,0,0,1,0,0,0,0,0,1,0,0,0,0],
				[0,0,0,0,1,1,0,0,0,1,1,0,0,0,0],
				[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
				[1,1,1,0,0,1,1,0,1,1,0,0,1,1,1],
				[0,0,1,0,1,0,1,0,1,0,1,0,1,0,0],
				[0,0,0,0,1,1,0,0,0,1,1,0,0,0,0],
				[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
				[0,0,0,0,1,1,0,0,0,1,1,0,0,0,0],
				[0,0,1,0,1,0,1,0,1,0,1,0,1,0,0],
				[1,1,1,0,0,1,1,0,1,1,0,0,1,1,1],
				[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
				[0,0,0,0,1,1,0,0,0,1,1,0,0,0,0],
				[0,0,0,0,1,0,0,0,0,0,1,0,0,0,0],
				[0,0,0,0,1,0,0,0,0,0,1,0,0,0,0],
			]
			
		elif cell_type[5]:
			if direction == 'Up' or direction == 'Down':
				cells = [
					[1,1,1],
					[1,0,1],
					[1,1,1],
					[1,1,1],
					[1,1,1],
					[1,1,1],
					[1,0,1],
					[1,1,1],
				]
				
			else:
				cells = [
					[1,1,1,1,1,1,1,1],
					[1,0,1,1,1,1,0,1],
					[1,1,1,1,1,1,1,1],
				]
		elif cell_type[8]:
			cells = [
				[0,0,0,1,1,1,0,0,0],
				[0,0,0,0,1,0,0,0,0],
				[0,0,0,0,0,0,0,0,0],
				[1,0,0,0,1,0,0,0,1],
				[1,1,0,1,0,1,0,1,1],
				[1,0,0,0,1,0,0,0,1],
				[0,0,0,0,0,0,0,0,0],
				[0,0,0,0,1,0,0,0,0],
				[0,0,0,1,1,1,0,0,0],
			]
			
		elif cell_type[7]:
			if direction == 'Up':
				cells = [
					[0,0,0,0,1,1,0,0,1,1,0,0,0,0],
					[0,0,0,0,0,0,1,1,0,0,0,0,0,0],
					[0,0,0,0,0,0,1,1,0,0,0,0,0,0],
					[0,0,0,1,0,1,0,0,1,0,1,0,0,0],
					[0,0,0,1,0,0,0,0,0,0,1,0,0,0],
					[0,0,0,0,0,0,0,0,0,0,0,0,0,0],
					[0,0,0,1,0,0,0,0,0,0,1,0,0,0],
					[0,0,0,0,1,1,0,0,1,1,0,0,0,0],
					[0,0,0,0,0,1,1,1,1,0,0,0,0,0],
					[0,0,0,0,0,0,0,0,0,0,0,0,0,0],
					[0,0,0,0,0,0,1,1,0,0,0,0,0,0],
					[0,0,0,0,0,0,1,1,0,0,0,0,0,0],
				]
			elif direction == "Right":
				cells = [
					[0,0,0,0,0,0,0,0,0,0,0,0],
					[0,0,0,0,0,0,0,0,0,0,0,0],
					[0,0,0,0,0,0,0,0,0,0,0,0],
					[0,0,0,0,0,1,0,1,1,0,0,0],
					[0,0,0,0,1,0,0,0,0,0,0,1],
					[0,0,0,1,1,0,0,0,1,0,0,1],
					[1,1,0,1,0,0,0,0,0,1,1,0],
					[1,1,0,1,0,0,0,0,0,1,1,0],
					[0,0,0,1,1,0,0,0,1,0,0,1],
					[0,0,0,0,1,0,0,0,0,0,0,1],
					[0,0,0,0,0,1,0,1,1,0,0,0],
					[0,0,0,0,0,0,0,0,0,0,0,0],
					[0,0,0,0,0,0,0,0,0,0,0,0],
					[0,0,0,0,0,0,0,0,0,0,0,0],
				]
			elif direction == "Down":
				cells = [
					[0,0,0,0,0,0,1,1,0,0,0,0,0,0],
					[0,0,0,0,0,0,1,1,0,0,0,0,0,0],
					[0,0,0,0,0,0,0,0,0,0,0,0,0,0],
					[0,0,0,0,0,1,1,1,1,0,0,0,0,0],
					[0,0,0,0,1,1,0,0,1,1,0,0,0,0],
					[0,0,0,1,0,0,0,0,0,0,1,0,0,0],
					[0,0,0,0,0,0,0,0,0,0,0,0,0,0],
					[0,0,0,1,0,0,0,0,0,0,1,0,0,0],
					[0,0,0,1,0,1,0,0,1,0,1,0,0,0],
					[0,0,0,0,0,0,1,1,0,0,0,0,0,0],
					[0,0,0,0,0,0,1,1,0,0,0,0,0,0],
					[0,0,0,0,1,1,0,0,1,1,0,0,0,0],
				]
			elif direction == "Left":
				cells = [
					[0,0,0,0,0,0,0,0,0,0,0,0],
					[0,0,0,0,0,0,0,0,0,0,0,0],
					[0,0,0,0,0,0,0,0,0,0,0,0],
					[0,0,0,1,1,0,1,0,0,0,0,0],
					[1,0,0,0,0,0,0,1,0,0,0,0],
					[1,0,0,1,0,0,0,1,1,0,0,0],
					[0,1,1,0,0,0,0,0,1,0,1,1],
					[0,1,1,0,0,0,0,0,1,0,1,1],
					[1,0,0,1,0,0,0,1,1,0,0,0],
					[1,0,0,0,0,0,0,1,0,0,0,0],
					[0,0,0,1,1,0,1,0,0,0,0,0],
					[0,0,0,0,0,0,0,0,0,0,0,0],
					[0,0,0,0,0,0,0,0,0,0,0,0],
					[0,0,0,0,0,0,0,0,0,0,0,0],
				]
		
		elif cell_type[6]:
			cells = [
				[0,0,0,0,0,0,1,0,0,0,0,0,0],
				[0,0,0,0,0,1,0,1,0,0,0,0,0],
				[0,0,0,0,0,1,1,1,0,0,0,0,0],
				[0,0,0,0,0,0,1,0,0,0,0,0,0],
				[0,0,0,0,0,0,0,0,0,0,0,0,0],
				[0,1,1,0,0,0,0,0,0,0,1,1,0],
				[1,0,1,1,0,0,0,0,0,1,1,0,1],
				[0,1,1,0,0,0,0,0,0,0,1,1,0],
				[0,0,0,0,0,0,0,0,0,0,0,0,0],
				[0,0,0,0,0,0,1,0,0,0,0,0,0],
				[0,0,0,0,0,1,1,1,0,0,0,0,0],
				[0,0,0,0,0,1,0,1,0,0,0,0,0],
				[0,0,0,0,0,0,1,0,0,0,0,0,0]
			]
		
		elif cell_type[9]:
			cells = [
				[0,0,0,0,0,0,1,0,0,0,0,0,0],
				[0,0,0,0,0,1,1,1,0,0,0,0,0],
				[0,0,0,0,0,1,0,1,0,0,0,0,0],
				[0,0,0,0,0,0,1,0,0,0,0,0,0],
				[0,0,0,0,0,0,0,0,0,0,0,0,0],
				[0,1,1,0,0,0,0,0,0,0,1,1,0],
				[1,1,0,1,0,0,0,0,0,1,0,1,1],
				[0,1,1,0,0,0,0,0,0,0,1,1,0],
				[0,0,0,0,0,0,0,0,0,0,0,0,0],
				[0,0,0,0,0,0,1,0,0,0,0,0,0],
				[0,0,0,0,0,1,0,1,0,0,0,0,0],
				[0,0,0,0,0,1,1,1,0,0,0,0,0],
				[0,0,0,0,0,0,1,0,0,0,0,0,0]
			]
		
		elif cell_type[10]:
			if direction == 'Up' or direction == 'Down':
				cells = [
					[0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0], 
					[0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0], 
					[0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0], 
					[0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0], 
					[0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0], 
					[0, 1, 1, 0, 0, 1, 1, 1, 0, 0, 1, 1, 0], 
					[1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1], 
					[0, 1, 1, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0], 
					[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 
					[0, 1, 1, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0], 
					[1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1], 
					[0, 1, 1, 0, 0, 1, 1, 1, 0, 0, 1, 1, 0], 
					[0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0], 
					[0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0], 
					[0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0], 
					[0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0], 
					[0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0]
				]
			
			else:
				cells = [
					[0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0],
					[0, 0, 0, 0, 0, 1, 1, 1, 0, 1, 1, 1, 0, 0, 0, 0, 0],
					[0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0],
					[0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0],
					[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
					[0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 1, 1, 0],
					[1, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 1],
					[0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 1, 1, 0],
					[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
					[0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0],
					[0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0],
					[0, 0, 0, 0, 0, 1, 1, 1, 0, 1, 1, 1, 0, 0, 0, 0, 0],
					[0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0]
				]

		elif cell_type[12]:
			cells = [
				[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 
				[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 
				[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 
				[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 
				[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 
				[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 
				[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 
				[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 
				[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 
				[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 
				[0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0], 
				[0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0], 
				[0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0], 
				[0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0], 
				[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 0, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 
				[1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1], 
				[1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1], 
				[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 
				[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 
				[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 
				[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 
				[0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0], 
				[0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0], 
				[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 0, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 0, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 
				[0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0], 
				[0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0], 
				[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 
				[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 
				[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 
				[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 
				[1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1], 
				[1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1], 
				[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 0, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 
				[0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0], 
				[0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0], 
				[0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0], 
				[0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0], 
				[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 
				[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 
				[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 
				[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 
				[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 
				[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 
				[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 
				[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 
				[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 
				[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
			]
		
		elif cell_type[11]:
			cells = [
				[0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0], 
				[0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0], 
				[0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0], 
				[0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0], 
				[0, 0, 0, 0, 0, 1, 0, 1, 1, 1, 0, 1, 0, 0, 0, 0, 0], 
				[0, 0, 0, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 0, 0, 0], 
				[0, 0, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 0, 0], 
				[0, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 1, 1, 1, 1, 1, 0], 
				[1, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 1], 
				[0, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 1, 1, 1, 1, 1, 0], 
				[0, 0, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 0, 0], 
				[0, 0, 0, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 0, 0, 0], 
				[0, 0, 0, 0, 0, 1, 0, 1, 1, 1, 0, 1, 0, 0, 0, 0, 0], 
				[0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0], 
				[0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0], 
				[0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0], 
				[0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0]
			]
		
		var heighty = cells.size()
		var widthy = cells[0].size()

		var half_width = int(widthy / 2)
		var half_height = int(heighty / 2)

		var rangy_x = range(-half_width, widthy - half_width)
		var rangy_y = range(-half_height, heighty - half_height)
		
		for x_off in rangy_x:
			for y_off in rangy_y:
				var nx = x + x_off
				var ny = y + y_off

				if nx < 0 or nx >= width or ny < 0 or ny >= height:
					continue
					
				var x_offset = cells[0].size() / 2
				var y_offset = cells.size() / 2

				var value = cells[y_off + y_offset][x_off + x_offset]
				
				if cell_type[3]:
					if light == 1:
						set_cell(Vector2i(nx, ny), value, Vector2i.ZERO)
						my_field[nx][ny] = value
					elif light == 2:
						set_cell(Vector2i(nx, ny), 2, Vector2i.ZERO)
				elif light == 1 and value == 1:
					set_cell(Vector2i(nx, ny), value, Vector2i.ZERO)
					my_field[nx][ny] = value
				elif light == 2 and value == 1:
					if value == 1:
						value = 2
					set_cell(Vector2i(nx, ny), value, Vector2i.ZERO)
	
