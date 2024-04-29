extends Node

class_name Weapon

var freshness

@export var stage1: int = 2
@export var stage2: int = 4
@export var stage3: int = 5
@export var stage4: int = 6

var currentFreshness

@onready var numberOfAttacks = stage2

func _physics_process(delta):
    _updateFreshness()

func _updateFreshness():
    if (numberOfAttacks >= stage1 && numberOfAttacks < stage2):
        currentFreshness = owner.stage1Decay
    elif (numberOfAttacks >= stage2 && numberOfAttacks < stage3):
        currentFreshness = owner.stage2Decay
    elif (numberOfAttacks >= stage3 && numberOfAttacks < stage4):
        currentFreshness = owner.stage3Decay
    elif (numberOfAttacks >= stage4):
        currentFreshness = owner.stage4Decay
    else:
        currentFreshness = owner.defaultWeaponFreshness