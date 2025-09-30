extends Control

# TODO: Add ability for key switching and its frequency
# TODO: Consider adding visible timer

## Strength determines how much progress is made every key press
@export var strength: float = 10.0
## Decay determines how quickly the progress regresses without player activity
@export var decay: float = 1.0
## Time limit determines how long the player has to fill the meter before they fail
@export var time_limit: float = 3.0
## Switch determines whether the key to be pressed changes throughout or not
@export var switch: bool = true
## Only applicable if switch = true. Frequency determines how often the key will change
@export var frequency: float = 2.0
## Enables the game to load
@export var game_enabled: bool = false

@onready var mash_container: HBoxContainer = $"Mash Container"
@onready var mash_event: PackedScene = preload("res://Mini Games/Key Mash/Objects/key_mash.tscn")

func _ready() -> void:
	if game_enabled:
		add_new_mash()

## Creates a new instance of the mash minigame based on above variables
func add_new_mash() -> void:
	var new_mash = mash_event.instantiate()
	new_mash.strength = strength
	new_mash.decay = decay
	new_mash.time_limit = time_limit
	new_mash.switch = switch
	new_mash.frequency = frequency
	mash_container.add_child(new_mash)
