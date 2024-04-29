extends CharacterBody2D

class_name Arrow

@onready var wallCheckL = get_node("WallCheckL")
@onready var wallCheckR = get_node("WallCheckR")

@onready var arrowSprite = get_node("Sprite2D")

@onready var player = get_node("../Player")

var direction = -1

var ARROW_SPEED = 800

func _ready():
	if player:
		direction = _round_number(player.lastHoriInput)
	arrowSprite.flip_h = not direction > 0.0

func _physics_process(delta):
	velocity.x = direction * ARROW_SPEED
	if wallCheckL.is_colliding() or wallCheckR.is_colliding():
		queue_free()
	move_and_slide()

func _on_arrow_hit(body:Node2D):
	if not body is Arrow:
		if body is WalkingEnemy:
			body.takeDamage(player.bowBonus,false,true)
		queue_free()

func _round_number(input: float) -> float:
	if input < 0:
		return floor(input)
	else:
		return ceil(input)
