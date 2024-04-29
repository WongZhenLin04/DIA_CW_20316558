extends CharacterBody2D
class_name KnightPlayer

# to access the move data and the animation node from the child node, get through owner
@export var moveData = Resource

# ground slam and bow attacks are not used anymore
@export var combo1Bonus:float = 2
@export var combo2Bonus:float = 3
@export var combo3Bonus:float = 4
@export var combo4Bonus:float = 5
@export var combo5Bonus:float = 6
@export var bowBonus:float = 3
@export var groundSlamBonus:float = 1
@export var levelCompletionReward:int = 20
# variable that multiplies the reward obtained by the AI
@export var inheritEnemyKillMultiplier:float = 2

# multiplier decay for combo attacks
@export var defaultWeaponFreshness: float = 2
@export var stage1Decay: float = 1.5
@export var stage2Decay: float = 1
@export var stage3Decay: float = 0.5
@export var stage4Decay: float = 0

@export var weaponDiversityReward1:float = 0.2
@export var weaponDiversityReward2:float = 0.4
@export var weaponDiversityReward3:float = 0.5
@export var weaponDiversityReward4:float = 1

# If the player goes past this Y threshold, the start rewarding it for jumping up
@export var yRangeTreshold: float = 30
# how much the y distance must improve by when the AI jumps up
@export var yImprovementThreshold: float = 0.1
@export var yImproveReward: float = 0.5
const approxSameLevelWithWalkingEnemy: float = 10
var calculateYDistReward = false
@export var bestYDist = INF

# variable to note the distance of when to recalculate the enemy's position if the player overshoots the target
@export var xRangeTreshold: float = 40
# 1 = on the right, -1 on the left
@export var prevDirection = -1
var xPosRecalc = false

@export var closenessMultiplier:float = 1.5

@export var overShootingEnemyPenalty: float = 10
@export var attackMissPenalty:float = 0.1
@export var restartPenalty: float = 30
@export var touchEnemyPenalty: float = 1
@export var overEnemyHitPenalty: float = 1

@onready var completionStopwatch:completion_stopwatch = get_node("../CompletionStopWatch")
@onready var animations = get_node("AnimatedSprite2D")
@onready var attacks = get_node("Attacks")
@onready var comboTimer = get_node("ComboTimer")
@onready var enemies= get_node("../Enemies")
@onready var scoreSystem = get_node("UserInterface")
@onready var enemyCounter: EnemyCounter = get_node("../Counter")
@onready var stanceTimer: Timer = get_node("StanceSwapCooldown")
@onready var freshnessCounter = get_node("FreshnessCounter")
@onready var fileWriter: FileWriter = get_node("../FileWriter") 

const sparseRewardMultiplier = 0.1

var aiController

#closest enemy
var enemy
var is_occupied = false
var bestDist = INF
var lastHoriInput = -1

var sprintToggle = false

var scoreArray = []
var timeArray = []
var rewardArray = []
var success =0
var fails = 0

# stance 0 - Sword, 1 - melee, 2 - Bow
var stance = 0
# number of stances the player should have
var maxStances = 1
#vars to track the current combo for each weapon
var fistCombo = 0
var swordCombo = 0
var hitEnemy = false

var originalSpawnPos:Vector2

var numberOfRetries = 3
var curRetries = 0
# var that notes the last level that the user was in
var levelNumber = 4
var lastLv = levelNumber

# TODO: change the repeats to appropriate values after debugging
# array for containing the information of each level, goes in numerical order
# IMPORTANT: Last entry of the dictionary should contain information regarding the snadbox level
const levelInformation = [
	{"spawn location": Vector2(414,-293), "required kills":3},
	{"spawn location": Vector2(842,-294), "required kills":3},
	{"spawn location": Vector2(1424,-294), "required kills":3},
	{"spawn location": Vector2(2075,-293), "required kills":3},
	{"spawn location": Vector2(2773,-310), "required kills":3},
	{"spawn location": Vector2(3553,-312), "required kills":3},
	{"spawn location": Vector2(440,227), "required kills":15},
	{"spawn location": Vector2(448,732), "required kills":11},
	{"spawn location": Vector2(481,1253), "required kills":13}
]
var ableStanceSwap = true

var killsRequired = 0


var rng = RandomNumberGenerator.new()

func _ready():
	showAndHideEnemies()
	originalSpawnPos = self.position
	recalculateEnemyDist()	
	aiController = $AIController2D
	aiController.init(self)
	
