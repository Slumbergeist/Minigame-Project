extends TextureProgressBar

@export var speed: float = 3.0
@export_enum("up", "down", "left", "right", "fast", "leap", "slow", "peek_L", "peek_R") var key: String = "up"
@export_enum("Unresolved", "Succeeded", "Failed") var result: String = "Unresolved"

@onready var game_controller: Node2D = $".."
@onready var text_edit: RichTextLabel = $TextEdit
@onready var timer: Timer = $Timer
@onready var se_success: AudioStreamPlayer = $Success
@onready var se_failure: AudioStreamPlayer = $Failure

var key_literal

func _ready() -> void:
	# Setting up unique signal receivers for each instance
	game_controller.qte_success.connect(qte_key_success)

	# Setting up Key display text
	var actionEvent = InputMap.action_get_events(key)
	var actionEventIndex = actionEvent[0]
	var keyName = OS.get_keycode_string(actionEventIndex.physical_keycode)
	key_literal = keyName
	text_edit.text = keyName
	
	# Setting up timer and progress bar
	value = speed * 100
	max_value = speed * 100
	timer.start(speed)

func _process(delta: float) -> void:
	value = timer.time_left * 100

func _on_timer_timeout() -> void:
	eventFailure()

func eventFailure() -> void:
	tint_over = "#aa0022a2"
	se_failure.play()
	result = "Failed"
	await se_failure.finished
	queue_free()
	
func eventSuccess() -> void:
	timer.stop()
	tint_over = "#237d00ad"
	se_success.play()
	result = "Succeeded"
	await se_success.finished
	queue_free()

func qte_key_success(qte_cleared: TextureProgressBar) -> void:
	if qte_cleared == self:
		eventSuccess()
