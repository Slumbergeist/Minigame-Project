extends Control

# TODO: Check if randomly selected key is pre-existing (i.e. no duplicates)

## Frequency determines the time in-between key press events
@export var frequency: float = 1.0
## Speed determines how much time the QTE will be active
@export var speed: float = 2.0
## Amount caps how many times a QTE will appear
@export var amount: int = 5
## Game Enabled being set to true will begin the spawn timer. False turns off new QTEs
@export var game_enabled: bool = false

@onready var timer: Timer = $Timer
@onready var qte_event: PackedScene = preload("res://Mini Games/Key QTE/Objects/key_qte.tscn")
@onready var qte_container: HBoxContainer = $"QTE Container"

## Emitted when the QTE is successfully completed in time
signal qte_success(qte_cleared: TextureProgressBar)

var rng = RandomNumberGenerator.new()

func _ready() -> void:
	if game_enabled:
		timer_cycle()

func _input(event) -> void:
	if event is InputEventKey:
		if event.pressed and not event.echo:
			var key_pressed = OS.get_keycode_string(event.keycode)
			scan_active_qtes(key_pressed)

## Takes in a keycode and looks through all active QTEs (via "Active QTEs" group). Emits a success signal if a match is found along with the QTE instance it matched with
func scan_active_qtes(key: String) -> void:
	var all_active = get_tree().get_nodes_in_group("Active QTEs")
	for qte in all_active:
		if qte.key_literal == key:
			qte_success.emit(qte)
			break

## Creates a new QTE instance based on above variables and randomization
func add_new_qte() -> void:
	var new_qte = qte_event.instantiate()
	new_qte.speed = rng.randf_range((speed / 1.5), (speed * 1.5))
	new_qte.key = Util.random_action_selector()
	new_qte.add_to_group("Active QTEs")
	qte_container.add_child(new_qte)
	
## Activates creation of new QTE and cycles the timer for a new one to appear as well as tracking how many more may appear. At 0, it will not cycle the timer 
func timer_cycle() -> void:
	add_new_qte()
	amount -= 1
	if amount > 0:
		timer.start(rng.randf_range((frequency / 1.5), (frequency * 1.5)))
	
func _on_timer_timeout() -> void:
	# Each time the timer ends, begin cycling the timer again
	timer_cycle()
