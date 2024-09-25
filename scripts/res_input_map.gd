@tool
class_name EZInputMap extends Resource

@export var map: Dictionary 


func _init() -> void:
	load_map()


func load_map(): 
	InputMap.load_from_project_settings()
	
	for action in InputMap.get_actions(): 
		map[action] = []
		
		for event in InputMap.action_get_events(action): 
			map.get(action).append(event)


func update_project_inputs(): 
	InputMap.load_from_project_settings()
	
	for action in map.keys(): 
		if InputMap.has_action(action): 
			InputMap.erase_action(action)
			InputMap.add_action(action)
			
		for event in map.get(action): 
			InputMap.action_add_event(action, event)


func save(update=true): 
	
	if resource_path != null: 
		ResourceSaver.save(self, resource_path)
	
	if update:
		update_project_inputs()


func action_get_events(action) -> Array: 
	
	if !map.has(action): return []
	return map.get(action)


func action_erase_event(action, event):
	if !map.has(action): return 
	map.get(action).erase(event)
	
	
func action_add_event(action, event): 
	if !map.has(action): return 
	map.get(action).append(event)
