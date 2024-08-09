extends Node2D

@export var chunk_size: Vector2 = Vector2(3423, 1979)
@export var Items: Array = []
@onready var player = get_owner().get_node("Player")
@onready var playable_area = get_owner().get_node("Playable")
const original_drop_rate = 30
var drop_rate

func _ready():
	drop_rate = original_drop_rate
	_generate_items()

func _process(delta):
	drop_rate -= delta
	if drop_rate < 0:
		_generate_items()
		drop_rate = original_drop_rate

func _generate_items() -> void:
	var item_count = Items.size()
	for i in range(item_count):
		var index = randi() % Items.size()
		var item_scene = Items[index]
		var item_obstacle = item_scene.instantiate()

		var spawn_position = _get_random_position_within_radius_and_area()
		item_obstacle.position = spawn_position
		add_child(item_obstacle)

func _get_random_position_within_radius_and_area() -> Vector2:
	var max_attempts = 100  # Maximum attempts to find a valid position
	var radius = player.get_node("SpawnArea").get_child(0).shape.radius * player.scale.length()

	for i in range(max_attempts):
		var angle = randf() * 2 * PI
		var r = radius * sqrt(randf())
		var spawn_position = player.position + Vector2(r * cos(angle), r * sin(angle))

		if _is_position_within_playable_area(spawn_position):
			return spawn_position

	# Fallback if no valid position is found within max_attempts
	return player.position

func _is_position_within_playable_area(position: Vector2) -> bool:
	var polygon_node = playable_area.get_node("CollisionPolygon2D")
	var polygon = polygon_node.polygon
	var local_position = polygon_node.to_local(position)  # Convert position to local space
	var n = polygon.size()
	var inside = false

	for i in range(n):
		var j = (i + 1) % n
		var xi = polygon[i].x
		var yi = polygon[i].y
		var xj = polygon[j].x
		var yj = polygon[j].y

		var intersect = ((yi > local_position.y) != (yj > local_position.y)) and (local_position.x < (xj - xi) * (local_position.y - yi) / (yj - yi) + xi)
		if intersect:
			inside = not inside

	return inside
