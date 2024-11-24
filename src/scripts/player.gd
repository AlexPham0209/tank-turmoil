class_name Player
extends CharacterBody2D

signal death(player : Player)
var bullet : PackedScene = preload("res://src/scenes/bullet.tscn")

@export var username : String
@export var speed : float = 300.0

@export var id := 1

var bullet_path : Node2D

@onready var name_label : Label = $NameLabel
@onready var player_input : PlayerInput = $PlayerInput
@onready var camera : Camera2D = $Camera2D
@onready var aim : Node2D = $Aim
@onready var sprite : Sprite2D = $Sprite2D
@onready var bullet_spawn : Marker2D = $Aim/Marker2D
@onready var hurtbox : Hurtbox = $Hurtbox

enum State {
	WAIT,
	IDLE,
	RUN,
	HURT,
	DEAD
}

var current_state : State = State.IDLE
var max_health : int = 5
var max_bullets : int = 3

@export var health : float = 0 :
	set(value):
		health = clamp(value, 0, max_health)
		if id == multiplayer.get_unique_id():
			Signals.update_health.emit(health)
		
@export var bullets : float = 0 :
	set(value):
		bullets = clamp(value, 0, max_bullets)
		if id == multiplayer.get_unique_id():
			Signals.update_ammo.emit(bullets)

func _ready() -> void:
	health = max_health
	bullets = max_bullets
	hurtbox.take_damage.connect(on_take_damage)
	
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
			await get_tree().create_timer(1.0).timeout
			set_state(State.IDLE)
		State.DEAD:
			death.emit(self)
			queue_free()
	
	current_state = state

func _physics_process(delta: float) -> void:
	aim.rotation = player_input.mouse_position.normalized().angle()
	sprite.flip_h = player_input.direction.x < 0
	process_state(delta)
	move_and_slide()
	
	if player_input.can_shoot:
		shoot()
		
	player_input.can_shoot = false
	
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
	
func shoot() -> void:
	var instance : Bullet = bullet.instantiate()
	instance.global_position = bullet_spawn.global_position
	var direction : Vector2 = player_input.mouse_position.normalized()
	instance.rotation = direction.angle()
	instance.direction = direction
	instance.id = id
	
	if bullet_path != null:
		bullet_path.add_child(instance, true)
	
func on_take_damage(hitbox : Hitbox) -> void:
	health -= hitbox.damage

	if health <= 0:
		if id == multiplayer.get_unique_id():
			print(multiplayer.get_unique_id())
			print(hitbox.id)
			print(id)
			print()
			GameManager.increase_kills.rpc(hitbox.id)
			GameManager.increase_deaths.rpc(id)
		
		set_state.rpc(State.DEAD)
	else:
		set_state.rpc(State.HURT)
