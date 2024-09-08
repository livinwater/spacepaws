extends Node2D

enum GameState { WAIT, MOVE}
var state

#Grid initialization
@export var width: int
@export var height: int
@export var x_start: int
@export var y_start: int
@export var offset: int
@export var y_offset: int
@export var empty_spaces : PackedVector2Array

var possible_pieces = [
	preload("res://Scenes/blue_piece.tscn"),
	preload("res://Scenes/green_piece.tscn"),
	preload("res://Scenes/red_piece.tscn"),
	preload("res://Scenes/yellow_piece.tscn")
]

var all_pieces = []

var first_touch = Vector2(0,0)
var final_touch = Vector2(0,0)
var controlling = false
var piece_one = null
var piece_two = null
var last_place = Vector2(0,0)
var last_direction = Vector2(0,0)
var move_checked = false

const BLUE_GOAL = 10
var blue_pieces_cleared = 0
var goal_counter_box: VBoxContainer

# Add these new variables near the top of the script
const MOVE_LIMIT = 20
var moves_left = MOVE_LIMIT
var move_counter_label: Label

func _ready():
	state = GameState.MOVE
	randomize()
	all_pieces = make_2D_array()
	center_grid()  # Call this before spawning pieces
	spawn_pieces()
	
	# Get reference to the GoalCounterBox node
	goal_counter_box = get_node("../MarginGoalCounter/PanelGoalCounter/GoalCounterBox")
	update_blue_pieces_counter()

	# Add this line to get the reference to the MoveCounterLabel
	move_counter_label = get_node("../MarginMoveCounter/PanelMoveCounter/MoveContainer/MoveCounterLabel")
	update_move_counter()

# New function to center the grid
func center_grid():
	var screen_size = get_viewport_rect().size
	var grid_width = width * offset
	var grid_height = height * offset
	x_start = (screen_size.x - grid_width) / 2
	y_start = screen_size.y - (screen_size.y - grid_height) / 2

func restricted_movement(place):
	for i in empty_spaces.size():
		if empty_spaces[i] == place:
			return true
	return false
	
# Update this function
func update_blue_pieces_counter():
	if goal_counter_box:
		var pieces_left = BLUE_GOAL - blue_pieces_cleared
		goal_counter_box.get_node("CounterLabel").text = "x " + str(pieces_left)

func make_2D_array():
	var array = []
	for i in width:
		array.append([])
		for j in height:
			array[i].append(null)
	return array
			
# Spawn pieces and ensure no match-at-start
func spawn_pieces():
	for i in width:
		for j in height:
			if !restricted_movement(Vector2(i,j)):
				all_pieces[i][j] = create_random_piece(i, j)
# Helper function to create a random piece
func create_random_piece(column, row):
	var rand = floor(randi_range(0, possible_pieces.size() - 1))
	var piece = possible_pieces[rand].instantiate()
	var loops = 0
	while match_at(column, row, piece.color) and loops < 100:
		rand = floor(randi_range(0, possible_pieces.size() - 1))
		loops += 1
		piece = possible_pieces[rand].instantiate()
	add_child(piece)
	piece.position = grid_to_pixel(column,row + y_offset)
	piece.move(grid_to_pixel(column,row))
	return piece

# Match check function
func match_at(i, j, color):
	if i > 1:
		if all_pieces[i - 1][j] != null and all_pieces[i - 2][j] != null:
			if all_pieces[i - 1][j].color == color and all_pieces[i - 2][j].color == color:
				return true
	if j > 1:
		if all_pieces[i][j - 1] != null and all_pieces[i][j - 2] != null:
			if all_pieces[i][j - 1].color == color and all_pieces[i][j - 2].color == color:
				return true
	return false
		
# Conversion functions between grid and pixel
func grid_to_pixel(column, row):
	return Vector2(x_start + offset * column, y_start - offset * row)

func pixel_to_grid(pixel_x, pixel_y):
	return Vector2(round((pixel_x - x_start) / offset), round((pixel_y - y_start) / -offset))

# Check if the position is within grid bounds
func is_in_grid(grid_position):
	return grid_position.x >= 0 and grid_position.x < width and grid_position.y >= 0 and grid_position.y < height

# Handle touch input
func touch_input():
	if Input.is_action_just_pressed("ui_touch"):
		if is_in_grid(pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y)):
			first_touch = pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y)
			controlling = true
	if Input.is_action_just_released("ui_touch"):
		if controlling:
			controlling = false		
			final_touch = pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y)
			touch_difference(first_touch, final_touch)
			
# Swap pieces and store information for rollback
func swap_pieces(column, row, direction):
	var first_piece = all_pieces[column][row]
	var other_piece = all_pieces[column + direction.x][row + direction.y]
	if first_piece != null and other_piece != null:
		store_info(first_piece, other_piece, Vector2(column, row), direction)
		state = GameState.WAIT
		all_pieces[column][row] = other_piece
		all_pieces[column + direction.x][row + direction.y] = first_piece
		first_piece.move(grid_to_pixel(column + direction.x, row + direction.y))
		other_piece.move(grid_to_pixel(column, row))
		if not move_checked:
			find_matches()
			moves_left -= 1
			update_move_counter()
			check_game_over()

