class_name Player extends CharacterBody2D

var cardinal_direction : Vector2 = Vector2.DOWN
var direction : Vector2 = Vector2.ZERO
var move_speed : float = 100.0
var state : String = "idle"

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D

@export var inv: Inv


func _ready():
	pass
	
func _process(delta):
	#use vectors for coordinates (x,y)
	direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	direction.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	
	velocity = direction * move_speed #otherwise it would be really slow
	if set_State() == true || set_Direction() == true:
		updateAnimation()
	pass
func _physics_process(delta):
	move_and_slide()

func set_Direction() -> bool:
	var new_dir: Vector2 = cardinal_direction
	if direction == Vector2.ZERO:
		return false;
	
	if direction.y == 0:
		new_dir = Vector2.LEFT if direction.x < 0 else Vector2.RIGHT
	elif direction.x == 0:
		new_dir = Vector2.UP if direction.y < 0 else Vector2.DOWN
	
	if new_dir == cardinal_direction:
		return false
	
	cardinal_direction = new_dir
	return true

func set_State() -> bool:
	var new_state: String = "idle" if direction == Vector2.ZERO else "walk"
	if new_state == state :
		return false
	state = new_state
	return true

func updateAnimation() -> void:
	animation_player.play(state + "_" + AnimDirection())
	pass
	
func AnimDirection() -> String:
	if cardinal_direction == Vector2.UP:
		return "back"
	elif cardinal_direction == Vector2.DOWN:
		return "front"
	elif cardinal_direction == Vector2.LEFT:
		return "left"
	else:
		return "right"
		
	
	
