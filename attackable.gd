extends CharacterBody2D
class_name Attackable
@export var health: int=100
@onready var animated_sprite = $AnimatedSprite2D

var base_health: int=100
var is_dead=false
var dead_since=3.0

func _process(delta):
	handle_death(delta)
	
func init(_health:int):
	health=_health
	base_health=_health
	
func die():
	is_dead=true
	var collider=$CollisionShape2D
	collider.queue_free()
	if animated_sprite:
		animated_sprite.play("die")
	
func take_damage(damage:int):
	health-=damage
	if health<=0:
		die()
		
func heal(amount:int):
	if (health+amount) > base_health:
		health=base_health
	else:
		health+=amount
		
func handle_death(delta):
	if(find_child("Marker2D")):
		$Marker2D.queue_free()
	if is_dead:
		dead_since-=delta
	if dead_since<=0:
		queue_free()
		
