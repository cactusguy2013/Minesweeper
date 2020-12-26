extends Node

var board_size = 20 #Amount of tiles in a row or column
var tile_size = int(600.0/board_size) #Pixel size of image
var tile_amount = board_size*board_size #Total tiles of screen

var mine_density = 0.15 #Ratio of mines : not mines (1)
var mine_amount = int(max(tile_amount * mine_density, 1)) #Total mines

var flags = 0
var correct_flags = 0
var revealed = 0
var game_running = true

var auto_start = false

func index2Dto1D(x,y):
	return y*int(board_size) + x

func index1Dto2D(index):
	return Vector2(index % int(board_size), index/int(board_size))

func reset():
	tile_size = int(600.0/board_size)
	tile_amount = board_size*board_size
	flags = 0
	correct_flags = 0
	revealed = 0
	mine_amount = int(max(tile_amount * mine_density, 1))
	game_running = true
