extends Node

# Input actions
const MOVE_LEFT = "move_left"
const MOVE_RIGHT = "move_right"
const MOVE_UP = "move_up"
const MOVE_DOWN = "move_down"
const ITEM_PICKUP = "item_pickup"
const FLASHLIGHT_TOGGLE = "flashlight_toggle"

# Signals
signal flashlight_toggle(is_on)

var is_flashlight_on: bool = false:
	set(value):
		is_flashlight_on = value
		flashlight_toggle.emit(is_flashlight_on)
