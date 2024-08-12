extends Attackable

class_name Enemy2D

@onready var Properties=$Properties
var speed = 600
var attack_damage
var attack_range
var player
@export var slowdown_amount: float = 0.7  # Amount to reduce speed by on hit
@export var slowdown_duration: float = 1.0  # Duration of the slowdown effect
var drop_chance:float=0.5
var original_speed: float
var is_slowed: bool = false
var slowdown_timer: Timer
var hit_rate
enum{
	IDLE,
	ATTACK,
	HIT,
	DEAD,
	SURROUND
}
var dropped_item:bool=false #to make sure drop_item_on_death() only gets called once
@export var state= ATTACK
@export var item_drops: Array = [
	preload("res://Scenes/ammo.tscn")
]
func _ready():
	init(Properties.health)
	attack_damage=Properties.attack_damage
	attack_range=Properties.attack_range
	original_speed=Properties.Speed
	speed=Properties.Speed
	hit_rate=Properties.hit_rate
	drop_chance=Properties.drop_chance
	slowdown_timer = Timer.new()
	add_child(slowdown_timer)
	slowdown_timer.wait_time = slowdown_duration
	slowdown_timer.one_shot = true
	slowdown_timer.timeout.connect(_on_slowdown_timeout)
	if animated_sprite:
		animated_sprite.play("idle")
		
func _physics_process(delta):		
	match state:
		ATTACK:
			move(player.global_position,delta)
		HIT:
			move(player.global_position,delta)
			hit(player,delta)
		DEAD:
			velocity=Vector2.ZERO
		SURROUND:
			surround_player(delta)
				
func _process(delta):
	handle_states()
	match state:
		ATTACK:
			animated_sprite.play("walk")
		HIT:
			animated_sprite.play("attack")
		DEAD:
			handle_death(delta)
		IDLE:
			animated_sprite.play("idle")
		SURROUND:
			animated_sprite.play("walk")
	
			
			
func move(target,delta):
	var direction= (target -global_position ).normalized()
	var desired_velocity=direction*speed
	var steering= (desired_velocity-velocity)*delta*2.5
	velocity+=steering
	move_and_slide()



func hit(target,delta):
	hit_rate-=delta
	if hit_rate<0:
		if target.has_method("take_damage"):
			target.call("take_damage",attack_damage)
		hit_rate=1.0

func handle_states():
	if is_dead:
		state=DEAD
		drop_items_on_death() 
		return
	if not player.is_dead:
		if (player.global_position - global_position).length() <player.get_node("AttackArea").get_child(0,false).shape.radius:
			state=HIT
		elif (player.global_position - global_position).length() <player.get_node("AttackArea").get_child(0,false).shape.radius * 5:
			state = SURROUND
		else:
			state=ATTACK
	else:
		state=IDLE

func take_damage(damage:int):
	super.take_damage(damage)
	_slow_down()

func _slow_down() -> void:
	if not is_slowed:
		is_slowed = true
		speed *= slowdown_amount  # Reduce the speed
		slowdown_timer.start()   # Start the slowdown timer

func _on_slowdown_timeout() -> void:
	speed = original_speed  # Restore the original speed
	is_slowed = false

	
func drop_items_on_death():
	if dropped_item:
		return
	print("yo")
	if item_drops.size() > 0:
		dropped_item=true
		var actual_drop_chance = drop_chance
		var rand = randf() 

		if rand < actual_drop_chance:
			var drop_index = randi() % item_drops.size()  
			var item_instance = item_drops[drop_index].instantiate()
			item_instance.position = global_position + Vector2(1,0)
			get_parent().add_child(item_instance)  
			
func surround_player(delta):
	var desired_position = calculate_surround_position()
	move(desired_position, delta)

func calculate_surround_position() -> Vector2:
	var enemies = get_parent().get_children()
	var active_enemies = []
	
	for enemy in enemies:
		if enemy is Enemy2D  and not enemy.is_dead:
			active_enemies.append(enemy)
	
	var enemy_count = active_enemies.size()
	var index = active_enemies.find(self)
	
	if enemy_count == 0:
		return global_position 
	
	var angle_offset = index * (PI * 2 / enemy_count)
	var surround_distance = attack_range * 3  
	var surround_position = player.global_position + Vector2(cos(angle_offset), sin(angle_offset)) * surround_distance
	
	return surround_position
