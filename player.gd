extends CharacterBody2D
@export var speed=200
@export var dash_speed=1200
@export var dash_duration=0.2
@export var dash_cooldown = 1.0  # Cooldown time in seconds
var dash_timer=0.0
var is_dashing=false
var can_dash=true
var is_hit=false

var health=100
var is_facing_right=true
var is_shooting=false
var can_shoot=true
@export var is_dead:bool=false
var fire_rate=0.1
var ammo=0

const Utils = preload("res://utils.gd")
@onready var animated_sprite= $AnimatedSprite2D
@onready var Bullet = preload("res://bulletArea.tscn")
@onready var Hands=$AnimatedSprite2D/Hands
@onready var MuzzleFlash=$AnimatedSprite2D/Hands/leftHand/WeaponR1/MuzzleFlash
@onready var Bullet_Marker=$AnimatedSprite2D/Hands/leftHand/WeaponR1/shootingJoint

func _ready():
	animated_sprite.play("idle")
func _process(delta):
	if is_dead:
		return
	handle_animations()
	
func _physics_process(delta):
	if is_dead:
		return
	handle_dash(delta)
	handle_movement(delta)
	if Input.is_action_just_pressed("dash") and not is_dashing and can_dash:
		start_dash()
			
	if Input.is_action_pressed("shoot") :
		if can_shoot:
			shoot()
	else:
		is_shooting=false
	handle_fire_rate(delta)
	handle_dash_cooldown(delta)
	
	

func start_dash():
	is_dashing=true
	dash_timer=dash_duration
	velocity=velocity.normalized()*dash_speed
	can_dash=false
	
func handle_dash(delta):
	if is_dashing:
		dash_timer-=delta
		if dash_timer<=0:
			is_dashing=false
		else:
			move_and_slide()
			return
	velocity=Vector2()
	

func handle_dash_cooldown(delta):
	dash_cooldown-=delta
	if dash_cooldown<=0:
		can_dash=true
		dash_cooldown=1.0

func handle_fire_rate(delta):
	fire_rate-=delta
	if fire_rate<=0:
		can_shoot=true
		fire_rate=0.1
		
func shoot():
	if ammo<=0:
		return
	is_shooting=true
	var bullet_instance=Bullet.instantiate()
	bullet_instance.position=Bullet_Marker.global_position
	var direction = Bullet_Marker.global_transform.x.normalized()
	bullet_instance.rotation = Hands.rotation*animated_sprite.scale.x
	bullet_instance.set_direction(direction)
	get_parent().add_child(bullet_instance)
	can_shoot=false
	ammo-=1
	
func handle_movement(delta):
	var mouse_position =get_local_mouse_position()
	var direction = Input.get_vector("move_left", "move_right","move_up","move_down")
	velocity=direction*speed
	if mouse_position.x>0.0 and not is_facing_right:
		is_facing_right=true			
		flip()
	if mouse_position.x<0.0 and is_facing_right:
		flip()
		is_facing_right=false
	move_and_slide()


func handle_animations():
	if is_shooting and ammo>0:
		MuzzleFlash.visible =true
	else:
		MuzzleFlash.visible =false
	if is_hit:
		animated_sprite.play("hit")
		is_hit=false
		return
	if is_dashing:
		animated_sprite.play("dash")
	elif velocity.length()>0 or velocity.length()<0:
		animated_sprite.play("walk")
	else:
		animated_sprite.play("idle")	
		
func flip():
	animated_sprite.scale.x*=-1	

func take_damage(damage:int):
	is_hit=true
	health-=damage
	if health<=0:
		handle_death()
		

func handle_death():
	is_dead=true
	Hands.visible=false	
	animated_sprite.play("death")
	if self.find_child("CollisionShape2D"):	
		self.find_child("CollisionShape2D").queue_free()
	return
	
func collect_collectable(collectable: Node) -> void:
	match collectable.collectable_type:
		"health":
			if collectable.has_method("health_amount"):
				heal(collectable.health_amount)
		"ammo":
			if collectable.has_method("ammo_amount"):
				add_ammo(collectable.ammo_amount)
		_:
			print("Unknown collectable type")
			

func add_ammo(amount: int) -> void:
	ammo += amount
	print(ammo)
func heal(amount: int) -> void:
	health = min(health + amount, 100)
