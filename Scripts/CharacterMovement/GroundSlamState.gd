extends State

var normalAttack
var normalAttackF
var slamAttack
var fallingAttack
var fallingAttackF

var enemiesKilled = 0

func enter(_msg := {}) -> void:
	
	player.is_occupied = true
	#Get all attacks that are involved in the ground slam attack
	for attack in player.attacks.get_children():
		#check if all the children in the attack box are collision boxes
		var allCollsions = true
		for collision in attack.get_children():
			if not collision is CollisionShape2D:
				allCollsions = false
		if allCollsions:
			if attack.name == "FallingAttack":
				fallingAttack = attack.get_child(0)
				fallingAttackF = attack.get_child(1)
			if attack.name == "GroundSlam":
				slamAttack = attack.get_child(0)
			if attack.name == "AirAttack":
				normalAttack = attack.get_child(0)
				normalAttackF = attack.get_child(1)

	player.animations.animation = "airSlash"

	var playingAttack = normalAttackF if owner.animations.flip_h else normalAttack

	#TODO: very ugly code, make sure to make superclass for attacks in the future
	playingAttack.disabled = false
	await player.animations.animation_finished
	playingAttack.disabled = true
	player.animations.play()

	#falling part
	player.animations.animation = "fallingSlam"
	playingAttack = fallingAttackF if owner.animations.flip_h else fallingAttack
	playingAttack.disabled = false
	
	while not player.is_on_floor():
		player.velocity.y = player.moveData.groundSlamVelocity
		#prevents player from moving horizontally
		player.velocity.x = 0
		player.move_and_slide()
	
	if player.is_on_floor():
		player.animations.animation = "groundSlam"
		playingAttack.disabled = true
		slamAttack.disabled = false
		await player.animations.animation_finished
		slamAttack.disabled = true
		player.animations.play()
		player.is_occupied = false

		if not player.hitEnemy:
			player.aiController.reward -= player.attackMissPenalty
		else:
			enemiesKilled = min(enemiesKilled+1,player.freshnessCounter.decay3SlamNumOfAtcks+1) 
			player.hitEnemy = false

		if player.velocity.x ==0.0:
			state_machine.transition_to("IdleState")
		else:
			state_machine.transition_to("RunState")

	
