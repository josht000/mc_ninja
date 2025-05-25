extends Node2D

var mob_scene_paths = {
    "creeper": "res://scenes/mobs/creeper.tscn",
    "skeleton": "res://scenes/mobs/skeleton.tscn",
    "zombie": "res://scenes/mobs/zombie.tscn",
    "sheep": "res://scenes/mobs/sheep.tscn"
}

var mob_scenes = {}
var spawn_timer: Timer
var game_active = false

func _ready():
    print("MC Ninja game initialized")
    
    # Load all mob scenes
    for mob_name in mob_scene_paths:
        mob_scenes[mob_name] = load(mob_scene_paths[mob_name])
    
    # Setup spawn timer
    spawn_timer = Timer.new()
    spawn_timer.wait_time = 1.0
    spawn_timer.connect("timeout", _on_spawn_timer_timeout)
    add_child(spawn_timer)
    
    # Start game
    start_game()
    
    # Connect swipe controller
    $SwipeController.connect("swipe", _on_swipe)

func start_game():
    GameManager.reset_score()
    game_active = true
    spawn_timer.start()

func _on_spawn_timer_timeout():
    if game_active:
        spawn_mob()
        
        # Gradually increase difficulty by reducing timer
        if spawn_timer.wait_time > 0.5:
            spawn_timer.wait_time -= 0.01

func spawn_mob():
    # Choose random mob type
    var mob_types = mob_scenes.keys()
    var mob_type = mob_types[randi() % mob_types.size()]
    
    # Instance the mob
    var mob = mob_scenes[mob_type].instantiate()
    add_child(mob)
    
    # Set position at bottom of screen with random X
    var viewport_rect = get_viewport_rect().size
    mob.position.x = randf_range(100, viewport_rect.x - 100)
    mob.position.y = viewport_rect.y + 50
    
    # Apply upward force with random direction
    mob.apply_central_impulse(Vector2(
        randf_range(-300, 300),
        randf_range(-1200, -800)
    ))
    
    # Add rotation
    mob.angular_velocity = randf_range(-5, 5)

func _on_swipe(start_position, end_position, direction):
    # Create a line between start and end positions
    var space_state = get_world_2d().direct_space_state
    
    # Set up physics query parameters
    var query = PhysicsRayQueryParameters2D.new()
    query.from = start_position
    query.to = end_position
    query.collision_mask = 2  # Layer for mobs
    
    # Check for intersections with mobs
    var result = space_state.intersect_ray(query)
    
    if result and result.collider.has_method("slice"):
        result.collider.slice()
        
        # Play slice sound
        # $SliceSound.play() 