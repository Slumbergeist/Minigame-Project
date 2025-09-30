extends TextureProgressBar

# See MG-QTE.gd for variable descriptions
var speed: float
var key: String

@onready var game_controller: Control = $"../../."
@onready var text_edit: RichTextLabel = $TextEdit
@onready var timer: Timer = $Timer
@onready var se_success: AudioStreamPlayer = $Success
@onready var se_failure: AudioStreamPlayer = $Failure

## Emitted when the QTE instance is successfully cleared
signal qte_instance_success()
## Emitted when the QTE instance is failed
signal qte_instance_failure()

# Holds the actual keycode (letter, number, etc)
var key_literal

func _ready() -> void:
	# Setting up unique signal receivers for each instance
	game_controller.qte_success.connect(qte_key_success)

	# Setting up Key display text
	var key_name = Util.action_to_keycode(key)
	key_literal = key_name
	text_edit.text = key_name
	
	# Setting up timer and progress bar
	value = speed * 100
	max_value = speed * 100
	timer.start(speed)

func _process(delta: float) -> void:
	value = timer.time_left * 100

func _on_timer_timeout() -> void:
	# Event fails when timer runs out of time
	eventFailure()

## On failure, it emits the failure signal and disappears
func eventFailure() -> void:
	tint_over = Util.failure_color
	qte_instance_failure.emit()
	se_failure.play()
	await se_failure.finished
	queue_free()

## On success, it freezes the timer, emits the success signal and disappears
func eventSuccess() -> void:
	timer.stop()
	tint_over = Util.success_color
	qte_instance_success.emit()
	se_success.play()
	await se_success.finished
	queue_free()

## Connects (in _ready) to MG-QTE's success signal. Upon emitting, triggers the instance success
func qte_key_success(qte_cleared: TextureProgressBar) -> void:
	if qte_cleared == self:
		eventSuccess()
