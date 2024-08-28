extends CharacterBody2D


const DEFAULT_SPEED = 110.0
const JUMP_VELOCITY = -320.0
const CAST_DURATION = 1.0

const INPUT_MAP: Array = [
	"ice",
	"lightning",
	"fire"
]

var spell_ingredients = [INPUT_MAP[0], INPUT_MAP[1], INPUT_MAP[2]]

@onready var mage: AnimatedSprite2D = $Mage
@onready var spell_component_1: AnimatedSprite2D = $SpellComponent1
@onready var spell_component_2: AnimatedSprite2D = $SpellComponent2
@onready var spell_component_3: AnimatedSprite2D = $SpellComponent3

var is_casting = false
var cast_timer = 0.0 
var speed = DEFAULT_SPEED

func _physics_process(delta: float) -> void:

	if is_on_floor and Input.is_action_just_pressed("invoke"):
		is_casting = true
		cast_timer = 0.0
		speed = DEFAULT_SPEED * 0.1
		
	if is_casting:
		cast_timer += delta
		if cast_timer >= CAST_DURATION:
			is_casting = false  # Stop casting after the duration is reached
			speed = DEFAULT_SPEED
		
	if not is_casting:
		for action in INPUT_MAP:
			if Input.is_action_just_pressed(action):
				spell_ingredients.pop_front()
				spell_ingredients.push_back(action)
				break

	spell_component_1.play(spell_ingredients[0])
	spell_component_2.play(spell_ingredients[1])
	spell_component_3.play(spell_ingredients[2])
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_casting:
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	
	if direction > 0:
		mage.flip_h = false
	elif direction < 0:
		mage.flip_h = true
	
	if is_on_floor():
		mage.position.y = -8
		if is_casting == true:
			mage.position.y = -16
			mage.play("casting")
		elif direction == 0:
			mage.play("idle")
		else:
			mage.play("run")	
	elif velocity.y > 0 and not is_on_floor():
		mage.play("falling")
	else:
		mage.play("jump")
		
	
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()
