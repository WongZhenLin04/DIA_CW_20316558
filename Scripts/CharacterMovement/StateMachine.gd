extends State
#Generic class to handle switching between states 
class_name StateMachine

# when a new state is used, this signal is emitted
signal transitioned(state_name)

@export var initial_state := NodePath()

#when the game is loaded set the character to the default state specified in the editor
@onready var state: State = get_node(initial_state)

func _ready() -> void:
	# pause function untill owner of the node (knight player) is fully loaded
	await owner.ready
	# Assign this instance of the statemachine to every one of its states
	for child in get_children():
		child.state_machine = self
	# Activate the initialisation function of the initial class
	state.enter()

# for unhadled inputs for the state machine delegate them to the current state
func _unhandled_input(event: InputEvent) -> void:
	state.handle_input(event)

# every frame run the update and physics update function of the current state
func _process(delta: float) -> void:
	state.update(delta)

func _physics_process(delta: float) -> void:
	state.physics_update(delta)

# function calls the current exit fucntion and then changes the active state
# a message from the previous state can be passed to the next state
# message has a default value of empty
func transition_to(target_state_name: String, msg: Dictionary = {}) -> void:
	#if the targeted node does not exists then interupt the script
	if not has_node(target_state_name):
		return
	state.exit()
	state = get_node(target_state_name)
	state.enter(msg)
	emit_signal("transitioned", state.name)
	


