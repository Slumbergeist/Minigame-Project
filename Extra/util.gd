extends Node

var rng = RandomNumberGenerator.new()
var valid_actions = ["up", "down", "left", "right", "peek_L", "peek_R"]
var success_color = "#237d00ad"
var failure_color = "#aa0022a2"

func action_to_keycode(action: String) -> String:
	var actionEvent = InputMap.action_get_events(action)
	var actionEventIndex = actionEvent[0]
	var keycode = OS.get_keycode_string(actionEventIndex.physical_keycode)
	return keycode

func random_action_selector() -> String:
	return valid_actions[rng.randi_range(0, (valid_actions.size() - 1))]
