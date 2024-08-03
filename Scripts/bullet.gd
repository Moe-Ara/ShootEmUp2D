extends RigidBody2D

@export var speed= 500
var direction = Vector2(1,0)
func _ready():
	var animated_sprite=$AnimatedSprite2D
	animated_sprite.play("default")
	mass = 0.01 

	gravity_scale = 0.0  

	linear_velocity = direction * speed
	self.body_entered.connect(_on_body_entered)

func set_direction(dir):
	direction=dir
	linear_velocity = direction * speed
	

func _on_body_entered(body: Node):
	if body and body != self:
		if body.has_method("take_damage"):
			body.call("take_damage", 10)
		queue_free()

