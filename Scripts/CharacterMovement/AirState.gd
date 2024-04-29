extends State

@onready var jumps = owner.moveData.maxDoubleJumps
@onready var slamCheck = get_node("../../SlamCheck")

#TODO: figure out why the character is always facing left without input in the air
func physics_update(_delta: float) -> void:
	var input = Vector2.ZERO
	var aiAirAttack = false
	var aiQuickFall = false
	var aiDoubleJump = false

	if player.aiController.heuristic == "human": 
		input.x = Input.get_axis("ui_left","ui_right")
		
	else:
		aiAirAttack =  player.aiController.attack_action
		aiQuickFall = player.aiController.quick_fall_action
		aiDoubleJump =  player.aiController.double_jump
		input.x = player.aiController.move_action

	if input.x != 0:
		player.lastHoriInput = input.x

	if player.aiController.heuristic != "human":
		if aiAirAttack:
			state_machine.transition_to("AttackState")

	if Input.is_action_just_pressed("ui_accept") and player.aiController.heuristic == "human":
		# need to change if the bow stance changes number
		if not slamCheck.is_colliding() and player.stance != 2:
			state_machine.transition_to("GroundSlamState")
		else:
			state_machine.transition_to("AttackState")

	if not player.is_occupied:
		#when in the middle of the air 
		if (Input.is_action_just_released("ui_up") and player.aiController.heuristic == "human") or aiQuickFall:
			if player.velocity.y < 0:
				player.velocity.y = 100
		
		#double jumping
		if (Input.is_action_just_pressed("ui_up") or aiDoubleJump) and player.velocity.y > 0 and jumps > 0:
			player.animations.animation = "JumpUp"
			player.velocity.y = player.moveData.doubleJumpForce
			jumps -= 1
		
		if input.x!= 0:
			owner.animations.flip_h = not input.x > 0.0

		var verticalSpeed = player.moveData.sprintSpeed if player.sprintToggle else player.moveData.horizontalMovementSpeed

		player.velocity.x = verticalSpeed * input.x

		if player.velocity.y > 0:
			player.animations.animation = "JumpDown"

		player.move_and_slide()

	player.animations.play()

	if player.is_on_floor():
		jumps = owner.moveData.maxDoubleJumps
		if is_equal_approx(player.velocity.x, 0.0):
			state_machine.transition_to("IdleState")
		else:
			state_machine.transition_to("RunState")

func enter(msg := {}) -> void:
	if msg.has("Jump"):
		player.animations.animation = "JumpUp"
		player.velocity.y = owner.moveData.JumpForce

