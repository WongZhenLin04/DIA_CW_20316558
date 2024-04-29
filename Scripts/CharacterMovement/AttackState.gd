extends State

var swordAttack1
var swordAttack1F
var swordAttack2
var swordAttack2F
var swordAttack3
var swordAttack3F

var fistAttack1
var fistAttack1F
var fistAttack2
var fistAttack2F
var fistAttack3
var fistAttack3F
var fistAttack4
var fistAttack4F
var fistAttack5
var fistAttack5F

var arrow = preload("res://Elements/arrow.tscn")
@onready var arrowStartL = get_node("../../ArrowStartL")
@onready var arrowStartR = get_node("../../ArrowStartR")
@onready var groundSlamState = get_node("../GroundSlamState")

func enter(_msg := {}) -> void:
	player.is_occupied = true
	player.comboTimer.stop()
	player.comboTimer.start()
	for attack in player.attacks.get_children():
		if attack.name == "Sword1":
			# Hitbox should always be first child
			var hitBox = attack.get_child(0)
			var hitBoxF = attack.get_child(1)
			if hitBox is CollisionPolygon2D and hitBoxF is CollisionPolygon2D:
				swordAttack1 = hitBox
				swordAttack1F = hitBoxF
		if attack.name == "Sword2":
			# Hitbox should always be first child
			var hitBox = attack.get_child(0)
			var hitBoxF = attack.get_child(1)
			if hitBox is CollisionShape2D and hitBoxF is CollisionShape2D:
				swordAttack2 = hitBox
				swordAttack2F = hitBoxF
		if attack.name == "Sword3":
			# Hitbox should always be first child
			var hitBox = attack.get_child(0)
			var hitBoxF = attack.get_child(1)
			if hitBox is CollisionPolygon2D and hitBoxF is CollisionPolygon2D:
				swordAttack3 = hitBox
				swordAttack3F = hitBoxF
		if attack.name == "FistAttack1":
			# Hitbox should always be first child
			var hitBox = attack.get_child(0)
			var hitBoxF = attack.get_child(1)
			if hitBox is CollisionShape2D and hitBoxF is CollisionShape2D:
				fistAttack1 = hitBox
				fistAttack1F = hitBoxF
		if attack.name == "FistAttack2":
			# Hitbox should always be first child
			var hitBox = attack.get_child(0)
			var hitBoxF = attack.get_child(1)
			if hitBox is CollisionShape2D and hitBoxF is CollisionShape2D:
				fistAttack2 = hitBox
				fistAttack2F = hitBoxF
		if attack.name == "FistAttack3":
			# Hitbox should always be first child
			var hitBox = attack.get_child(0)
			var hitBoxF = attack.get_child(1)
			if hitBox is CollisionPolygon2D and hitBoxF is CollisionPolygon2D:
				fistAttack3 = hitBox
				fistAttack3F = hitBoxF
		if attack.name == "FistAttack4":
			# Hitbox should always be first child
			var hitBox = attack.get_child(0)
			var hitBoxF = attack.get_child(1)
			if hitBox is CollisionPolygon2D and hitBoxF is CollisionPolygon2D:
				fistAttack4 = hitBox
				fistAttack4F = hitBoxF
		if attack.name == "FistAttack5":
			# Hitbox should always be first child
			var hitBox = attack.get_child(0)
			var hitBoxF = attack.get_child(1)
			if hitBox is CollisionPolygon2D and hitBoxF is CollisionPolygon2D:
				fistAttack5 = hitBox
				fistAttack5F = hitBoxF
	
	var playingAttack
	if player.stance == 0:
		if player.swordCombo == 0:
			player.animations.animation = "sword1"
			playingAttack = swordAttack1F if owner.animations.flip_h else swordAttack1
			player.swordCombo += 1
		elif player.swordCombo == 1:
			player.animations.animation = "sword2"
			playingAttack = swordAttack2F if owner.animations.flip_h else swordAttack2
			player.swordCombo += 1
		elif player.swordCombo == 2:
			player.animations.animation = "sword3"
			playingAttack = swordAttack3F if owner.animations.flip_h else swordAttack3
			player.swordCombo = 0
	elif player.stance == 1:
		if player.fistCombo == 0:
			player.animations.animation = "fistAttack1"
			playingAttack = fistAttack1F if owner.animations.flip_h else fistAttack1
			player.fistCombo += 1
		elif player.fistCombo == 1:
			player.animations.animation = "fistAttack2"
			playingAttack = fistAttack2F if owner.animations.flip_h else fistAttack2
			player.fistCombo += 1
		elif player.fistCombo == 2:
			player.animations.animation = "fistAttack3"
			playingAttack = fistAttack3F if owner.animations.flip_h else fistAttack3
			player.fistCombo += 1
		elif player.fistCombo == 3:
			player.animations.animation = "fistAttack4"
			playingAttack = fistAttack3F if owner.animations.flip_h else fistAttack3
			player.fistCombo += 1
		#change this if the combo gets longer
		elif player.fistCombo == 4:
			player.animations.animation = "fistAttack5"
			playingAttack = fistAttack3F if owner.animations.flip_h else fistAttack3
			player.fistCombo = 0
	elif player.stance == 2:
		player.animations.animation = "shooting"
		await player.animations.animation_finished
		var curArrow = arrow.instantiate()
		player.get_parent().add_child(curArrow)
		var curPoint = arrowStartL if player.animations.flip_h else arrowStartR
		curArrow.position = Vector2(player.position.x+curPoint.position.x,player.position.y+curPoint.position.y)
		
	#if its not a projectile attack
	if playingAttack:
		playingAttack.disabled = false
		await player.animations.animation_finished
		playingAttack.disabled = true

	player.animations.play()

	player.is_occupied = false

	var zeroMultWeaponInd = player.freshnessCounter.find_weapon_with_mult(player.stage4Decay)

	if not player.hitEnemy:
		player.aiController.reward -= player.attackMissPenalty
		player.hitEnemy = false

	if player.is_on_floor():
		if player.velocity.x ==0.0:
			state_machine.transition_to("IdleState")
		else:
			state_machine.transition_to("RunState")
	#TODO: Implement ground slam after being able to find out if AI works
	elif not player.is_on_floor():
		state_machine.transition_to("AirState")
