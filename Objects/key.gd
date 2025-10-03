extends Control

# TODO: 
# Custom penalty sound and look

## The key associated with the instance
@export var key_label: String = "W"
## If randomize is enabled, the Key Label property will be ignored and will be randomly assigned a valid key
@export var randomize_key_label: bool = false
## How the key will be interacted with. TAP requires a single press. SPAM requires multiple button presses. HOLD requires one button press, but without releasing.
@export_enum("Tap", "Spam", "Hold") var key_type: String = "Tap"


@export_group("Progression") # -------------------------------------------
## Determines how much progress is made each key press (applies to progression key types)
@export var progress_strength: float = 5.0

@export_subgroup("Decay")
## Determines whether lack of key input regresses progress made
@export var decay: bool = false
## Determines how much progress is lost during decay sequences
@export var decay_speed: float = 0.5

@export_subgroup("Penalty")
## If enabled, will inflict a penalty if the player presses the wrong key
@export var penalty: bool = false
## Determines the penalty given to the player. TIME LOSS reduces the fail timer. PROGRESS LOSS reduces the player's accumulated progress.
@export_enum("Time Loss", "Progress Loss") var penalty_type: String = "Time Loss"
## The severity of the penalty if the penalty_type is set to "Time Loss"
@export var timer_penalty: float = 0.5
## The severity of the penalty if the penalty_type is set to "Progress Loss"
@export var progress_penalty: float = 20.0


@export_group("Timer") # -------------------------------------------
## Enables a timer that will fail the player once the time is up
@export var fail_time_limit: bool = true
## Sets the amount of time for the failure time limit
@export var fail_time_speed: float = 5.0


@export_group("Switching") # -------------------------------------------
## Will enable the key label to change throughout the game
@export var switch: bool = false
## Determines approximately how often the key will switch
@export var switch_frequency: float = 2.5


@export_group("Groups") # -------------------------------------------
## Determines whether the key is intended to be alone or with groups of keys
@export var multiple_keys: bool = false
## Determines this key's order in relation to other keys
@export_range(1, 100) var sequence: int = 1
## Determines whether the player needs to press this key or not
@export var active: bool = true


var game_over_state: bool = false
var rng = RandomNumberGenerator.new()

## Emitted upon successful key press
signal key_success()
## Emitted upon unsuccessful key press
signal key_failure()

@onready var key_label_box: RichTextLabel = $"Key Label"

@onready var progress_bar: TextureProgressBar = $Progress
@onready var fail_timer_bar: TextureProgressBar = $Timer

@onready var fail_timer: Timer = $"Timers/Fail Timer"
@onready var frequency_timer: Timer = $"Timers/Frequency Timer"

@onready var se_success: AudioStreamPlayer = $Audio/Success
@onready var se_failure: AudioStreamPlayer = $Audio/Failure


func _ready() -> void:
	set_key()
	if fail_time_limit:
		fail_timer_bar.max_value = fail_time_speed * 100
		fail_timer_bar.value = fail_time_speed * 100
		fail_timer.start(fail_time_speed)
	if switch:
		frequency_timer.start(switch_frequency)
		
func _process(delta: float) -> void:
	fail_timer_bar.value = fail_timer.time_left * 100
	if decay and not game_over_state:
		progress_bar.value -= decay_speed
		
func _input(event) -> void:
	if event is InputEventKey and not game_over_state:
		var key_pressed = OS.get_keycode_string(event.keycode)
		if key_pressed == key_label:
			if event.pressed and not event.echo:
				progress("Tap")
			elif event.pressed:
				progress("Hold")
		else:
			if penalty:
				error_penalty()
				match penalty_type:
					"Time Loss":
						var time_marker = fail_timer.time_left
						fail_timer.stop()
						if time_marker <= timer_penalty:
							key_event_failure()
						else:
							fail_timer.start(time_marker - timer_penalty)
					"Progress Loss":
						progress_bar.value -= progress_penalty
					_:
						push_warning('"%s" is not an acceptable penalty type!' % penalty_type)
			
func is_key_in_group(key: String) -> bool:
	var active_keys = get_tree().get_nodes_in_group("Active Keys")
	for instance in active_keys:
		if instance.key == key:
			return true
	return false
	
func progress(trigger: String) -> void:
	match key_type:
		"Tap":
			if trigger == "Tap":
				progress_bar.value = progress_bar.max_value
		"Hold":
			if trigger == "Hold":
				progress_bar.value += progress_strength
		"Spam":
			if trigger == "Tap":
				progress_bar.value += progress_strength
		_:
			push_warning('"%s" is not an acceptable key type!' % key_type)
	if success_check():
		key_event_success()
	
func success_check() -> bool:
	if progress_bar.value == progress_bar.max_value:
		return true
	return false
	
func key_event_success() -> void:
	game_over_state = true
	if not fail_timer.is_stopped():
		fail_timer.stop()
	elif not frequency_timer.is_stopped():
		frequency_timer.stop()
	fail_timer_bar.tint_over = Util.success_color
	key_success.emit()
	se_success.play()
	await se_success.finished
	queue_free()
	
func key_event_failure() -> void:
	game_over_state = true
	progress_bar.value = 0
	progress_bar.tint_over = Util.failure_color
	fail_timer_bar.tint_over = Util.failure_color
	key_failure.emit()
	se_failure.play()
	await se_failure.finished
	queue_free()
	
func error_penalty() -> void:
	progress_bar.tint_over = Util.failure_color
	fail_timer_bar.tint_over = Util.failure_color
	se_failure.play()
	await se_failure.finished
	progress_bar.tint_over = "#ffffff"
	fail_timer_bar.tint_over = "#ffffff"
	
func set_key() -> void:
	if randomize_key_label:
		var selected_action = Util.valid_actions[rng.randi_range(0, (Util.valid_actions.size() - 1))]
		var new_key = Util.action_to_keycode(selected_action)
		key_label = new_key
		key_label_box.text = new_key
	else:
		key_label_box.text = key_label
