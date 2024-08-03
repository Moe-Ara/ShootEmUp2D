extends Area2D
class_name Collectable
@export var collectable_type: String = "generic"  
var generated_at=0
var despawn_time=60*5



func _ready() -> void:
	self.body_entered.connect(_on_body_entered)

func _process(delta):
	generated_at+=delta
	if generated_at>=despawn_time:
		self.queue_free()
		
func _on_body_entered(body: Node) -> void:
	collect(body)
	queue_free()

func collect(player: Node) -> void:
	if player.has_method("collect_collectable"):
		player.call("collect_collectable", self)
