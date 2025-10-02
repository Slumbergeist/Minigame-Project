extends Control

@export var game_rules: PackedScene
@export var game_enabled: bool = false
@export var number_of_keys: int = 1

# Do I store all game rules in this file?
# Or do I store game rules in another scene and import that data here?

@onready var key_container: HBoxContainer = $"Key Container"

@onready var key_instance: PackedScene = preload("uid://onf0ukg4py2y")

func _ready() -> void:
	key_prepper()
	
func key_prepper() -> void:
	for i in number_of_keys:
		key_builder()

func key_builder() -> void:
	var new_key = key_instance.instantiate()
	key_container.add_child(new_key)
	# Apply all key properties needed according to settings here and for appropriate game
