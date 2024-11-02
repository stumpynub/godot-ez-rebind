@tool
extends HBoxContainer

@export var action: String :
	get: 
		return _action
	set(val): 
		_action = val
		
		if !Engine.is_editor_hint() || !is_inside_tree(): return 
		label.text = val
		_update_debug()
		
@export var input_map: EZInputMap
@export var allow_mouse_input = false
@export var existing_warning_popup = true 

@onready var label: Label = $Label
@onready var label_debug: Label = $LabelDebug
@onready var button = $Button
@onready var confirm_dialog = $ConfirmationDialog

var queued_event : InputEvent
var confirmation_queued = false
var _action: String = ""
var listening = false 
var key_string = ""


signal unlisten


func _ready():
	
	_update_debug()
	
	if input_map == null: 
		input_map = EZInputMap.new()
		input_map.resource_name = "input_map"
		input_map.update_map()
	
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
	input_map.update_project_actions()


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
				if has_existing(event): 
					confirmation_queued = true 
					confirm_dialog.popup_centered()
					queued_event = event
					return 
				
				comfirm_rebind(event)
		unlisten.emit()


func has_existing(event): 
	for a in input_map.map:
		if a != action: 
			for e in input_map.map.get(a):  
				if event.keycode == e.keycode: return true 


func comfirm_rebind(event): 
	input_map.map.erase(action)
	input_map.map[action] = []
	input_map.action_add_event(action, event)
	key_string = OS.get_keycode_string(event.physical_keycode)
	button.text = key_string
	input_map.save()


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


func _on_confirmation_dialog_confirmed() -> void:
	comfirm_rebind(queued_event)


func _on_confirmation_dialog_canceled() -> void:
	unlisten.emit()
