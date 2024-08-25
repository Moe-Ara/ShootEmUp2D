extends Marker2D
@onready var Properties=get_parent().get_node("Properties")

var original_fire_rate
var fire_rate
var player
@onready var Bullet = preload("res://Scenes/enemyBullet.tscn")
func _ready():
	original_fire_rate=Properties.fire_rate
	fire_rate=Properties.fire_rate
	pass 


func _process(delta):
	if not player:
		player=self.get_owner().player
		return
	fire(player,delta)

func fire(target,delta):
	fire_rate-=delta
	if fire_rate>0:
		return
	var bullet_instance=Bullet.instantiate()
	bullet_instance.position=self.global_position
	var direction= (target.global_position -global_position ).normalized()
		# Calculate the rotation angle based on direction
	var angle = direction.angle()
	
	# Set the bullet's rotation to face the target
	bullet_instance.rotation = angle
	bullet_instance.set_direction(direction)
	get_parent().get_parent().add_child(bullet_instance)
	fire_rate=original_fire_rate
	
	
