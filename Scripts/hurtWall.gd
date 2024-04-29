extends Node2D

func _on_area_2d_body_entered(body:Node2D):
	if body is KnightPlayer and get_parent().hurtAvailable:
		get_parent().hurtAvailable = false
		get_parent().wallHurtTimer.start()
		body.freshnessCounter.resetAllWeaponFreshness()
		body.enemyCounter.totalScore = 0
		if body.curRetries == body.numberOfRetries:
			body.curRetries = 0
			body.fails += 1
			body.aiController.done = true
			body.aiController.reward -= body.restartPenalty
			body.rewardArray.append(body.aiController.reward/body.killsRequired)
			body.gameOver()
		else:
			body.enemyCounter.enemiesKilledInLv = 0
			body.curRetries+=1
			body.enemyCounter.totalScore = 0
			body.fails += 1
			body.aiController.done = true
			body.aiController.reward -= body.restartPenalty
			body.rewardArray.append(body.aiController.reward/body.killsRequired)
			body.enemies.respawnLevelEnemies(body.levelNumber)
			body.respawnAndHideEnemies()
			body.recalculateEnemyDist()
			body.resetPosition()
		
		
