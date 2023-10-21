class_name Level extends TileMap

const FIRE_LAYER = 2
const BLOCK_LAYER = 1
# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# subtract delta time from each tile's life remaining
	var fire_cells = get_used_cells(FIRE_LAYER)
	for cell in fire_cells:
		var data = get_cell_tile_data(FIRE_LAYER, cell)
		var life = data.get_custom_data("life") - delta
		if life > 0:
			data.set_custom_data("life", life)
		else:
			set_cell(FIRE_LAYER, cell) # erase cell
			
func process_cell(pos: Vector2i):
	var current_tile = get_cell_tile_data(BLOCK_LAYER, pos)
	if (current_tile == null):
		return 0
	if current_tile.get_custom_data("breakable"):
		set_cell(BLOCK_LAYER, Vector2i(pos.x, pos.y)) # erase cell
		return 1
	else:
		return 2

func explode(pos: Vector2i, length: int):
	var explosion_tiles: Array[Vector2i]
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
	for cell in explosion_tiles:
		var data = get_cell_tile_data(FIRE_LAYER, cell)
		data.set_custom_data("life", 0.4)
