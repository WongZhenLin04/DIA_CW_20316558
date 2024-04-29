extends Node2D

@onready var walkingEnemy = preload("res://Elements/enemy.tscn")
@onready var enemyCounter:EnemyCounter = get_node("Counter")
@onready var enemies = get_node("Enemies")

func _ready():
	RenderingServer.set_default_clear_color(Color.BLACK)

# unsed for now in the current format
# func _physics_process(delta):
# 	if  enemyCounter.enemiesKilled % enemyCounter.maxEnemyCount == 0:
# 		for enemy in enemies.get_children():
# 			if enemy is WalkingEnemy:
# 				enemy.respawn()

