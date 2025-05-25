extends RigidBody2D

signal sliced

@export var points: int = 10
@export var sliced_sprite: Texture2D
@export var whole_sprite: Texture2D

var is_sliced = false
var screen_size

func _ready():
    screen_size = get_viewport_rect().size
    $Sprite2D.texture = whole_sprite
    
    # Set collision shape to match sprite
    var shape = $CollisionShape2D.shape
    var sprite_size = $Sprite2D.texture.get_size()
    shape.radius = min(sprite_size.x, sprite_size.y) / 2

func _process(delta):
    # Remove if off screen
    if position.y > screen_size.y + 100:
        queue_free()

func slice():
    if is_sliced:
        return
        
    is_sliced = true
    $Sprite2D.texture = sliced_sprite
    
    # Split into two pieces
    var top_half = create_half(true)
    var bottom_half = create_half(false)
    
    get_parent().add_child(top_half)
    get_parent().add_child(bottom_half)
    
    # Add score
    GameManager.add_score(points)
    
    # Remove original
    queue_free()
    
func create_half(is_top: bool) -> RigidBody2D:
    var half = RigidBody2D.new()
    var sprite = Sprite2D.new()
    
    half.position = position
    
    sprite.texture = sliced_sprite
    sprite.region_enabled = true
    
    var texture_size = sliced_sprite.get_size()
    if is_top:
        sprite.region_rect = Rect2(0, 0, texture_size.x, texture_size.y / 2)
        half.linear_velocity = linear_velocity + Vector2(50, -200)
    else:
        sprite.region_rect = Rect2(0, texture_size.y / 2, texture_size.x, texture_size.y / 2)
        half.linear_velocity = linear_velocity + Vector2(-50, 100)
    
    half.angular_velocity = angular_velocity * 2
    half.add_child(sprite)
    
    # Auto-remove after a short time
    var timer = Timer.new()
    timer.wait_time = 2.0
    timer.one_shot = true
    timer.autostart = true
    timer.connect("timeout", half.queue_free)
    half.add_child(timer)
    
    return half 