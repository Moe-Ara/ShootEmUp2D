extends Area2D

@export var speed: float = 150.0
var direction: Vector2 = Vector2.RIGHT
var has_hit: bool = false  # To ensure the bullet hits only one enemy

@onready var animated_sprite = $AnimatedSprite2D

func _ready() -> void:
	animated_sprite.play("default")
	
	self.body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	if not has_hit:
		position += direction * speed * delta

func set_direction(dir: Vector2) -> void:
	direction = dir

func _on_body_entered(body: Node) -> void:
	if not has_hit and body and body != self:
		if body.has_method("take_damage"):
			body.call("take_damage", 5)
		has_hit = true
		queue_free()
