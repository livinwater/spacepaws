extends Node

var wallet_address: String = ""
var total_points: int = 0
var silica_count = 0
var metal_count = 0
var crystal_count = 0

func set_wallet_address(address: String):
    wallet_address = address

func get_wallet_address() -> String:
    return wallet_address

func add_points(points: int):
    total_points += points
    if total_points < 0:
        total_points = 0

func get_total_points() -> int:
    return total_points

func add_resource(resource_type: String, amount: int):
    match resource_type:
        "Silica":
            silica_count += amount
        "Metal":
            metal_count += amount
        "Crystal":
            crystal_count += amount
 
func get_resource_count(resource_type: String) -> int:
    match resource_type:
        "Silica":
            return silica_count
        "Metal":
            return metal_count
        "Crystal":
            return crystal_count
    return 0