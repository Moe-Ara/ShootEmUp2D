extends Node2D

@onready var player = get_node("Player")
const chunk_scene = preload("res://chunk.tscn")
@export var chunk_size: Vector2 = Vector2(3423, 1979)
@export var load_radius: int = 2  # Set to 1 for a 3x3 grid around the player
var chunks: Dictionary = {}  # To store currently loaded chunks
var current_chunk_pos: Vector2 = Vector2.ZERO

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	_update_chunks()

func _process(delta):
	_update_chunks()

func _update_chunks() -> void:
	var player_pos = player.global_position
	var chunk_pos = screen_to_iso(player_pos)
	chunk_pos = Vector2(chunk_pos.x, chunk_pos.y)

	print("Player position: ", player_pos)  # Debug print
	print("Calculated chunk position: ", chunk_pos)  # Debug print

	# Load chunks around the player
	for x in range(-load_radius, load_radius+1):
		for y in range(-load_radius, load_radius+1):
			var chunk_coords = chunk_pos + Vector2(x, y)
			print("Chunk coordinates: ", chunk_coords)  # Debug print
			if not chunks.has(chunk_coords):
				_load_chunk(chunk_coords)

   # Unload chunks that are too far away
	var to_remove = []
	for coords in chunks.keys():
		var manhattan_distance = abs(coords.x - chunk_pos.x) + abs(coords.y - chunk_pos.y)
		if manhattan_distance > load_radius * 2:
			print("Chunk coordinates to unload: ", coords)  # Debug print
			to_remove.append(coords)

	for coords in to_remove:
		_unload_chunk(coords)


func _load_chunk(coords: Vector2) -> void:
	var chunk_instance = chunk_scene.instantiate()
	chunk_instance.position = iso_to_screen(coords)
	add_child(chunk_instance)
	move_chunk_to_bottom(chunk_instance)

	chunks[coords] = chunk_instance
	print("Loading chunk at: ", coords, " with screen position: ", chunk_instance.position)  # Debug print
	print("There are total of :",len(chunks)," Chunks")
func _unload_chunk(coords: Vector2) -> void:
	if chunks.has(coords):
		chunks[coords].queue_free()
		chunks.erase(coords)
		print("Unloading chunk at: ", coords)  # Debug print


func move_chunk_to_bottom(chunk_instance: Node):
	if chunk_instance and chunk_instance.get_parent():
		var parent = chunk_instance.get_parent()
		parent.move_child(chunk_instance, 0)  # Move to bottom if necessary

func iso_to_screen(iso_coords: Vector2) -> Vector2:
	var x = (iso_coords.x - iso_coords.y) * (chunk_size.x / 2)
	var y = (iso_coords.x + iso_coords.y) * (chunk_size.y /2)
	return Vector2(x, y)


func screen_to_iso(screen_coords: Vector2) -> Vector2:
	var x_size = chunk_size.x / 2
	var y_size = chunk_size.y / 2
	var x = int(floor(((screen_coords.x / x_size) + (screen_coords.y / y_size)) / 2))
	var y = int(floor(((screen_coords.y / y_size) - (screen_coords.x / x_size)) / 2))
	return Vector2(x, y)

func _draw():
	for coords in chunks.keys():
		var screen_pos = iso_to_screen(coords)
		draw_rect(Rect2(screen_pos, chunk_size), Color(1, 0, 0, 0.5))

