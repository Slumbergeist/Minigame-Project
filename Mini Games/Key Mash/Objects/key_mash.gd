extends TextureProgressBar

# KeyMash requires the player to spam press the designated key in order to build up progress

# See MG-Mash.gd for variable descriptions
var strength: float
var decay: float
var time_limit: float
var switch: bool
var frequency: float

@onready var fail_timer_bar: TextureProgressBar = $"Visual Fail Timer"
@onready var fail_timer: Timer = $"Fail Timer"
@onready var frequency_timer: Timer = $"Frequency Timer"
@onready var text_edit: RichTextLabel = $TextEdit
@onready var se_success: AudioStreamPlayer = $Success
@onready var se_failure: AudioStreamPlayer = $Failure

## Emitted when an instance of the key mashing minigame is successfully completed
signal mash_instance_success()
## Emitted when an instance of the key mashing minigame is failed 
signal mash_instance_failure()

var rng = RandomNumberGenerator.new()

var key: String = Util.random_action_selector()
# Enables the effect of the strength variable
var strength_active: bool = true
# Enables the effect of the decay variable
var decay_active: bool = true

func _ready() -> void:
	text_edit.text = Util.action_to_keycode(key)
	if switch:
		key_cycle()
	fail_timer.start(time_limit)
	fail_timer_bar.max_value = time_limit * 100
	
func _process(delta: float) -> void:
	fail_timer_bar.value = fail_timer.time_left * 100
	if decay_active:
		decay_progress()

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and not event.echo:
			var key_pressed = OS.get_keycode_string(event.keycode)
			# Checking if the correct key is being pressed for the instance of the mash minigame
			if key_pressed == Util.action_to_keycode(key):
				if strength_active:
					boost_progress()
					
## Progresses the progress bar (typically on successful button press)
func boost_progress() -> void:
	value += strength

## Regresses the progress bar (typically passively)
func decay_progress() -> void:
	value -= decay

## If switch is active, key_cycle resets the timer after each switch
func key_cycle() -> void:
	frequency_timer.start(rng.randf_range((frequency / 0.5), (frequency * 0.5)))

# If the FAIL timer runs out, the player fails
func _on_fail_timer_timeout() -> void:
	mash_failure()

# If switch is active, upon frequency_timer timout, gets a new random key to press
func _on_frequency_timer_timeout() -> void:
	if switch:
		key = Util.random_action_selector() 
		text_edit.text = Util.action_to_keycode(key)
		key_cycle()

func _on_value_changed(value: float) -> void:
	# If the progress bar value maxes out, the player succeeds
	if value == max_value:
		fail_timer.stop()
		mash_success()

## On success, it freezes any more game progress, emits the success signal, and then disappears
func mash_success() -> void:
	decay_active = false
	strength_active = false
	frequency_timer.stop()
	tint_over = Util.success_color
	mash_instance_success.emit()
	se_success.play()
	await se_success.finished
	queue_free()

## On failure, it freezes any more game progress, emits the failure signal, and then disappears
func mash_failure() -> void:
	decay_active = false
	strength_active = false
	frequency_timer.stop()
	tint_over = Util.failure_color
	mash_instance_failure.emit()
	se_failure.play()
	await se_failure.finished
	queue_free()
