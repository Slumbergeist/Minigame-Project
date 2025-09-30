extends Node

# Generating random number
var rng = RandomNumberGenerator.new()
# Contains all valid key actions that minigames can pull from
var valid_actions = ["up", "down", "left", "right", "peek_L", "peek_R"]
# Color tint used for success
var success_color = "#237d00ad"
# Color tint used for failure
var failure_color = "#aa0022a2"

## Takes in a key action and returns it as its keycode (as a string)
func action_to_keycode(action: String) -> String:
	var actionEvent = InputMap.action_get_events(action)
	var actionEventIndex = actionEvent[0]
	var keycode = OS.get_keycode_string(actionEventIndex.physical_keycode)
	return keycode

## Referencing valid_actions, randomly chooses one from the list
func random_action_selector() -> String:
	return valid_actions[rng.randi_range(0, (valid_actions.size() - 1))]
