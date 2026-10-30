extends Node2D
## Wires the world, player, camera and dialogue together, and slides the
## camera one screen at a time when the player walks into a new room.

const HUD_HEIGHT: float = 16.0
const TRANSITION_TIME: float = 0.5
## How far the player is carried into the new room during a transition.
const TRANSITION_NUDGE: float = 10.0

var _current_room: Vector2i
var _transitioning: bool = false

@onready var world: World = $World
@onready var player: Player = $Player
@onready var camera: Camera2D = $Camera
@onready var area_label: Label = $HUD/AreaLabel
@onready var dialogue: DialogueBox = $DialogueBox


func _ready() -> void:
	_setup_input()
	player.global_position = world.player_spawn
	_current_room = world.room_at(player.global_position)
	camera.global_position = _camera_center(_current_room)
	area_label.text = world.room_name(_current_room)
	player.interact_requested.connect(_on_interact_requested)
	dialogue.finished.connect(_on_dialogue_finished)


func _process(_delta: float) -> void:
	if _transitioning:
		return
	var room: Vector2i = world.room_at(player.global_position)
	if room != _current_room:
		_change_room(room)


func _change_room(room: Vector2i) -> void:
	_transitioning = true
	player.frozen = true
	var step := Vector2(room - _current_room)
	_current_room = room
	area_label.text = world.room_name(room)
	var tween := create_tween().set_parallel(true)
	tween.tween_property(camera, "global_position", _camera_center(room), TRANSITION_TIME)
	tween.tween_property(player, "global_position", player.global_position + step * TRANSITION_NUDGE, TRANSITION_TIME)
	await tween.finished
	player.frozen = false
	_transitioning = false


## Centers the room in the area below the HUD bar.
func _camera_center(room: Vector2i) -> Vector2:
	return world.room_origin(room) + World.ROOM_SIZE / 2.0 - Vector2(0.0, HUD_HEIGHT / 2.0)


func _on_interact_requested(npc: NPC) -> void:
	player.frozen = true
	dialogue.open(npc.display_name, npc.lines)


func _on_dialogue_finished() -> void:
	player.frozen = false


## Keys are set up here so the controls work without editing the Input Map by hand.
func _setup_input() -> void:
	_add_keys("move_up", [KEY_W, KEY_UP])
	_add_keys("move_down", [KEY_S, KEY_DOWN])
	_add_keys("move_left", [KEY_A, KEY_LEFT])
	_add_keys("move_right", [KEY_D, KEY_RIGHT])
	_add_keys("interact", [KEY_SPACE, KEY_E, KEY_ENTER])


func _add_keys(action: StringName, keys: Array) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for key: Key in keys:
		var event := InputEventKey.new()
		event.physical_keycode = key
		InputMap.action_add_event(action, event)