# Store information for swap back
func store_info(first_piece, other_piece, place, direction):
	piece_one = first_piece
	piece_two = other_piece
	last_place = place
	last_direction = direction
	
# Swap back the pieces if no match is found
func swap_back():
	if piece_one != null and piece_two != null:
		swap_pieces(last_place.x, last_place.y, last_direction)	
	state = GameState.MOVE
	move_checked = false
	moves_left += 1  # Refund the move if it didn't result in a match
	update_move_counter()
	
# Determine which direction to swap
func touch_difference(grid_1, grid_2):
	var difference = grid_2 - grid_1
	if abs(difference.x) > abs(difference.y):
		if difference.x > 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(1, 0))
		elif difference.x < 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(-1, 0))
	elif abs(difference.y) > abs(difference.x):
		if difference.y > 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(0, 1))
		elif difference.y < 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(0, -1))
			
# Find matches on the grid
func find_matches():
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				check_match(i, j)
	get_parent().get_node("destroy_timer").start()
	
# Helper function to check for matches in a specific position
func check_match(i, j):
	var current_color = all_pieces[i][j].color
	# Horizontal match
	if i > 0 and i < width - 1:
		if all_pieces[i - 1][j] != null and all_pieces[i + 1][j] != null:
			if all_pieces[i - 1][j].color == current_color and all_pieces[i + 1][j].color == current_color:
				mark_as_matched(i - 1, j)
				mark_as_matched(i, j)
				mark_as_matched(i + 1, j)
	# Vertical match
	if j > 0 and j < height - 1:
		if all_pieces[i][j - 1] != null and all_pieces[i][j + 1] != null:
			if all_pieces[i][j - 1].color == current_color and all_pieces[i][j + 1].color == current_color:
				mark_as_matched(i, j - 1)
				mark_as_matched(i, j)
				mark_as_matched(i, j + 1)

# Mark piece as matched and dim it
func mark_as_matched(i, j):
	all_pieces[i][j].matched = true
	all_pieces[i][j].dim()

# Destroy matched pieces
func destroy_matched():
	var was_matched = false
	for i in width:
		for j in height:
			if all_pieces[i][j] != null and all_pieces[i][j].matched:
				was_matched = true
				if all_pieces[i][j].color == "blue":
					blue_pieces_cleared += 1
					update_blue_pieces_counter()
				all_pieces[i][j].queue_free()
				all_pieces[i][j] = null
	move_checked = true
	if was_matched:
		get_parent().get_node("collapse_timer").start()
	else:
		swap_back()
	
	check_goal()

# New function to check if the goal has been reached
func check_goal():
	check_game_over()

# Add this new function to check if the game is over
func check_game_over():
	if moves_left <= 0:
		print("Game Over! Out of moves.")
		show_game_over_screen()
	elif blue_pieces_cleared >= BLUE_GOAL:
		print("Level completed! You've cleared", blue_pieces_cleared, "blue pieces!")
		show_win_screen()

# Add this new function to show the game over screen
func show_game_over_screen():
	var game_over_screen = preload("res://Scenes/GameOverScreen.tscn").instantiate()
	get_tree().root.add_child(game_over_screen)

func show_win_screen():
	var win_screen = preload("res://Scenes/WinScreen.tscn").instantiate()
	get_tree().root.add_child(win_screen)

# Collapse columns after match
func collapse_columns():
	for i in width:
		for j in height:
			if all_pieces[i][j] == null and !restricted_movement(Vector2(i,j)):
				for k in range(j + 1, height):
					if all_pieces[i][k] != null:
						all_pieces[i][k].move(grid_to_pixel(i, j))
						all_pieces[i][j] = all_pieces[i][k]
						all_pieces[i][k] = null
						break
	get_parent().get_node("refill_timer").start()

# Refill the grid after collapsing
func refill_columns():
	for i in width:
		for j in height:
			if all_pieces[i][j] == null and !restricted_movement(Vector2(i,j)):
				all_pieces[i][j] = create_random_piece(i, j)
	after_refill()
				
# Check for new matches after refill
func after_refill():
	for i in width:
		for j in height:
			if all_pieces[i][j] != null and match_at(i, j, all_pieces[i][j].color):
				find_matches()
				get_parent().get_node("destroy_timer").start()
				return
	# If no new matches are found, switch state back to move
	state = GameState.MOVE
	move_checked = false

# Add this new function to update the move counter display
func update_move_counter():
	if move_counter_label:
		move_counter_label.text = str(moves_left)

# Process function to handle state and touch input
func _process(delta):
	if state == GameState.MOVE:
		touch_input()
		
# Callback for destroy timer timeout
func _on_destroy_timer_timeout():
	destroy_matched()

# Callback for collapse timer timeout
func _on_collapse_timer_timeout():
	collapse_columns()

# Callback for refill timer timeout
func _on_refill_timer_timeout():
	refill_columns()
