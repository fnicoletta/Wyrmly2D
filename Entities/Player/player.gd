extends CharacterBody2D


@export var walk_speed: float = 50.0
@export var sprint_speed: float = 70.0

var current_speed: float
var can_sprint: bool = true
var _sprint_timer: float = 10
# var _sprint_cooldown: float = 5 IMPLEMENT A SPRINT COOLDOWN

@onready var sprite: Sprite2D = $Sprite2D
@onready var flashlight: PointLight2D = $Flashlight
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var flashlight_audio: AudioStreamPlayer = $Sounds/Flashlight
@onready var footsteps: AudioStreamPlayer = $Sounds/Footsteps


func _physics_process(delta: float) -> void:
	_handle_input(delta)
	_update_sprite_direction()
	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("toggle_flashlight"):
		if flashlight_audio.playing:
			flashlight_audio.stop()
		flashlight_audio.play()
		flashlight.enabled = not flashlight.enabled


func _handle_input(delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if direction == Vector2.ZERO and footsteps.playing:
		footsteps.stop()
	elif direction != Vector2.ZERO and not footsteps.playing:
		footsteps.play()
	
	if _sprint_timer <= 0:
		can_sprint = false
	else:
		can_sprint = true
	
	if Input.is_action_pressed("sprint") and can_sprint:
		footsteps.pitch_scale = 1.2
		_sprint_timer -= delta
		current_speed = sprint_speed
	else:
		footsteps.pitch_scale = 0.7
		if _sprint_timer < 100:
			_sprint_timer += delta
		current_speed = walk_speed
		
	velocity = direction * current_speed


func _update_sprite_direction() -> void:
	var mouse_position = get_global_mouse_position()
	var direction = (mouse_position - global_position).normalized()
	
	# Determine the direction based on angle
	var angle = rad_to_deg(atan2(direction.y, direction.x))
	
	if angle > -22.5 and angle <= 22.5:
		anim_player.play("LOOK_E")
	elif angle > 22.5 and angle <= 67.5:
		anim_player.play("LOOK_SE")
	elif angle > 67.5 and angle <= 112.5:
		anim_player.play("LOOK_S")
	elif angle > 112.5 and angle <= 157.5:
		anim_player.play("LOOK_SW")
	elif angle > 157.5 or angle <= -157.5:
		anim_player.play("LOOK_W")
	elif angle > -157.5 and angle <= -112.5:
		anim_player.play("LOOK_NW")
	elif angle > -112.5 and angle <= -67.5:
		anim_player.play("LOOK_N")
	elif angle > -67.5 and angle <= -22.5:
		anim_player.play("LOOK_NE")
