extends State

func enter(msg := {}) -> void:
	owner.velocity = Vector2.ZERO
	owner.animations.animation = "Idle"

func update(delta: float) -> void:
	if not owner.is_on_floor():
			state_machine.transition_to("AirState")
	
	if player.aiController.heuristic == "human":

		if Input.is_action_just_pressed("ui_accept"):
			state_machine.transition_to("AttackState")

		elif owner.is_on_floor() and Input.is_action_just_pressed("ui_up"):
			state_machine.transition_to("AirState", {Jump=true})

		elif (Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right")) and player.is_on_floor():
			state_machine.transition_to("RunState")

	else:
		if player.aiController.attack_action:
			state_machine.transition_to("AttackState")
		elif player.aiController.move_action != 0:
			state_machine.transition_to("RunState")
		elif player.aiController.jump_action:
			state_machine.transition_to("AirState", {Jump=true})
		

