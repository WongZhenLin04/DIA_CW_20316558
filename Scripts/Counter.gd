extends Node
class_name EnemyCounter

# reward for getting a bow kill
@export var bowKillReward: float = 0.75

#reward for getting combo kills
@export var combo1Reward: float = 1
@export var combo2Reward: float = 1.5
@export var combo3Reward: float = 2
@export var combo4Reward: float = 2.5
@export var combo5Reward: float = 3

@onready var multiKillTimer:Timer = get_node("../MultikillTimer")
@onready var rewardSystem = get_node("../Player/UserInterface")
@onready var freshnessCounter = get_node("../Player/FreshnessCounter")
@onready var player : KnightPlayer = get_node("../Player")
@onready var multiplierTracker:MultiplierTracker = get_node("../Player/MultiplierTracker")

var enemiesKilled = 0
var numberOfMultiKills = 0
var totalScore = 0
var score = 0
var weaponFreshness = 2
var multiplier = 1

var enemiesKilledInLv = 0

var currentStance

func _ready():
	rewardSystem.updateUI(totalScore,score,multiplier,weaponFreshness)
	currentStance = player.stance

func _physics_process(delta: float):
	multiplier = multiplierTracker.multiplierBonus
	rewardSystem.updateUI(totalScore,score,multiplier,weaponFreshness)

func enemyKilled(killMethodBonus,isSlam,isBow):
	multiKillTimer.start()
	numberOfMultiKills+=1
	freshnessCounter.updateWeaponKills(isBow)
	if isSlam:
		score = calculateSlamRewards(killMethodBonus)
	elif isBow:
		weaponFreshness = freshnessCounter.get_child(2).currentFreshness
		score = calculateRewards(killMethodBonus)
	else:
		score = calculateRewards(killMethodBonus)
	totalScore += score
	enemiesKilledInLv += 1
	enemiesKilled+=1
	var stage1DecayWeaponIndex = freshnessCounter.find_weapon_with_mult(player.stage1Decay)
	var stage2DecayWeaponIndex = freshnessCounter.find_weapon_with_mult(player.stage2Decay)
	var stage3DecayWeaponIndex = freshnessCounter.find_weapon_with_mult(player.stage3Decay)
	var stage4DecayWeaponIndex = freshnessCounter.find_weapon_with_mult(player.stage4Decay)
	var currentWeapon :Weapon
	if isBow:
		currentWeapon= freshnessCounter.get_child(2)
	else:
		currentWeapon = freshnessCounter.get_child(player.stance)
	# If the current stance used is not the same as the weapon with a zero multiplier give an extra reward
	if stage4DecayWeaponIndex != null:
		var weapon = freshnessCounter.get_child(stage4DecayWeaponIndex) 
		if (player.stance != stage4DecayWeaponIndex) and (currentWeapon.currentFreshness > weapon.currentFreshness):
			player.aiController.reward += player.weaponDiversityReward4
	elif stage3DecayWeaponIndex != null:
		var weapon = freshnessCounter.get_child(stage3DecayWeaponIndex ) 
		if (player.stance != stage3DecayWeaponIndex ) and (currentWeapon.currentFreshness > weapon.currentFreshness):
			player.aiController.reward += player.weaponDiversityReward3
	elif stage2DecayWeaponIndex != null:
		var weapon = freshnessCounter.get_child(stage2DecayWeaponIndex) 
		if (player.stance != stage2DecayWeaponIndex) and (currentWeapon.currentFreshness > weapon.currentFreshness):
			player.aiController.reward += player.weaponDiversityReward2
	elif stage1DecayWeaponIndex != null:
		var weapon = freshnessCounter.get_child(stage1DecayWeaponIndex) 
		if (player.stance != stage1DecayWeaponIndex) and (currentWeapon.currentFreshness > weapon.currentFreshness):
			player.aiController.reward += player.weaponDiversityReward1

# TODO: Decide if inherit multiplier is needed,
func calculateRewards(killMethodBonus) -> float:
	# formula to calculate the total score points
	return max((killMethodBonus)*weaponFreshness*multiplier,1)

func calculateSlamRewards(killMethodBonus) -> float:
	# seperate formula to calculate the ground slam reward
	return max((killMethodBonus+numberOfMultiKills)*weaponFreshness*multiplier*freshnessCounter.groundSlamFreshness,1)

func _on_multikill_timer_timeout():
	numberOfMultiKills = 0	
