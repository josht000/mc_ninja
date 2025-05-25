extends Node2D

signal swipe(start_position, end_position, direction)

var swipe_start_position = null
var minimum_drag = 50

func _input(event):
    if event is InputEventScreenTouch:
        if event.pressed:
            # Start swipe
            swipe_start_position = event.position
        elif swipe_start_position != null:
            # End swipe
            var swipe_end_position = event.position
            var direction = (swipe_end_position - swipe_start_position).normalized()
            var distance = swipe_start_position.distance_to(swipe_end_position)
            
            if distance > minimum_drag:
                emit_signal("swipe", swipe_start_position, swipe_end_position, direction)
                
                # Draw swipe trail effect
                draw_swipe_trail(swipe_start_position, swipe_end_position)
            
            swipe_start_position = null

func draw_swipe_trail(start_pos, end_pos):
    var trail = Line2D.new()
    trail.width = 10
    trail.default_color = Color(1, 1, 1, 0.8)
    trail.add_point(start_pos)
    trail.add_point(end_pos)
    
    add_child(trail)
    
    # Fade out and remove
    var tween = create_tween()
    tween.tween_property(trail, "default_color:a", 0.0, 0.3)
    tween.tween_callback(trail.queue_free) 