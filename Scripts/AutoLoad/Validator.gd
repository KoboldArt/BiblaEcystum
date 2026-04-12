extends Node

var definition_box : TextEdit
var feedback_display : RichTextLabel
var glyph_node : Node
var original_ID : String

var is_definition_edit : bool = false


func validate_new_ID(ID : String, old_ID : String, new_entry : bool) -> bool:
	if new_entry:
		old_ID = ""
	var search = Core.search_database(ID, old_ID, "ID")
	
	if search[0].size() > 0 or search[1].size() > 0:
		return false
	else:
		return true


func validate_new_definition(new_def : String, old_def : String, new_entry : bool) -> bool:
	if new_entry:
		old_def = ""
	var search_term : Array = new_def.split(",", true)
	var result : bool
	
	for i in search_term.size():
		var word = search_term[i]
		var def_search = Core.search_database(word, old_def, "Definitions")
		
		if def_search[0].size() > 0 or def_search[1].size() > 0:
			result = false
		else:
			result = true
		
		if not result:
			break
	
	return result


func update_database(content : String, database : SQLite, new_entry : bool) -> void:
	var parsed_data : Array = content.split(";", true)
	parsed_data[1] = parsed_data[1].strip_escapes()
	parsed_data[1] = parsed_data[1].remove_chars("\"")
	
	if new_entry:
		Core.add_to_database(parsed_data, database)
	else:
		Core.update_database(parsed_data, database)


func validate_entry(def_pack : Array, ID_pack : Array, database: SQLite, entry_type : Array) -> bool:
	feedback_display.text = ""
	var new_def : String = def_pack[0]
	var old_def : String = def_pack[1]
	var new_ID : String = ID_pack[0]
	var old_ID : String = ID_pack[1]
	
	var valid_result : bool = true
	
	var new_entry : bool = entry_type[0]
	var def_edit : bool = entry_type[1]
	var ID_edit : bool = entry_type[2]
	
	print("new entry: ", new_entry, "\n",
	"Def. edit: ", def_edit, "\n",
	"ID edit: ", ID_edit, "\n")
	
	if new_def == "":
		feedback_display.text = "[color=red]Definition can't be empty.[/color]"
		print("Definition can't be empty.")
		return false
	elif new_ID == "000000" or new_ID == "" and new_entry:
		feedback_display.text = "[color=red]You need to compose a Glyph first.[/color]"
		print("You need to compose a Glyph first.")
		return false
	else:
		if valid_result and new_entry or def_edit:
			print("Submit Definition Edit", "\n")
			valid_result = validate_new_definition(new_def, old_def, new_entry)
		
		if valid_result and new_entry or ID_edit:
			print("Submit ID Edit", "\n")
			valid_result = validate_new_ID(new_ID, old_ID, new_entry)
	
	if not valid_result:
		feedback_display.text = "[color=red]Concept or Glyph already exists in dictionary.[/color]"
		print("Concept or Glyph already exists in dictionary.")
	else :
		var CompileText = str(new_ID, ";", "\"", new_def, "\"", ";", original_ID)
		if new_entry:
			update_database(CompileText, database, true)
			feedback_display.text = "[color=white]Glyph was added to the dictionary.[/color]"
		else:
			update_database(CompileText, database, false)
	
	return valid_result
