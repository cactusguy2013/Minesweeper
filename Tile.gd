extends Node2D

var number #It's number underneath but being a mine is 9 and a blank is 0
var flagged  = false setget set_flagged
var revealed = false

signal clicked(index)
signal tile_updated()
signal game_over()

onready var sprite = $Sprite

func init(x, y, num):
	number = num
	global_position = Vector2(x,y)
	sprite.frame = 10 #The unrevealed tile image
	var scale = Global.tile_size/40.0
	sprite.scale = Vector2(scale,scale)

func _process(delta: float) -> void:
	var mousePos = get_local_mouse_position()
	#For debugging
	if mousePos.x >= 0 and mousePos.x < Global.tile_size and mousePos.y >= 0 and mousePos.y < Global.tile_size and Input.is_action_just_released("ui_select"):
		emit_signal("clicked", get_position_in_parent())
	
	if !Global.game_running:
		return
	
	if mousePos.x >= 0 and mousePos.x < Global.tile_size and mousePos.y >= 0 and mousePos.y < Global.tile_size:
		if Input.is_action_just_released("clear"):
			if number == 9 and !flagged:
				Global.game_running = false
				emit_signal("game_over")
				sprite.frame = 12
			elif revealed:
				reveal_adjacent()
			else:
				reveal()
		if Input.is_action_just_released("flag"):
			self.flagged = !flagged

func set_flagged(value):
	if revealed:
		return
	if value and !flagged:
		sprite.frame = 11
		Global.flags += 1
		if number == 9:
			Global.correct_flags += 1
		emit_signal("tile_updated")
	elif !value and flagged:
		sprite.frame = 10
		Global.flags -= 1
		if number == 9:
			Global.correct_flags -= 1
		emit_signal("tile_updated")
	
	flagged = value

func reveal():
	if flagged or revealed:
		return
	
	if (number == 0):
		revealed = true
		for i in range(-1,2):
			for j in range(-1,2):
				var row_len = Global.board_size
				if get_position_in_parent() % row_len == 0 and j == -1:
					continue
				if get_position_in_parent() % row_len == row_len-1 and j == 1:
					continue
				var adjacent_tile_index = get_position_in_parent() + i*Global.board_size + j
				
				if adjacent_tile_index >= 0 and adjacent_tile_index < Global.tile_amount:
					get_parent().get_child(adjacent_tile_index).flagged = false
					get_parent().get_child(adjacent_tile_index).reveal()
	
	Global.revealed += 1
	emit_signal("tile_updated")
	revealed = true
	sprite.frame = number

func reveal_adjacent():
	#Count the adjacent flags
	var flags = 0
	var adjacents = []
	var row_len = Global.board_size
	for i in range(-row_len,row_len*2,row_len):
		for j in range(-1,2):
			if get_position_in_parent() % row_len == 0 and j == -1:
				continue
			if get_position_in_parent() % row_len == row_len-1 and j == 1:
				continue
			
			var adjacent_tile_index = get_position_in_parent() + i + j
			if adjacent_tile_index < 0 or adjacent_tile_index >= Global.tile_amount:
				continue
			
			var adjacent_tile = get_parent().get_child(adjacent_tile_index)
			
			if adjacent_tile.flagged:
				flags += 1
			adjacents.append(adjacent_tile)
	
	if flags != number:
		return
	
	#Clear
	for tile in adjacents:
		if tile.number == 9 and !tile.flagged:
			Global.game_running = false
			emit_signal("game_over")
			tile.sprite.frame = 12
		
		tile.reveal()
