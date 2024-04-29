extends Node
class_name MultiplierTracker

@export var maxMultiplierBonus:int = 3 

var multiplierBonus = 1

func _physics_process(delta):

	if not owner.is_on_floor():
		multiplierBonus = min(multiplierBonus+0.1,maxMultiplierBonus)
	if owner.is_on_floor():
		multiplierBonus = 1
	