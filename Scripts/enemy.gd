extends CharacterBody2D
class_name WalkingEnemy

var direction = Vector2.LEFT

@onready var hitbox = get_node("CollisionShape2D")
@onready var hurtbox = get_node("Hitbox/CollisionPolygon2D")

@onready var enemyCounter:EnemyCounter = get_node("../../../Counter")
@onready var player: = get_node("../../../Player")

@export var spawnLocation : Vector2 = Vector2()

var isHit = false

# used when user is hitting
func takeDamage(killMethodBonus,isSlam,isBow):
	isHit = true
	enemyCounter.enemyKilled(killMethodBonus,isSlam,isBow)
	visible = false
	position = Vector2(-5000,-5000)
	player.recalculateEnemyDist()
	# Amount of reward is tied to how enemy is killed
	player.aiController.reward += enemyCounter.score

# used when enemy was hit by user
func respawn():
	isHit = false
	position = spawnLocation
	visible = true

# used when player is spawned in a different level
func hideFromPlayer():
	position = Vector2(-5000,-5000)

# used when player is in the same level
func showToPlayer():
	position = spawnLocation
