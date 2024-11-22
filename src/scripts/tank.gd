class_name Player
extends CharacterBody2D

@export var username : String
@export var speed : float = 300.0

@export var id := 1

@onready var name_label : Label = $NameLabel
@onready var player_input : PlayerInput = $PlayerInput
@onready var camera : Camera2D = $Camera2D
@onready var sprite : Sprite2D = $Sprite2D

enum State {
	IDLE,
	RUN,
	HURT,
	DEAD
}

var current_state : State = State.IDLE

func _ready() -> void:
	#Set which peer has control over the node
	name_label.text = username
	if id == multiplayer.get_unique_id():
		camera.make_current()

@rpc("any_peer", "call_local")
func set_state(state : State) -> void:
	match state:
		State.IDLE:
			self.velocity = Vector2.ZERO
		State.RUN:
			pass
		State.HURT:
			pass
		State.DEAD:
			pass
	
	current_state = state

func _physics_process(delta: float) -> void:
	sprite.flip_h = player_input.direction.x < 0
	process_state(delta)
	move_and_slide()
	
func process_state(delta : float) -> void:
	match current_state:
		State.IDLE:
			process_idle(delta)
		State.RUN:
			process_run(delta)
		State.HURT:
			pass
		State.DEAD:
			pass

func process_idle(delta : float) -> void:
	if player_input.direction != Vector2.ZERO:
		set_state.rpc(State.RUN)

func process_run(delta : float) -> void:
	if player_input.direction == Vector2.ZERO:
		set_state.rpc(State.IDLE)
	
	self.velocity = player_input.direction * speed
	

	
