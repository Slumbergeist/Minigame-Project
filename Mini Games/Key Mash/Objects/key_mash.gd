extends TextureProgressBar

# KeyMash requires the player to spam press the designated key in order to build up progress

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

@onready var timer: Timer = $Timer
@onready var text_edit: RichTextLabel = $TextEdit
@onready var se_success: AudioStreamPlayer = $Success
@onready var se_failure: AudioStreamPlayer = $Failure

signal mash_instance_success()
signal mash_instance_failure()

var key: String = Util.random_action_selector()
var decay_active: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text_edit.text = Util.action_to_keycode(key)
	timer.start(time_limit)
	
func _process(delta: float) -> void:
	if decay_active:
		decay_progress()

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and not event.echo:
			var key_pressed = OS.get_keycode_string(event.keycode)
			if key_pressed == Util.action_to_keycode(key):
				boost_progress()
				
func boost_progress() -> void:
	value += strength
	
func decay_progress() -> void:
	value -= decay

func _on_timer_timeout() -> void:
	mash_failure()

func _on_value_changed(value: float) -> void:
	if value == max_value:
		timer.stop()
		decay_active = false
		mash_success()

func mash_success() -> void:
	tint_over = Util.success_color
	mash_instance_success.emit()
	se_success.play()
	await se_success.finished
	queue_free()

func mash_failure() -> void:
	tint_over = Util.failure_color
	mash_instance_failure.emit()
	se_failure.play()
	await se_failure.finished
	queue_free()
