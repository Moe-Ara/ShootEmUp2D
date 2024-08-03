extends Collectable


@onready var animation_player = $AnimatedSprite2D
@export var health_amount: int = 20

func _ready() -> void:
	super._ready()
	animation_player.play("default")


func collect(player: Node) -> void:
	if player.has_method("heal"):
		player.call("heal", health_amount)
	queue_free()
