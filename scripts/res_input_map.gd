@tool
class_name EZInputMap extends Resource

@export var _update_and_save : bool : 
	set(val): 
		update_map()

@export var map: Dictionary 

@export_group("filter settings")
@export var prefix_ignore_list : Array[String] = []

 
@export_group("save settings")
@export_subgroup("user")
@export var enable_user_save : bool = false 

@export_subgroup("res")
@export var enable_res_save : bool = true 


@export_group("load settings")
@export var load_from_user : bool = false 


func _init() -> void:
	if map == null: 
		update_map()


func load_map(): 
	if load_from_user: 
		if ResourceLoader.exists(get_user_path()): 
			var loaded_map : EZInputMap = ResourceLoader.load(get_user_path())
			map = loaded_map.map
		else: 
			map = {}
			update_map()


func update_map(): 
	InputMap.load_from_project_settings()
	
	load_map()
	
	var new_map = {}
	for action in InputMap.get_actions():
		if passed_filter_check(action): 
			
			# copy contents of existing map or create new and fill with events
			if map.has(action) and map.get(action).size() > 0: 
				new_map[action] = map.get(action)
			else: 
				new_map[action] = []
				for event in InputMap.action_get_events(action): 
					new_map.get(action).append(event)
	
	map = new_map
	save(false)

func update_project_actions(): 
	InputMap.load_from_project_settings()
	
	for action in map.keys(): 
		if InputMap.has_action(action): 
			InputMap.erase_action(action)
			InputMap.add_action(action)
			
		for event in map.get(action): 
			InputMap.action_add_event(action, event)


func save(update=true): 
	if !resource_path.is_empty() and null and enable_res_save: 
		ResourceSaver.save(self, resource_path)
	
	# don't save if resource name isn't specified 
	if resource_name == "": 
		printerr("Error saving: resource name cannot be empty")
	
	# saves resources to user path 
	if enable_user_save:
		ResourceSaver.save(self, get_user_path())
	
	if update:
		update_project_actions()


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
	

func get_user_path() -> String: 
	return "user://" + resource_name + ".tres"
