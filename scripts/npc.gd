class_name NPC
extends StaticBody2D
## A character the player can talk to. The world fills these in from its NPCS table.

const SKIN: Color = Color(0.95, 0.79, 0.63)
const EYES: Color = Color(0.1, 0.1, 0.1)

@export var display_name: String = "Villager"
@export var color: Color = Color(0.88, 0.63, 0.25)
@export var lines: Array[String] = []


func _draw() -> void:
	draw_rect(Rect2(-6, -7, 12, 14), color)
	draw_rect(Rect2(-4, -5, 8, 5), SKIN)
	draw_rect(Rect2(-3, -4, 1, 2), EYES)
	draw_rect(Rect2(2, -4, 1, 2), EYES)
