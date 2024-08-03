extends Node2D
@export var Enemies : Array=[]
@onready var player = get_owner().get_node("Player")
@onready var whiteSkeleton= preload("res://Scenes/WhiteSkeleton.tscn")
@onready var blueSkeleton= preload("res://Scenes/BlueSkeleton.tscn")
@onready var redSkeleton= preload("res://Scenes/RedSkeleton.tscn")
var generation_rate


@export var initial_spawn_interval: float = 5.0  # Initial time between spawns in seconds
@export var min_spawn_interval: float = 1.0  # Minimum time between spawns
@export var spawn_rate_increase: float = 0.1  # Rate at which the spawn interval decreases

@export var white_skeleton_rate: float = 0.5  # Probability for spawning type 1
@export var blue_skeleton_rate: float = 0.3  # Probability for spawning type 2
@export var red_skeleton_rate: float = 0.2  # Probability for spawning type 3
@export var max_enemies: int = 100
var enemy_count: int = 0 
var current_spawn_interval: float
var spawn_timer: Timer

func _ready():
	current_spawn_interval = initial_spawn_interval
	spawn_timer = Timer.new()
	spawn_timer.timeout.connect(_on_SpawnTimer_timeout)
	# spawn_timer.connect("timeout", self, "_on_SpawnTimer_timeout")
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
	enemy_instance.player=player
	var spawn_radius = 500  
	var angle = randf() * 2 * PI
	var spawn_position = player.position + Vector2(cos(angle), sin(angle)) * spawn_radius
	enemy_instance.position = spawn_position
	add_child(enemy_instance)
	enemy_count += 1

func _increase_spawn_rate():
	current_spawn_interval = max(current_spawn_interval - spawn_rate_increase, min_spawn_interval)
	spawn_timer.start(current_spawn_interval)

func _on_enemy_removed():
	enemy_count -= 1
