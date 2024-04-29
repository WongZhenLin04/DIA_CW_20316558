extends AIController2D

var move_action = 0.0
var attack_action = false
var jump_action = false
var quick_fall_action = false
var stance_change = false
var double_jump = false
var sprint = false

func _physics_process(delta):
	n_steps += 1
	if n_steps > reset_after:
		needs_reset = true
		done = true

	if needs_reset:
		needs_reset = false
		reset()

func get_obs() -> Dictionary:
	#add all enemy positions to the ai's observation
	var enemies = _player.enemies
	var obs = []
	for enemy in enemies.getChildrenInRange(3,5) :
		var enemyPos = enemy.spawnLocation
		obs.append(enemyPos.x)
		obs.append(enemyPos.y)
	return {"obs":obs}
	
# set reward dynamically through the code?
func get_reward() -> float:	
	return reward
	
func get_action_space() -> Dictionary:
	return {
		"move_action" : {
			"size": 1,
			"action_type": "continuous"
		},
		"short_stop" : {
			"size": 1,
			"action_type": "discrete"
		},
		"attack_action" : {
			"size": 1,
			"action_type": "discrete"
		},
		"jump_action":{
			"size": 1,
			"action_type" : "discrete"
		},
		"quick_fall_action" : {
			"size": 1,
			"action_type" : "discrete"
		},
		"stance_change":{
			"size":1,
			"action_type":"discrete"
		},
		"double_jump":{
			"size":1,
			"action_type":"discrete"
		},
		"sprint":{
			"size":1,
			"action_type":"discrete"
		}
	}
	
func set_action(action) -> void:	
	move_action = clamp(action["move_action"][0],-1.0,1.0)
	attack_action = action["attack_action"] == 1
	jump_action = action["jump_action"] == 1 and not attack_action
	quick_fall_action = action["quick_fall_action"] == 1 and not attack_action
	stance_change = action["stance_change"] == 1 and not attack_action
	double_jump = action["double_jump"] == 1 and not attack_action
	sprint = action["sprint"] == 1 and not attack_action

