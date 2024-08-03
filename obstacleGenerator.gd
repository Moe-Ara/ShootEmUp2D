extends Node2D
@export var chunk_size: Vector2= Vector2(3423, 1979)
@export var obstacle_scenes: Array= []

func _ready():
	pass 


func _process(delta):
	pass

func _generate_obstacle()->void:
	var obstacle_count=obstacle_scenes.size()
	for i in range(obstacle_count):
		var index=randi()%obstacle_scenes.size()
		var obstacle_scene=obstacle_scenes[index]
		var obstacle_instance=obstacle_scene.instantiate()
		obstacle_instance.position = Vector2(randf() * chunk_size.x, randf() * chunk_size.y)
		add_child(obstacle_instance)
