extends Collectable


@onready var animation_player = $AnimationPlayer
@export var ammo_amount: int = 100


func _ready() -> void:
	super._ready()
	animation_player.play("up_down")
	
func collect(player: Node) -> void:
	if player.has_method("add_ammo"):
		player.call("add_ammo", ammo_amount)
	queue_free()
