extends Node

@export var decay1SlamNumOfAtcks = 2
@export var decay2SlamNumOfAtcks = 3
@export var decay3SlamNumOfAtcks = 4

# get counter for enemy
@onready var enemyCounter:EnemyCounter = get_node("../../Counter") 
@onready var enemies = get_node("../../Enemies")
@onready var groundSlamState = get_node("../StateMachine/GroundSlamState")
@onready var bow = get_node("bow")

#last recorded stance
var currentStance
# number of enemies before the stance change
var initialEnemies

var getNonHitFlag = true
var notHitEnemies = []

var currentWeapon:Weapon

# variable to keep track of the freshness of the ground slam attack
var groundSlamFreshness = 1

func _ready():
	await owner.ready
	currentStance = owner.stance
	currentWeapon = get_child(owner.stance)
	initialEnemies = enemyCounter.enemiesKilled

func _physics_process(delta):
	currentWeapon = get_child(owner.stance)
	enemyCounter.weaponFreshness = currentWeapon.currentFreshness

func updateWeaponKills(isBow):
	# every time a weapon hits an enemy, lower its freshness but increase the freshness of other weapons
	if !isBow:
		currentWeapon.numberOfAttacks = min(currentWeapon.numberOfAttacks+1, currentWeapon.stage4)
		for i in range(owner.maxStances+1):
			if i != owner.stance:
				get_child(i).numberOfAttacks = max(get_child(i).numberOfAttacks-1,0)
	else:
		bow.numberOfAttacks = min(bow.numberOfAttacks+1, bow.stage4)
		for weapon in get_children():
			if weapon.name!="bow":
				weapon.numberOfAttacks = max(weapon.numberOfAttacks-1,0)

func resetAllWeaponFreshness():
	for weapon in get_children():
		weapon.numberOfAttacks = weapon.stage2


func find_weapon_with_mult(mult:float):
	var index = null
	for i in range(get_child_count()):
		if get_child(i) is Weapon:
			if get_child(i).currentFreshness == mult:
				index = i
				break
	return index

