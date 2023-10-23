class_name Level extends TileMap

const FIRE_LAYER = 2
const BLOCK_LAYER = 1
const POST_TILE_COORD = Vector2i(3, 0)
const BRICK_TILE_COORD = Vector2i(2, 0)
const LEVEL_WIDTH = 12
const LEVEL_HEIGHT = 10

@export var fire_life = 200.0

@export var broken_brick_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	generate_level()
	
func generate_level():
	const brick_chance = .55
	const half_width = LEVEL_WIDTH / 2 + 1
	const half_height = LEVEL_HEIGHT / 2 + 1
	const start_cavity_length = 3
	var num_bricks = int(brick_chance * half_height * half_width)
	var available_cells: Array[Vector2i] = []
	var used_cells: Array[Vector2i] = []
	
	for y in range(0, half_height):
		for x in range(0, half_width):
			if (
				not(x == 0 and y < start_cavity_length) and 
				not(y == 0 and x < start_cavity_length) and
				not((x + 1) % 2 == 0 and (y + 1) % 2 == 0)
				):
				print(str(x) + " " + str(y))
				available_cells.append(Vector2i(x, y))
	
	while num_bricks > 0 and available_cells.size() > 0:
		num_bricks -= 1
		used_cells.append(available_cells.pop_at(randi_range(0, available_cells.size() - 1)))
	
	for cell in used_cells:
		set_cell(BLOCK_LAYER, cell, 2, BRICK_TILE_COORD)
		set_cell(BLOCK_LAYER, Vector2i(LEVEL_WIDTH - cell.x, cell.y), 2, BRICK_TILE_COORD)
		set_cell(BLOCK_LAYER, Vector2i(cell.x, LEVEL_HEIGHT - cell.y), 2, BRICK_TILE_COORD)
		set_cell(BLOCK_LAYER, Vector2i(LEVEL_WIDTH - cell.x, LEVEL_HEIGHT - cell.y), 2, BRICK_TILE_COORD)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# subtract delta time from each tile's life remaining
	var fire_cells = get_used_cells(FIRE_LAYER)
	var time = Time.get_ticks_msec()
	for cell in fire_cells:
		var data = get_cell_tile_data(FIRE_LAYER, cell)
		var life = time - data.get_custom_data("start")
		if life > fire_life:
			set_cell(FIRE_LAYER, cell) # erase cell
			
func _unhandled_input(event):
	if event is InputEventMouseButton and event.is_pressed():
		print(local_to_map(to_local(get_global_mouse_position())))
		print()
			
func process_cell(pos: Vector2i):
	var current_tile = get_cell_tile_data(BLOCK_LAYER, pos)
	if (current_tile == null):
		return 0
	if current_tile.get_custom_data("breakable"):
		set_cell(BLOCK_LAYER, Vector2i(pos.x, pos.y)) # erase cell
		var brick = broken_brick_scene.instantiate()
		brick.position = map_to_local(pos)
		add_child(brick)
		return 1
	else:
		return 2

func explode(pos: Vector2i, length: int):
	var explosion_tiles: Array[Vector2i] = []
	explosion_tiles.append(pos)
	for x in range(1, length):
		var current_pos = Vector2i(pos.x - x, pos.y)
		if process_cell(current_pos) == 0: 
			explosion_tiles.append(current_pos)
		else: break
	
	for x in range(1, length):
		var current_pos = Vector2i(pos.x + x, pos.y)
		if process_cell(current_pos) == 0: 
			explosion_tiles.append(current_pos)
		else: break
	
	for y in range(1, length):
		var current_pos = Vector2i(pos.x, pos.y - y)
		if process_cell(current_pos) == 0: 
			explosion_tiles.append(current_pos)
		else: break
	
	for y in range(1, length):
		var current_pos = Vector2i(pos.x, pos.y + y)
		if process_cell(current_pos) == 0: 
			explosion_tiles.append(current_pos)
		else: break
	
	set_cells_terrain_connect(FIRE_LAYER, explosion_tiles, 0, 0)
	var time = Time.get_ticks_msec()
	for cell in explosion_tiles:
		var data = get_cell_tile_data(FIRE_LAYER, cell)
		data.set_custom_data("start", time)
