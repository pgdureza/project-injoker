extends AnimatedSprite2D

@onready var spell_component: AnimatedSprite2D = $"."

var original_scale = self.scale
var current_element = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.modulate = Color(1,1,1,0)

func change_element(element: String) -> void:
	if (element == "ice" || element == "wind" || element == "fire"):
		if current_element != element:
			self.modulate = Color(1,1,1,0)
			create_tween().tween_property(self, "modulate", Color(1,1,1,1), 0.2)	
			self.play(element)
			current_element = element
	else :
		self.modulate = Color(1,1,1,1)
		
		

func reset(cast_duration: float) -> void: 
	create_tween().tween_property(self, "modulate", Color(0,0,0,0), cast_duration)
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(self.scale.x * 3,self.scale.y * 3), cast_duration)
	tween.tween_callback(
		func callback():
			current_element = ""
			self.scale = original_scale
	)
	
	
	
