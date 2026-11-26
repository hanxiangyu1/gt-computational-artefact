extends Control

@onready var motion: Node = $MotionState
@onready var number: Label = $Center/Number
@onready var info: Label = $Info


func _ready() -> void:
	motion.state_changed.connect(_on_state_changed)
	_on_state_changed(motion.moving)


func _process(_delta: float) -> void:
	var source := "iPhone sensors" if OS.has_feature("ios") else "Desktop: hold SPACE to simulate movement"
	if OS.has_feature("ios") and not motion.sensor_available:
		source = "Waiting for sensor data"
	info.text = "%s\nMovement: %.2f\nAccel: %s\nGyro: %s" % [
		source, motion.movement_strength, motion.acceleration, motion.gyroscope
	]


func _on_state_changed(moving: bool) -> void:
	# Replace this display handler with animation playback when visuals are ready.
	number.text = "1" if moving else "0"
