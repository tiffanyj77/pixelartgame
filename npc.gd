
class_name NPC extends CharacterBody2D

@export var wander_distance: float = 100.0
var starting_position: Vector2

var cardinal_direction: Vector2 = Vector2.DOWN
var direction: Vector2 = Vector2.ZERO
var move_speed: float = 50.0
var state: String = "idle"

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D

@export var background: Sprite2D
# @export var boundary_margin: float = 8.0

@export var tilemap: TileMapLayer
@export var boundary_margin: float = 8.0

var map_bounds: Rect2

var move_timer: float = 0.0

func _ready():
    var tile_rect = tilemap.get_used_rect()
    var tile_size = Vector2(tilemap.tile_set.tile_size)

    var local_top_left = Vector2(tile_rect.position) * tile_size
    var local_bottom_right = Vector2(tile_rect.end) * tile_size

    var world_top_left = tilemap.to_global(local_top_left)
    var world_bottom_right = tilemap.to_global(local_bottom_right)

    map_bounds = Rect2(
        world_top_left.min(world_bottom_right),
        (world_bottom_right - world_top_left).abs()
    )

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
    
    
    global_position = global_position.clamp(
    map_bounds.position + Vector2.ONE * boundary_margin,
    map_bounds.end - Vector2.ONE * boundary_margin
)


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
    if state == "walk":
        # Play the walking animation
        animation_player.play("walk_" + AnimDirection())

    elif state == "idle":
        # Stop the animation
        animation_player.stop()

        # Display a static frame facing the last direction
        match cardinal_direction:
            Vector2.DOWN:
                sprite_2d.frame_coords = Vector2i(0, 0)
            Vector2.UP:
                sprite_2d.frame_coords = Vector2i(0, 3)
            Vector2.LEFT:
                sprite_2d.frame_coords = Vector2i(3, 4)
            Vector2.RIGHT:
                sprite_2d.frame_coords = Vector2i(3, 1)


func AnimDirection() -> String:
    if cardinal_direction == Vector2.UP:
        return "back"
    elif cardinal_direction == Vector2.DOWN:
        return "front"
    elif cardinal_direction == Vector2.LEFT:
        return "left"
    else:
        return "right"
