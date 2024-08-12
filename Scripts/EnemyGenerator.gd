extends Node2D

@export var Enemies: Array = []
@onready var player = get_owner().get_node("Player")
@onready var playable_area = get_owner().get_node("Playable")  # Assuming PlayableArea is in the same scene
@onready var whiteSkeleton = preload("res://Scenes/WhiteSkeleton.tscn")
@onready var blueSkeleton = preload("res://Scenes/BlueSkeleton.tscn")
@onready var redSkeleton = preload("res://Scenes/RedSkeleton.tscn")

@export var initial_spawn_interval: float = 5.0  # Initial time between spawns in seconds
@export var min_spawn_interval: float = 1.0  # Minimum time between spawns
@export var spawn_rate_increase: float = 0.2  # Rate at which the spawn interval decreases

@export var white_skeleton_rate: float = 0.5  # Probability for spawning type 1
@export var blue_skeleton_rate: float = 0.3  # Probability for spawning type 2
@export var red_skeleton_rate: float = 0.2  # Probability for spawning type 3
@export var max_enemies: int = 200
var enemy_count: int = 0 
var current_spawn_interval: float
var spawn_timer: Timer

func _ready():
	current_spawn_interval = initial_spawn_interval
	spawn_timer = Timer.new()
	spawn_timer.timeout.connect(_on_SpawnTimer_timeout)
	add_child(spawn_timer)
	spawn_timer.start(current_spawn_interval)

func _on_SpawnTimer_timeout():
	if enemy_count < max_enemies:
		_spawn_enemy()
		_increase_spawn_rate()

func _spawn_enemy():
	var enemy_scene: PackedScene
	var rand = randf()

	if rand < white_skeleton_rate:
		enemy_scene = whiteSkeleton
	elif rand < white_skeleton_rate + blue_skeleton_rate:
		enemy_scene = blueSkeleton
	else:
		enemy_scene = redSkeleton

	var enemy_instance = enemy_scene.instantiate()
	enemy_instance.player = player

	var spawn_position = _get_random_position_within_radius_and_area()
	enemy_instance.position = spawn_position

	add_child(enemy_instance)
	enemy_count += 1

func _get_random_position_within_radius_and_area() -> Vector2:
	var max_attempts = 100  # Maximum attempts to find a valid position
	var spawn_radius = 500  # Example spawn radius around the player

	for i in range(max_attempts):
		var angle = randf() * 2 * PI
		var r = spawn_radius * sqrt(randf())
		var spawn_position = player.position + Vector2(cos(angle), sin(angle)) * r

		if _is_position_within_playable_area(spawn_position):
			return spawn_position

	# Fallback if no valid position is found within max_attempts
	return player.position

func _is_position_within_playable_area(position: Vector2) -> bool:
	var polygon_node = playable_area.get_node("CollisionPolygon2D")
	var polygon = polygon_node.polygon
	var local_position = polygon_node.to_local(position)  # Convert position to local space
	var inside = false
	var n = polygon.size()

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

func _increase_spawn_rate():
	current_spawn_interval = max(current_spawn_interval - spawn_rate_increase, min_spawn_interval)
	spawn_timer.start(current_spawn_interval)

func _on_enemy_removed():
	enemy_count -= 1
