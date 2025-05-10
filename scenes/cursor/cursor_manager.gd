extends Node

@onready var CURSOR:Resource = preload("res://assets/art/cursors/cursor.png")
@onready var GREEN_BLOCK:Resource = preload("res://assets/art/cursors/GreenBlockCursor.png")

var current_cursor:Resource
#var current_dragging_object:DraggableObject = null
#var current_hovering_object:DraggableObject = null
#var last_dragging_object:DraggableObject = null

func _ready() -> void:
	set_mouse_cursor(CURSOR)

#func _process(delta: float) -> void:
	#if !Input.is_action_pressed("click"):
		## TODO: This is the second iteration of my ad-hoc fix for a gamebreaking
		## bug that can cause the desktop to be un-interactable. It's definitely
		## an inefficient solution that doesn't really address the actual
		## problem, but it is good enough for now (and maybe forever)
		#if current_dragging_object != null:
			#last_dragging_object = current_dragging_object
		#current_dragging_object = null

func set_mouse_cursor(source:Resource):
	Input.set_custom_mouse_cursor(source, 0, _get_hotspot(source))
	current_cursor = source
	

func current_cursor_is(source:Resource) -> bool:
	return current_cursor == source

# _get_hotspot returns the hotspot offset for the provided custom cursor resource.
func _get_hotspot(source:Resource) -> Vector2: 
	match source:
		CURSOR:
			return Vector2.ZERO
		GREEN_BLOCK:
			return Vector2.ZERO
		_:
			return Vector2.ZERO
