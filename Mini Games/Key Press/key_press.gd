extends Node2D

## Frequency determines the time in-between key press events
@export var frequency = 3
@export var speed = 3

@onready var timer: Timer = $Timer
@onready var qte_event: PackedScene = preload("res://Objects/key_qte.tscn")

signal qte_success(qte_cleared: TextureProgressBar)

var valid_qte_actions = ["up", "down", "left", "right", "peek_L", "peek_R"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.wait_time = frequency
	randi_range(0, 10)

# process. if timer is stopped, start timer with random time (relative to frequency)
# this creates new qte via add_new_qte()

func _input(event) -> void:
	if event is InputEventKey:
		if event.pressed and not event.echo:
			var key_pressed = OS.get_keycode_string(event.keycode)
			scan_active_qtes(key_pressed)

func scan_active_qtes(key: String) -> void:
	var all_active = get_tree().get_nodes_in_group("Active QTEs")
	for qte in all_active:
		if qte.key_literal == key:
			qte_success.emit(qte)
			break

func add_new_qte() -> void:
	var new_qte = qte_event.instantiate()
	# Set random position (check for existing qte positions)
	new_qte.speed = 5 # Randomize according to self.speed
	new_qte.key = "up" # Randomize according to valid_qte_actions Array
	new_qte.add_to_group("Active QTEs")
	
# Create randomization for how often a new QTE pops up using frequency (0 meaning never again)
# QTE auto-creator, randomization also should be able to randomly pick what key should be pressed and vary speed
# Create formula for positioning qtes without overlapping or going OoB
