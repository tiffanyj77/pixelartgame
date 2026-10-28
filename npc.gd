
class_name NPC extends CharacterBody2D

@export var wander_distance: float = 100.0
var starting_position: Vector2

var cardinal_direction: Vector2 = Vector2.DOWN
var direction: Vector2 = Vector2.ZERO
var move_speed: float = 50.0
var state: String = "idle"

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D

var move_timer: float = 0.0

func _ready():
    starting_position = global_position
    updateAnimation()


func _physics_process(delta):
    move_timer -= delta

    # Choose a new direction every 1-3 seconds
    if move_timer <= 0:
        choose_direction()
        move_timer = randf_range(1.0, 3.0)

    velocity = direction * move_speed

    var state_changed = set_State()
    var direction_changed = set_Direction()

    if state_changed || direction_changed:
        updateAnimation()

    move_and_slide()


func choose_direction():
    var directions = [
        Vector2.UP,
        Vector2.DOWN,
        Vector2.LEFT,
        Vector2.RIGHT,
        Vector2.ZERO
    ]

    direction = directions.pick_random()

    # Prevent NPC from walking too far from spawn
    if global_position.x >= starting_position.x + wander_distance:
        direction = Vector2.LEFT
    elif global_position.x <= starting_position.x - wander_distance:
        direction = Vector2.RIGHT

    if global_position.y >= starting_position.y + wander_distance:
        direction = Vector2.UP
    elif global_position.y <= starting_position.y - wander_distance:
        direction = Vector2.DOWN



func set_Direction() -> bool:
    var new_dir: Vector2 = cardinal_direction

    if direction == Vector2.ZERO:
        return false

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

    if new_state == state:
        return false

    state = new_state
    return true


func updateAnimation() -> void:
    var animation_name = state + "_" + AnimDirection()

    if animation_player.has_animation(animation_name):
        animation_player.play(animation_name)
    else:
        print("Missing animation: ", animation_name)


func AnimDirection() -> String:
    if cardinal_direction == Vector2.UP:
        return "back"
    elif cardinal_direction == Vector2.DOWN:
        return "front"
    elif cardinal_direction == Vector2.LEFT:
        return "left"
    else:
        return "right"
