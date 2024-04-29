extends Node
class_name AttackTimer

var time_elapsed := 0.0
var currentSec = 0

func _process(delta: float) -> void:
	time_elapsed += delta
	var temp = floor(time_elapsed)
	if currentSec != temp:
		currentSec = temp

func reset() -> void:
	time_elapsed = 0.0
