extends Node
class_name HurtWalls

@onready var wallHurtTimer = get_node("../HurtTimer")

var hurtAvailable = true

func _on_hurt_timer_timeout():
	hurtAvailable = true
