extend Node

var levels = [
		{
		"id": 1,
		"moves": 20,
		"blue_goal": 10,
		"grid_size": {"width": 6, "height": 8},
		"empty_spaces": [],
		"special_pieces": [
			{"type": "bomb", "position": [2, 3]},
			{"type": "color_bomb", "position": [4, 5]}
		],
	},
	{
		"id": 2,
		"moves": 20,
		"blue_goal": 10,
		"grid_size": {"width": 6, "height": 8},
		"empty_spaces": [[0, 0], [0, 1], [5, 7]],
		"special_pieces": [
			{"type": "bomb", "position": [2, 3]},
			{"type": "color_bomb", "position": [4, 5]}
		],
	},
	# ... more levels ...
]
