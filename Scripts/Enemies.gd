extends Node

# function used to respawn all enemies of a specific level
func respawnLevelEnemies(lvNum:int):
	var level = get_child(lvNum)
	if level != null:
		for enemy in level.get_children():
			if enemy is WalkingEnemy:
				enemy.respawn()

func getCurrentLevelEnemies(lvNum:int) -> Array:
	var level = get_child(lvNum)
	var enemies: Array = []
	if level != null:
		for enemy in level.get_children():
			if enemy is WalkingEnemy:
				enemies.append(enemy)
	return enemies

func getChildrenInRange(startIndex: int, endIndex: int) -> Array:
	var children: Array = []
	for i in range(startIndex, endIndex + 1):
		for enemy in get_child(i).get_children():
			if enemy is WalkingEnemy:
				children.append(enemy)
	return children

func getAllEnemies() -> Array:
	var enemies: Array = []
	for level in get_children():
		for enemy in level.get_children():
			if enemy is WalkingEnemy:
				enemies.append(enemy)
	return enemies
	