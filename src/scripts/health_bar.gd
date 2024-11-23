extends Control

@onready var amount : Label = $Amount

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signals.update_health.connect(on_update_health)
	
func on_update_health(value : int) -> void:
	amount.text = str(value)
