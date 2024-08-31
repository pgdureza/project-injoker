extends CharacterBody2D


const DEFAULT_SPEED = 110.0
const JUMP_VELOCITY = -320.0
const CAST_DURATION = 1
const INVOKE_ANIMATION_DURATION = 0.3

const SPELL_COMPONENT_MAP: Array = [
	"ice",
	"wind",
	"fire"
]

@onready var mage: AnimatedSprite2D = $Mage
@onready var spell_component_1: AnimatedSprite2D = $SpellComponent1
@onready var spell_component_2: AnimatedSprite2D = $SpellComponent2
@onready var spell_component_3: AnimatedSprite2D = $SpellComponent3

# spell components determine what spell the player can cast when invoking
var spell_components = [] 

# idle casting moving rolling jumping invoking
var state = "idle"
var cast_timer = 0.0 
var speed = DEFAULT_SPEED

func handle_jumping(delta: float) -> void:
	# falling
	if not is_on_floor():
		velocity += get_gravity() * delta

	# actually jumping
	if Input.is_action_just_pressed("jump") and is_on_floor() and not state == "casting":
		velocity.y = JUMP_VELOCITY	

func handle_movement(direction: float) -> void:
	#	direction facing
	if direction > 0:
		mage.flip_h = false
	elif direction < 0:
		mage.flip_h = true
		
	#	move left or right
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	
func animate(direction: float) -> void:
	#	idle vs jumping and falling
	if state == "casting":
		mage.position.y = -8
		mage.play("casting")
	else:
		mage.position.y = -0
	
	if state != "casting":
		if is_on_floor():
				if direction == 0:
					mage.play("idle")
				else:
					mage.play("run")	
		elif velocity.y > 0 and not is_on_floor():
			mage.play("falling")
		else:
			mage.play("jump")
		
	
func change_spell_component(action: String) -> void:
	var component_size = spell_components.size()
	
	if component_size == 3:
		spell_components.pop_back()
		
	spell_components.push_front(action)
	spell_component_1.change_element(spell_components[0])
		
	if (component_size > 0):
		spell_component_2.change_element(spell_components[1])
	
	if (component_size > 1):
		spell_component_3.change_element(spell_components[2])	

func handle_casting(delta: float) -> void:
	if Input.is_action_pressed("cast_spell_1"):
		state = "casting"
	
	if state == "casting":
		cast_timer += delta
		if cast_timer < CAST_DURATION:
			speed = DEFAULT_SPEED * 0.1
		else:
			state = "idle"  # Stop casting after the duration is reached
			speed = DEFAULT_SPEED
			cast_timer = 0
			
			
func handle_invoking(): 
	if spell_components.size() == 3 and state != "casting" and Input.is_action_just_pressed("invoke"):
		spell_component_1.reset(INVOKE_ANIMATION_DURATION)
		spell_component_2.reset(INVOKE_ANIMATION_DURATION)
		spell_component_3.reset(INVOKE_ANIMATION_DURATION)
		spell_components = []
	
	if not state == "casting":
		for spell_component in SPELL_COMPONENT_MAP:
			if Input.is_action_just_pressed(spell_component):
				change_spell_component(spell_component)
			

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	
	handle_invoking()
	handle_casting(delta)
	handle_movement(direction)
	handle_jumping(delta)
	animate(direction)
	
	move_and_slide()