#apply gravity at all times
func _physics_process(delta):
	var aiStanceChange = false
	var aiSprint = false
	originalSpawnPos = levelInformation[levelNumber]["spawn location"]
	killsRequired = levelInformation[levelNumber]["required kills"]
	#TODO: try experimenting with enclosed spaces
	# when the player has killed all enemies
	if enemyCounter.enemiesKilledInLv >= killsRequired:
		success += 1
		# when level complete record the time it took to complete the level
		timeArray.append(completionStopwatch.getTime())
		completionStopwatch.resetTimer()
		#reward the AI when a level is completed
		aiController.reward += levelCompletionReward
		# reset the number of enemies killed in the level
		enemyCounter.enemiesKilledInLv = 0
		# if the player has repeated the level enough times then, don't respawn enemies, advance to the next level and spawn the user at the next level
		scoreArray.append(enemyCounter.totalScore)
		enemyCounter.totalScore = 0
		rewardArray.append(aiController.reward)
		enemyCounter.enemiesKilledInLv = 0

		pickLevel()

		enemies.respawnLevelEnemies(levelNumber)
		
		respawnAndHideEnemies()
		recalculateEnemyDist()
		self.position = levelInformation[levelNumber]["spawn location"]

	if not is_occupied:
		_applyGrav(delta)

	if aiController.heuristic != "human":
		aiStanceChange = aiController.stance_change
		aiSprint = aiController.sprint

	if (Input.is_action_just_pressed("ui_shift")and aiController.heuristic == "human") or aiSprint:
		sprintToggle = !sprintToggle

	if ((Input.is_action_just_pressed("ui_cntrl") and aiController.heuristic == "human") or aiStanceChange) and ableStanceSwap:
		ableStanceSwap = false
		stanceTimer.start()
		if stance == maxStances:
			stance = 0
		else:
			stance+=1
		# duing stance changes, make sure to reset the combos
		fistCombo = 0
		swordCombo = 0
	var nSuc = "Success: " + str(success) 
	var nFail = "Fails: " + str(fails) 
	var res =str(nSuc) + "\n" + str(nFail)
	fileWriter.writeFile(res,0)
	_check_vertical_placement()
	_check_horizontal_placement()
	update_reward()

func pickLevel():
	levelNumber = rng.randi_range(3,5)
	while levelNumber == lastLv:
		levelNumber = rng.randi_range(3,5)
	lastLv = levelNumber

func recalculateEnemyDist():
	enemy = findClosesetEnemy()
	bestDist = self.position.distance_to(enemy.position)

func update_reward():
	var s_reward = 0.0
	aiController.reward -= 0.01
	var enemyDist = self.global_position.distance_to(enemy.global_position)
	if enemyDist < bestDist:
		s_reward += (1/(enemyDist))
		bestDist = enemyDist
	s_reward *= closenessMultiplier
	aiController.reward += s_reward

func findClosesetEnemy():
	var closestEnemy:Node2D
	var nearestDist = INF
	for curEnemy in enemies.getCurrentLevelEnemies(levelNumber):
		var curDist = self.global_position.distance_to(curEnemy.global_position)
		if curDist < nearestDist:
			closestEnemy = curEnemy
			nearestDist = curDist
	return closestEnemy

func resetPosition():
	self.position = originalSpawnPos

func gameOver():
	pickLevel()
	enemies.respawnLevelEnemies(levelNumber)
	self.position = levelInformation[levelNumber]["spawn location"]
	respawnAndHideEnemies()
	recalculateEnemyDist()
	enemyCounter.enemiesKilledInLv = 0
	aiController.reset()

func _applyGrav(delta):
	if not is_on_floor():
		#Looks like this accelerates the player downwards
		#Adding means that the postion is moving downwards
		velocity.y += moveData.gravity * delta
		velocity.y = min(velocity.y,moveData.maxGrav)

# show enemies of current level and hide those that are not
func respawnAndHideEnemies():
	for i in range(levelInformation.size()):
		if i != levelNumber:
			var level = enemies.get_child(i)
			# hide every enemy that is not in the current level
			for e in level.get_children():
				if e is WalkingEnemy:
					e.hideFromPlayer()
	var level = enemies.get_child(levelNumber)
	for e in level.get_children():
		if e is WalkingEnemy:
			e.respawn()

func showAndHideEnemies():
	for i in range(levelInformation.size()):
		if i != levelNumber:
			var level = enemies.get_child(i)
			# hide every enemy that is not in the current level
			for e in level.get_children():
				if e is WalkingEnemy:
					e.hideFromPlayer()
	var level = enemies.get_child(levelNumber)
	for e in level.get_children():
		if e is WalkingEnemy:
			e.showToPlayer()

