class_name Score
extends Control

var player : String = ""
var wins : int = 0
var kills : int = 0
var deaths : int = 0

@onready var player_label : Label = $Player
@onready var wins_label : Label = $Wins
@onready var kills_label : Label = $Kills
@onready var deaths_label : Label = $Deaths

func _ready() -> void:
	player_label.text = str(player)
	wins_label.text = str(wins)
	kills_label.text = str(kills)
	deaths_label.text = str(deaths)
