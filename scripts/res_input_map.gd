@tool
class_name EZInputMap extends Resource

@export var _update_map : bool : 
	set(val): 
		update_map()

@export var map: Dictionary 

@export_group("filter settings")
@export var prefix_ignore_list : Array[String] = []


func _init() -> void:
	if map == null: 
		update_map()


func update_map(): 
	InputMap.load_from_project_settings()
	
	var new_map = {}
	for action in InputMap.get_actions(): 
		if passed_filter_check(action): 
			
			# copy contents of existing map or create new and fill with events
			if map.has(action): 
				new_map[action] = map.get(action)
			else: 
				new_map[action] = []
				for event in InputMap.action_get_events(action): 
					new_map.get(action).append(event)
	
	map = new_map


func update_project_map(): 
	InputMap.load_from_project_settings()
	
	if !prefix_ignore_list: 
		prefix_ignore_list = []
	
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
		update_project_map()


func action_get_events(action) -> Array: 
	
	if !map.has(action): return []
	return map.get(action)


func passed_filter_check(action) -> bool:  
	var split = action.split("_")
	if prefix_ignore_list.has(split[0]): return false 
	
	return true 


func action_erase_event(action, event):
	if !map.has(action): return 
	map.get(action).erase(event)
	
	
func action_add_event(action, event): 
	if !map.has(action): return 
	map.get(action).append(event)
