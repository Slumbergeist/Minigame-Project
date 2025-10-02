extends Control

## How many key instances will be required to alternate between
@export_range(2, 5, 1, "Key instances") var num_of_alternating_keys: int = 2
## How much time the player has to complete the game before triggering a failure
@export var fail_time: float = 10.0
## While decay is true, inactivity will result in the progress regressing
@export var decay: bool = false
## If decay is active, this will determine how quickly decay takes place
@export var decay_speed: float = 1.0
## If the penalty timer is set to true, taking too long to press individual keys will lower the overall fail timer
@export var penalty_timer: bool = false
## How much time will be lost if the penalty timer is active
@export var penalty: float = 1.0
@export var game_enabled: bool = false

@onready var fail_timer: Timer = $"Fail Timer"
@onready var alt_event: PackedScene = preload("res://Mini Games/Key Alternate/Objects/key_alt.tscn")
@onready var alt_container: HBoxContainer = $"Alt Container"

## Fires when the correct key is successfully pressed
signal correct_key_pressed()

var rng = RandomNumberGenerator.new()

func _ready() -> void:
	assemble_minigame()
	fail_timer.start(fail_time)
	
func _input(event) -> void:
	if event is InputEventKey:
		if event.pressed and not event.echo:
			correct_key_pressed.emit()
	
func assemble_minigame() -> void:
	var action_pool: Array = Util.valid_actions
	for i in num_of_alternating_keys:
		print(i)
		var selected = action_pool.pop_at(rng.randi_range(0, action_pool.size()))
		create_key(selected, (i + 1))

func create_key(action: String, sequence: int) -> void:
	var new_event = alt_event.instantiate()
	
	new_event.key = Util.action_to_keycode(action)
	new_event.sequence = sequence
	new_event.penalty_timer = penalty_timer
	new_event.penalty = penalty
	new_event.add_to_group("Existing Alt Keys")
	
	if sequence == 1:
		new_event.active = true
		
	alt_container.add_child(new_event)
	
