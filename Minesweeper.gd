extends Node2D

const Tile = preload("res://Tile.tscn")

onready var tiles = $Tiles
onready var minesLeft = $MinesLeft
onready var slider = $HSlider
onready var endText = $EndText
onready var mineDensity = $MineDensity
onready var checkBox = $CheckBox
onready var bsSlider = $BSSlider
onready var boardSize = $BoardSize

func _ready() -> void:
	#Randomly select mine_amount mines
	randomize()
	var mines = []
	for i in range(Global.tile_amount):
		mines.push_back(i)
	mines.shuffle()
	mines = mines.slice(0,Global.mine_amount-1)
	if Global.mine_amount <= 0:
		mines = []
	
	#Create the tiles
	for y in range(Global.board_size):
		for x in range(Global.board_size):
			var tile = Tile.instance()
			tiles.add_child(tile)
			tile.connect("clicked", self, "tile_clicked")
			tile.connect("tile_updated", self, "tile_updated")
			tile.connect("game_over", self, "game_over")
			
			var number = 0
			if (mines.find(x + y*Global.board_size) != -1):
				number = 9 #is a mine
			tile.init(x*Global.tile_size, y*Global.tile_size + 40, number)
	
	#Increase the number of tiles surrounding mines
	for mine_index in mines:
		var row_len:int = Global.board_size
		for i in range(-row_len,row_len*2,row_len):
			for j in range(-1,2):
				if mine_index % row_len == 0 and j == -1:
					continue
				if mine_index % row_len == row_len-1 and j == 1:
					continue
				
				var adjacent_index = mine_index + i + j
				if adjacent_index >=0 and adjacent_index < Global.tile_amount:
					if tiles.get_child(adjacent_index).number != 9:
						tiles.get_child(adjacent_index).number += 1
	
	#Set UI values
	minesLeft.set_text(str(Global.mine_amount))
	slider.set_value(Global.mine_density)
	mineDensity.set_text(str(Global.mine_density))
	checkBox.set("pressed", Global.auto_start)
	bsSlider.set_value(Global.board_size)
	boardSize.set_text(str(Global.board_size))
	
	#Reveal a random blank tile on auto-start
	if (Global.auto_start):
		var blanks = []
		for y in range(Global.board_size):
			for x in range(Global.board_size):
				var tile = tiles.get_child(y*Global.board_size + x)
				if tile.number == 0:
					blanks.append(tile)
		blanks.shuffle()
		if blanks.size() > 0:
			blanks[0].reveal()

#Debugging
func tile_clicked(index):
	print(str(index) + " or " + str(Global.index1Dto2D(index)))
	var tile = tiles.get_child(index)
	print("Number = " + str(tile.number))
	print("Revealed = " + str(tile.revealed))
	print("Flagged = " + str(tile.flagged))
	print("game_running = " + str(Global.game_running))
	print()

func tile_updated():
	#Checks if won
	if (Global.correct_flags == Global.mine_amount and Global.correct_flags == Global.flags or Global.revealed == Global.tile_amount - Global.mine_amount and Global.game_running):
		Global.game_running = false
		endText.set_text("You Won!")
		endText.add_color_override("font_color", Color(0,1,0,1))
		endText.set_visible(true)
	
	minesLeft.set_text(str(Global.mine_amount - Global.flags))

func game_over():
	for tile in tiles.get_children():
		if tile.flagged and tile.number != 9:
			tile.sprite.frame = 13 #False flag image
		else:
			tile.reveal()
	
	endText.set_text("You Lost")
	endText.add_color_override("font_color", Color(1,0,0,1))
	endText.set_visible(true)

func _on_RestartButton_pressed() -> void:
	Global.reset()
	get_tree().change_scene("res://Minesweeper.tscn") #Easy way to restart the game

func _on_HSlider_value_changed(value: float) -> void:
	Global.mine_density = value
	mineDensity.set_text(str(value))

func _on_CheckBox_toggled(button_pressed: bool) -> void:
	Global.auto_start = button_pressed

func _on_BSSlider_value_changed(value: float) -> void:
	Global.board_size = int(value)
	boardSize.set_text(str(value))
