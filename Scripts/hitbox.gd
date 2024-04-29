extends Area2D

func _on_body_entered(body):
	if body is KnightPlayer:
		body.aiController.reward -= body.touchEnemyPenalty
		
