extends TextureProgressBar

# KeyMash requires the player to spam press the designated key in order to build up progress

var strength: float
var decay: float
var time_limit: float
var switch: bool
var frequency: float

@onready var timer: Timer = $Timer
@onready var text_edit: RichTextLabel = $TextEdit
@onready var se_success: AudioStreamPlayer = $Success
@onready var se_failure: AudioStreamPlayer = $Failure

signal mash_instance_success()
signal mash_instance_failure()

var key: String = Util.random_action_selector()
var strength_active: bool = true
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
				if strength_active:
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
		mash_success()

func mash_success() -> void:
	decay_active = false
	strength_active = false
	tint_over = Util.success_color
	mash_instance_success.emit()
	se_success.play()
	await se_success.finished
	queue_free()

func mash_failure() -> void:
	decay_active = false
	strength_active = false
	tint_over = Util.failure_color
	mash_instance_failure.emit()
	se_failure.play()
	await se_failure.finished
	queue_free()
