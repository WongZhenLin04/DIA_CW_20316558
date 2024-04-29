#The job of this object is to only update the labels shown on screen
extends Control
class_name RewardUI

@onready var scoreLabel: Label = get_node("ScoreLabel")
@onready var totalScoreLabel: Label = get_node("TotalScoreLabel")
@onready var scoreMultiplier: Label = get_node("ScoreMultiplier")
@onready var weaponFreshness: Label = get_node("WeaponFreshness")

var currentStance = "(sword)"

func _physics_process(delta):
	if get_parent().stance == 0 :
		currentStance = "(sword)"
	elif get_parent().stance == 1 :
		currentStance = "(fist)"
	elif get_parent().stance == 2 :
		currentStance = "(bow)"

func updateUI(totalScore, score, multiplier,freshness):
	totalScoreLabel.text = "Total Score: %s" % totalScore
	scoreLabel.text = "Score: %s" % score
	scoreMultiplier.text = "Multiplier x %s" % multiplier
	weaponFreshness.text = "Fressness x %s " % freshness + currentStance
