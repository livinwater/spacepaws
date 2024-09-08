extends "res://Scripts/piece.gd"

var is_horizontal = true

func _ready():
	super._ready()
	scale = Vector2(0.75, 0.75)

func move(target):
	var move_tween = get_tree().create_tween()
	move_tween.tween_property(self, "position", target, 0.3).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

func dim():
	var dim_tween = get_tree().create_tween()
	dim_tween.tween_property(self, "modulate", Color(1, 1, 1, 0.5), 0.3)
