extends State

var animationName
var runnnningSpeed

func physics_update(_delta: float) -> void:
	var aiAttack = false
	var aiJump = false
	var input = Vector2.ZERO
	# human player input
	if player.aiController.heuristic == "human": 
		#if going to the right it is positive, negative if left
		input.x = Input.get_axis("ui_left","ui_right")

	# get how much the AI wants to move left and right
	else:
		input.x = player.aiController.move_action
		aiAttack = player.aiController.attack_action
		aiJump = player.aiController.jump_action

	#hadling the player speed and animation for both sprint and normal
	if player.sprintToggle:
		runnnningSpeed = player.moveData.sprintSpeed
		animationName = "sprint"
	else:
		runnnningSpeed = player.moveData.horizontalMovementSpeed
		animationName = "Run"

	if input.x != 0:
		player.lastHoriInput = input.x
		
	if not player.is_occupied:
		if input.x == 0:
			state_machine.transition_to("IdleState")
		else:
			_applyAcceleration(input.x)
			owner.animations.animation = animationName
			owner.animations.flip_h = not input.x > 0.0

		if not player.is_on_floor():
			state_machine.transition_to("AirState")

		if (Input.is_action_just_pressed("ui_accept") and player.aiController.heuristic == "human") or aiAttack:
			state_machine.transition_to("AttackState")

		if owner.is_on_floor:
			if (Input.is_action_just_pressed("ui_up") and player.aiController.heuristic == "human") or aiJump:
				state_machine.transition_to("AirState", {Jump=true})
	player.move_and_slide()
		
func _applyFriction():
	player.velocity.x = move_toward(player.velocity.x,0,owner.moveData.friction)

func _applyAcceleration(direction):
	#moving from original velocity, which might be 0 to max speed which is 50 in any direction
	#can move towards 50 or -50
	player.velocity.x = move_toward(player.velocity.x,runnnningSpeed*direction,owner.moveData.gravity)
