extends State

@onready var playerHitBox = get_node("../../PlayerHitBox")
var direction = 0

func enter(_msg := {}) -> void:
	if _msg.has("Direction"):
		direction = _msg["Direction"]
	var input = Vector2.ZERO
	input.x = Input.get_axis("ui_left","ui_right")
	player.is_occupied = true
	player.animations.animation = "Slide"
	playerHitBox.disabled = true
	player.velocity.x += owner.moveData.slideVelocity*direction
	player.move_and_slide()
	await player.animations.animation_finished
	playerHitBox.disabled = false
	player.animations.play()
	player.is_occupied = false
	if is_equal_approx(input.x,0.0):
		state_machine.transition_to("IdleState")
	else:
		state_machine.transition_to("RunState")
