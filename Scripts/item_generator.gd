extends Node2D
@export var chunk_size: Vector2= Vector2(3423, 1979)
@export var Items: Array= []
@onready var player = get_owner().get_node("Player")
const original_drop_rate=30
var drop_rate
func _ready():
	drop_rate=original_drop_rate
	_generate_items()
	pass 


func _process(delta):
	drop_rate-=delta
	if drop_rate<0:
		_generate_items()
		drop_rate=original_drop_rate

func _generate_items()->void:
	var item_count=Items.size()
	for i in range(item_count):
		var index=randi()%Items.size()
		var item_scene=Items[index]
		var item_obstacle=item_scene.instantiate()
		var radius= player.get_node("SpawnArea").get_child(0).shape.radius*player.scale.length()
		radius*=randf_range(-1.0, 1.0)
		item_obstacle.position =player.position+ Vector2(radius,  radius)
		add_child(item_obstacle)
