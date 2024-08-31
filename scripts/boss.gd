extends CharacterBody2D

@onready var boss: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var player: CharacterBody2D = $"../Player"

const SPEED = 60
var direction = -1
var state = "moving"
var attack_sequence: Array = ["attack1", "attack2", "attack3"]
var current_attack_index: int = 0
var is_near_player = false

func _ready() -> void:
	# Connect the animation_finished signal to the method
	boss.connect("animation_finished", _on_animated_sprite_2d_animation_finished)


func move(delta: float) -> void:
	state = "moving"
	if ray_cast_right.is_colliding():
		direction = -1
	if ray_cast_left.is_colliding():
		direction = 1
	
	position.x += direction * delta * SPEED
	
func play_next_attack():
	if player.global_position.x < global_position.x:
		direction = -1
	else:
		direction = 1
	
	boss.play(attack_sequence[current_attack_index])
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if direction < 0:
		boss.flip_h = true
	else:
		boss.flip_h = false
				
	is_near_player = global_position.distance_to(player.global_position) < 50
	if current_attack_index == 0 and state == "attacking":
		play_next_attack()
		
	if state == "moving" and is_near_player:
		state = "attacking"
	elif state == "moving":
		current_attack_index = 0
		move(delta)
		if direction == 0:
			boss.play("idle")
		else:
			boss.play("running")
		
	
	

func _on_animated_sprite_2d_animation_finished() -> void:
	if current_attack_index < attack_sequence.size() - 1:
		current_attack_index += 1
	else: 
		current_attack_index = 0
		
	if not is_near_player:
		state = "moving"
	elif current_attack_index < attack_sequence.size():
		play_next_attack()
	else:
		state = "moving"  # Reset to moving after the attack sequence is finished
		
	
