extends Window

func _ready():
	$CloseButton.pressed.connect(self.queue_free)