func _check_horizontal_placement():
	var xDiff = self.global_position.x - enemy.global_position.x
	var xThresh = xRangeTreshold
	var curDirection = 0 

	# user is on the right of the enemy
	if xDiff >= 0:
		curDirection = 1
		xThresh = abs(xThresh)

	# user is on the left side of the enemy
	elif xDiff < 0:
		curDirection = -1
		xThresh *= -1
	
	# the current direction is not the same as the previous direction then update
	if curDirection != prevDirection:
		xPosRecalc = true
		prevDirection = curDirection

	if (xDiff < xThresh or xDiff > xThresh) and xPosRecalc:
		recalculateEnemyDist()
		aiController.reward -= overShootingEnemyPenalty
		xPosRecalc = false

# handles when the system should reward the AI for jumping up
func _check_vertical_placement():
	var yDist = self.global_position.y - enemy.global_position.y
	if is_on_floor():
		# when the player is on a platform that is lower than the enemy by the treshold distance then start rewardning it for jumping
		if yDist > yRangeTreshold:
			calculateYDistReward = true
		# when the player is on the same level or above the enemy then stop rewading it for jumping
		elif yDist < approxSameLevelWithWalkingEnemy:
			calculateYDistReward = false
			bestYDist = INF
	# if the player gets closer to the enemy in terms of y distance then reward them
	if calculateYDistReward:
		if yDist < bestYDist and abs(yDist-bestYDist) > yImprovementThreshold:
			bestYDist = yDist
			aiController.reward += yImproveReward

func _onCombo1Hit(body:Node2D):
	_on_enemy_hit(combo1Bonus,body,false)

func _on_ground_slam_body_entered(body:Node2D):
	_on_enemy_hit(groundSlamBonus,body,true)

func _on_falling_attack_body_entered(body:Node2D):
	_on_enemy_hit(groundSlamBonus,body,true)

func _on_air_attack_body_entered(body:Node2D):
	_on_enemy_hit(groundSlamBonus,body,true)

func _on_sword_2_body_entered(body:Node2D):
	_on_enemy_hit(combo2Bonus,body,false)

func _on_sword_3_body_entered(body:Node2D):
	_on_enemy_hit(combo3Bonus,body,false)
	
func _on_fist_attack_1_body_entered(body:Node2D):
	_on_enemy_hit(combo1Bonus,body,false)

func _on_fist_attack_2_body_entered(body:Node2D):
	_on_enemy_hit(combo2Bonus,body,false)

func _on_fist_attack_3_body_entered(body:Node2D):
	_on_enemy_hit(combo3Bonus,body,false)

func _on_fist_attack_4_body_entered(body:Node2D):
	_on_enemy_hit(combo4Bonus,body,false)

func _on_fist_attack_5_body_entered(body:Node2D):
	_on_enemy_hit(combo5Bonus,body,false)

func _on_enemy_hit(comboType,body:Node2D,isSlam:bool):
	if body is WalkingEnemy:
		body.takeDamage(comboType,isSlam,false)
		hitEnemy = true

func _on_combo_timer_timeout():
	swordCombo = 0
	fistCombo = 0

# every 50 seconds, check if the closest not same enemy is hit
func _on_closest_enemy_patience_timeout():
	# if the enemy is not hit, then the closest enemy is recalibrated
	if not enemy.isHit and (findClosesetEnemy().name != enemy.name):
		recalculateEnemyDist()

# Timer to ensure that the player can only swap weapons every 0.5 seconds
func _on_stance_swap_cooldown_timeout():
	ableStanceSwap = true

func arrayToString(arr: Array) -> String:
	var res = "["
	for i in range(arr.size()):
		res += str(arr[i])
		if i < arr.size() - 1:
			res += ", "
	res += "]"
	return res

#function for when the AI doesn't complete the environment on time
func _on_completion_timer_timeout():
	freshnessCounter.resetAllWeaponFreshness()
	enemyCounter.totalScore = 0
	if curRetries == numberOfRetries:
		curRetries = 0
		fails += 1
		aiController.done = true
		aiController.reward -= restartPenalty
		rewardArray.append(aiController.reward/killsRequired)
		gameOver()
	else:
		enemyCounter.enemiesKilledInLv = 0
		curRetries+=1
		enemyCounter.totalScore = 0
		fails += 1
		aiController.done = true
		aiController.reward -= restartPenalty
		rewardArray.append(aiController.reward/killsRequired)
		enemies.respawnLevelEnemies(levelNumber)
		respawnAndHideEnemies()
		recalculateEnemyDist()
		resetPosition()