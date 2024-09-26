@tool
extends HBoxContainer

@export var input_map: EZInputMap
@export var action: String :
	get: 
		return _action
	set(val): 
		_action = val
		
		if !Engine.is_editor_hint() || !is_inside_tree(): return 
		label.text = val
		_update_debug()

@export var allow_mouse_input = false


@onready var label: Label = $Label
@onready var label_debug: Label = $LabelDebug
@onready var button = $Button


var _action: String = ""
var listening = false 
var key_string = ""


signal unlisten


func _ready():
	if !Engine.is_editor_hint():
		label_debug.hide()
		
	if !input_map: return 
		
	input_map.load_map()
		
	label.text = action
	for e in input_map.action_get_events(action): 
		if e is InputEventKey: 
			key_string = OS.get_keycode_string(e.physical_keycode)
			button.text = key_string
	
	unlisten.connect(_unlisten)
	button.pressed.connect(_pressed)
	input_map.update_project_map()


func _pressed(): 
	listening = !listening
	
	if listening:
		button.text = "listening"


func _input(event):
	if !listening: return 
	if !input_map: return 
	
	if event.is_action_pressed("ui_cancel"): 
		unlisten.emit()
		return 
	
	# unlisten when mouse input found 
	if event is InputEventMouseButton and !allow_mouse_input: 
		unlisten.emit()
		
	if event is InputEventKey: 
		for e in input_map.action_get_events(action): 
			if e is InputEventKey: 
				input_map.action_erase_event(action, e)
				input_map.action_add_event(action, event)
				key_string = OS.get_keycode_string(event.physical_keycode)
				button.text = key_string
				input_map.save()
				
		unlisten.emit()


func _unlisten(): 
	button.text = key_string
	listening = false 


func _update_debug(): 
	if is_action_found(): 
		label_debug.modulate = Color.GREEN
		label_debug.text = "found action"
	else: 
		label_debug.text = "action '%s' not found" % action
		label_debug.modulate = Color.RED
	

func is_action_found() -> bool: 
	for e in input_map.action_get_events(action): 
		if e is InputEventKey: 
			return true 
			
	return false 
