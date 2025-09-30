extends Control

## Frequency determines the time in-between key press events
@export var frequency: float = 1.0
## Speed determines how much time the QTE will be active
@export var speed: float = 1.0
## Amount caps how many times a QTE will appear
@export var amount: int = 1
## Game Enabled being set to true will begin the spawn timer. False turns off new QTEs
@export var game_enabled: bool = false

@onready var timer: Timer = $Timer
@onready var qte_event: PackedScene = preload("res://Objects/key_qte.tscn")
@onready var qte_container: HBoxContainer = $"QTE Container"

signal qte_success(qte_cleared: TextureProgressBar)

var valid_qte_actions = ["up", "down", "left", "right", "peek_L", "peek_R"]
var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if game_enabled:
		timer_cycle()

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
	new_qte.speed = rng.randf_range((speed / 1.5), (speed * 1.5))
	new_qte.key = valid_qte_actions[rng.randi_range(0, (valid_qte_actions.size() - 1))]
	new_qte.add_to_group("Active QTEs")
	qte_container.add_child(new_qte)
	
func timer_cycle() -> void:
	add_new_qte()
	amount -= 1
	if amount > 0:
		timer.start(rng.randf_range((frequency / 1.5), (frequency * 1.5)))
	
func _on_timer_timeout() -> void:
	timer_cycle()
