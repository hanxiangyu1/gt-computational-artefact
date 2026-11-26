extends Node

signal state_changed(moving: bool)

# Starting values only. Tune these on the iPhone in its intended carrying position.
@export var start_threshold := 1.2
@export var stop_threshold := 0.6
@export var start_delay := 0.2
@export var stop_delay := 1.0
@export var smoothing_speed := 6.0

var moving := false
var movement_strength := 0.0
var sensor_available := false
var acceleration := Vector3.ZERO
var gyroscope := Vector3.ZERO
var _start_timer := 0.0
var _stop_timer := 0.0


func _process(delta: float) -> void:
	acceleration = Input.get_accelerometer()
	gyroscope = Input.get_gyroscope()
	var gravity := Input.get_gravity()
	var is_mobile := OS.has_feature("ios") or OS.has_feature("android")
	# A gravity reading confirms the input is active before enabling detection.
	sensor_available = is_mobile and gravity.length() > 1.0
	var strength := 0.0
	if sensor_available:
		strength = (acceleration - gravity).length()
	elif not is_mobile and Input.is_key_pressed(KEY_SPACE):
		# Hold Space on desktop to exercise exactly the same state transitions.
		strength = start_threshold + 1.0

	movement_strength = lerpf(movement_strength, strength, 1.0 - exp(-smoothing_speed * delta))
	_update_state(delta)


func _update_state(delta: float) -> void:
	if not moving:
		_start_timer = _start_timer + delta if movement_strength >= start_threshold else 0.0
		if _start_timer >= start_delay:
			_set_moving(true)
	else:
		_stop_timer = _stop_timer + delta if movement_strength <= stop_threshold else 0.0
		if _stop_timer >= stop_delay:
			_set_moving(false)


func _set_moving(value: bool) -> void:
	moving = value
	_start_timer = 0.0
	_stop_timer = 0.0
	state_changed.emit(moving)
