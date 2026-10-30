class_name Player
extends CharacterBody2D
## The hero. Moves freely, faces one of four directions, and talks to the NPC in front of them.

signal interact_requested(npc: NPC)

const SPEED: float = 80.0
## How far in front of the player to look for someone to talk to.
const REACH: float = 12.0
const TUNIC: Color = Color(0.18, 0.56, 0.23)
const SKIN: Color = Color(0.95, 0.79, 0.63)
const MARKER: Color = Color(1.0, 0.85, 0.2)

var facing: Vector2 = Vector2.DOWN
## True while a dialogue or screen transition is running.
var frozen: bool = false


func _physics_process(_delta: float) -> void:
	if frozen:
		velocity = Vector2.ZERO
		return
	var input: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input * SPEED
	move_and_slide()
	if input != Vector2.ZERO:
		_set_facing(input)


func _unhandled_input(event: InputEvent) -> void:
	if frozen or not event.is_action_pressed("interact"):
		return
	var npc: NPC = _npc_in_front()
	if npc:
		get_viewport().set_input_as_handled()
		interact_requested.emit(npc)


func _draw() -> void:
	draw_rect(Rect2(-6, -7, 12, 14), TUNIC)
	draw_rect(Rect2(-4, -5, 8, 5), SKIN)
	var tip: Vector2 = facing * 6.0
	draw_rect(Rect2(tip - Vector2(1.5, 1.5), Vector2(3, 3)), MARKER)


func _set_facing(input: Vector2) -> void:
	var new_facing: Vector2
	if absf(input.x) > absf(input.y):
		new_facing = Vector2(signf(input.x), 0.0)
	else:
		new_facing = Vector2(0.0, signf(input.y))
	if new_facing != facing:
		facing = new_facing
		queue_redraw()


func _npc_in_front() -> NPC:
	var query := PhysicsPointQueryParameters2D.new()
	query.position = global_position + facing * REACH
	var hits: Array[Dictionary] = get_world_2d().direct_space_state.intersect_point(query)
	for hit: Dictionary in hits:
		var collider: Object = hit["collider"]
		if collider is NPC:
			return collider as NPC
	return null
