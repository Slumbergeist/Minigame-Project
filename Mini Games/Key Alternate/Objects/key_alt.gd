extends TextureProgressBar

@onready var text_edit: RichTextLabel = $TextEdit

# Active keys are the next one the player needs to press
var active: bool = false
var sequence: int
var key: String
var penalty_timer: bool = false
var penalty: float

func _ready() -> void:
	text_edit.text = key
	
