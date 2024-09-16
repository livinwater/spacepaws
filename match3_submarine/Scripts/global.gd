extends Node

var total_points = 0

func add_points(points: int):
    total_points += points
    print("Points added. New total: ", total_points)  # Add this line

func get_total_points() -> int:
    return total_points