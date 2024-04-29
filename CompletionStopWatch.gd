extends Node

class_name completion_stopwatch

var time = 0.0

func _process(delta):
	time += delta
	pass

func resetTimer():
	time = 0.0

func getTime():
	return "%.2f"% time
