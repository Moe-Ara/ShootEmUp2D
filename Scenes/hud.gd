extends CanvasLayer
@onready var healthBar=$HPBar
@onready var ammoCounter=$Ammo

func _ready():
	var fg_style = StyleBoxFlat.new()
	fg_style.bg_color = Color(1, 0, 0)  
	healthBar.add_theme_stylebox_override("fill", fg_style)
	
func update_health(current_health: int, max_health:int):
	healthBar.max_value= max_health
	healthBar.value=current_health

func update_ammo(current_ammo:int):
	ammoCounter.text="%d" %current_ammo
