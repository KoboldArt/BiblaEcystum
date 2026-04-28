@tool
extends EditorScript

var is_dictionary_export : bool = true

var source_path : String = ("res://Database/prime_library.txt")
var source_file = FileAccess
var text_buffer : String
var split_lines : PackedStringArray
var split_data : PackedStringArray

var lib_dictionary : Dictionary

var json_string : String

var path_Save = "res://Database/symbol_lib.json"
var file_name = "symbol_lib.json"

var IDs_to_Options : bool = false
var Dictionary_Export : bool = false
var Defs_to_Options : bool = false
var SQLite_VirtualTabel : bool = false
var FillVirtualDB : bool = false
var VirtualPrime : bool = false
var AddButton : bool = false


##=================================================================##


var prime_db : SQLite
var prime_db_path = "res://Database/prime_database.db"
var comp_db : SQLite
var comp_db_path = "res://Database/comp_database.db"


var prime_lib_path : String = ("res://Database/prime_library.txt")
#var prime_lib = FileAccess
var comp_lib_path : String = ("res://Database/comp_library.txt")
#var comp_lib = FileAccess

var PrimeIDs : Array
var Matrices : Array
var PrimeDefinitions : Array
var PrimeDefStrings : Array

var CompIDs : Array
var CompDefinitions : Array
var CompDefStrings : Array

var Matrix_Identifier : Dictionary = {
	"" = 0,
	"Nature" = 1, "Life" = 2, "Society" = 3, "Duty" = 4, "Space" = 5,
	"Perception" = 1, "Recognition" = 2, "Record" = 3, "Command" = 4, "Action" = 5,
	"Worker" = 1, "Soldier" = 2, "Scholar" = 3, "Priest" = 4
}


func _run() -> void:
	#IDs_to_Options = true
	#Dictionary_Export = true
	#Defs_to_Options = true
	#SQLite_VirtualTabel = true
	#FillVirtualDB = true
	#VirtualPrime = true
	#AddButton = true
	
	
	if AddButton:
		var node = EditorInterface.get_selection().get_selected_nodes()
		var run_function = node[0]
		run_function.populate_list()
	
	
	if SQLite_VirtualTabel:
		process_file_source(", ")
		setup_sql_db("prime_dictionary")
		#setup_sql_comp_db("compound_dictionary")
	
	
	if FillVirtualDB:
		if VirtualPrime:
			setup_virtual_table(prime_db, prime_db_path, "prime_index")
			process_file_source(", ")
			setup_sql_db("prime_index")
		else:
			setup_virtual_table(comp_db, comp_db_path, "compound_index")
			process_file_source(", ")
			setup_sql_comp_db("compound_index")
	
	
	if Defs_to_Options:
		text_buffer = source_file.get_file_as_string(source_path)
		split_lines = text_buffer.split("\n", true, 0)
		split_lines.remove_at(0)
		
		for i in split_lines.size():
			split_lines[i] = split_lines[i].strip_escapes()
			split_lines[i] = split_lines[i].remove_chars("\"")
			split_lines[i] = split_lines[i].replace(", ", ";")
		
		var DefArray : Array
		
		for i in split_lines.size():
			var values : Array
			var tempDict : Array
			
			values = split_lines[i].split(",", true, 0)
			tempDict = values[4].split(";", true, 0)
			DefArray.append(tempDict)
		
		for node in EditorInterface.get_selection().get_selected_nodes():
			if node is OptionButton:
				for i in DefArray.size():
					var SubArray = DefArray[i]
					node.set_item_text(i, SubArray[0])
	
	
	if IDs_to_Options:
		text_buffer = source_file.get_file_as_string(source_path)
		split_lines = text_buffer.split("\n", true, 0)
		split_lines.remove_at(0)
		
		var IDs : Array
		
		for lines in split_lines.size():
			IDs.append(split_lines[lines].substr(0, 2))
		
		print(IDs)
		
		for node in EditorInterface.get_selection().get_selected_nodes():
			if node is OptionButton:
				for i in IDs.size():
					node.add_item(IDs[i], i)
	
	
	if Dictionary_Export:
		text_buffer = source_file.get_file_as_string(source_path)
		split_lines = text_buffer.split("\n", true, 0)
		
		
		for i in split_lines.size():
			split_lines[i] = split_lines[i].strip_escapes()
			split_lines[i] = split_lines[i].remove_chars("\"")
			split_lines[i] = split_lines[i].replace(", ", ";")
		
		if is_dictionary_export:
			process_into_Dictionary()
		else:
			process_into_StringArray()


func process_into_Dictionary() -> void:
	var keys : PackedStringArray
	keys = split_lines[0].split(",", true, 0)
	split_lines.remove_at(0)
	
	for i in split_lines.size():
		var values : PackedStringArray
		var meanings : PackedStringArray
		var temp_dict : Dictionary = {}
		
		values = split_lines[i].split(",", true, 0)
		meanings = values[4].split(";", true, 0)
		
		for k in keys.size() - 1:
			temp_dict.get_or_add(keys[k + 1], values[k + 1])
			
		temp_dict.set("Meanings", meanings)
		lib_dictionary.get_or_add(values[0], temp_dict)
	
	json_string = encode_data(lib_dictionary, true)
	
	#test_json(json_string)
	save_json(json_string)


func process_into_StringArray() -> void:
	for i in split_lines.size():
		split_data.append_array(split_lines[i].split(",", true, 0))
		var fix = split_data.size() - 1
		split_data[fix] = split_data[fix].replace(";", ", ")
		split_data.append("\n")
	
	json_string = encode_data(split_data, true)
	
	test_json(json_string)
	save_json(json_string)


func encode_data(value, full_object = false) -> String:
	#return JSON.stringify(JSON.from_native(value, full_object), "\t")
	return JSON.stringify(value, "\t", full_object)


func save_json(data) -> void:
	var output_file = FileAccess.open(path_Save, FileAccess.WRITE)
	print(data)
	output_file.store_string(data)
	output_file.close()


func test_json(source_json) -> void:
	var json = JSON.new()
	var error = json.parse(source_json)
	
	if error == OK:
		var data_received = json.data
		if typeof(data_received) == TYPE_DICTIONARY:
			print(data_received)
		else:
			print("Unexpected data")
	else:
		print("JSON Parse Error: ", json.get_error_message(), " in ", source_json, " at line ", json.get_error_line())


##=================================================================##


func setup_sql_db(table : String) -> void:
	prime_db = SQLite.new()
	prime_db.path = prime_db_path
	
	prime_db.verbosity_level = SQLite.VerbosityLevel.NORMAL
	prime_db.open_db()
	print("Database connection successful")
	
	var table_dict : Dictionary = {
		"ID" : {"data_type" : "text", "primary_key" : true, "auto_increment" : false},
		"MatrixID" : {"data_type" : "text"},
		"Definitions" : {"data_type" : "text"}
	}
	
	prime_db.create_table(table, table_dict)
	
	for i in PrimeIDs.size():
		var data = {
			"ID" : PrimeIDs[i] + "0000",
			"MatrixID" : Matrices[i],
			"Definitions" : PrimeDefStrings[i]
		}
		
		prime_db.insert_row(table, data)


func setup_sql_comp_db(table : String) -> void:
	comp_db = SQLite.new()
	comp_db.path = comp_db_path
	
	comp_db.verbosity_level = SQLite.VerbosityLevel.NORMAL
	comp_db.open_db()
	
	var table_dict : Dictionary = {
		"ID" : {"data_type" : "text", "primary_key" : true, "auto_increment" : false},
		"Definitions" : {"data_type" : "text"}
	}
	comp_db.create_table(table, table_dict)
	
	for i in CompIDs.size():
		var data = {
			"ID" : CompIDs[i],
			"Definitions" : CompDefStrings[i]
		}
		
		comp_db.insert_row(table, data)
	
	print("Database connection successful")


func setup_virtual_table(db : SQLite, db_path : String, table_name : String) -> void:
	db = SQLite.new()
	db.path = db_path
	db.verbosity_level = SQLite.VerbosityLevel.NORMAL
	db.open_db()
	var virtual_table = "CREATE VIRTUAL TABLE IF NOT EXISTS " + table_name + " USING fts5(ID, MatrixID, Definitions);"
	db.query(virtual_table)


func process_file_source(separator_type : String) -> void:
	PrimeIDs.clear()
	Matrices.clear()
	PrimeDefinitions.clear()
	CompIDs.clear()
	CompDefinitions.clear()
	
	split_lines = cut_to_lines(prime_lib_path)
	fragment_split_lines()
	
	process_prime_library(separator_type)
	
	split_lines = cut_to_lines(comp_lib_path)
	fragment_split_lines()
	process_comp_library()


func process_prime_library(separator : String) -> void:
	split_lines.remove_at(0)
	
	for i in split_lines.size():
		var values : Array
		var tempVec : String
		var tempDict : Array
		var tempDefString : String
		
		values = split_lines[i].split(",", true, 0)
		
		PrimeIDs.append(values[0])
		
		tempVec = str(switch_values(values[1]), ",", switch_values(values[2]), ",", switch_values(values[3]))
		Matrices.append(tempVec)
		
		tempDict = values[4].split(";", true, 0)
		PrimeDefinitions.append(tempDict)
		
		tempDefString = values[4].replace(";", separator)
		PrimeDefStrings.append(tempDefString)


func process_comp_library() -> void:
	for i in split_lines.size():
		var values : Array
		var tempDict : Array
		var tempDefString : String
		
		values = split_lines[i].split(",", true, 0)
		
		CompIDs.append(values[0])

		tempDict = values[1].split(";", true, 0)
		CompDefinitions.append(tempDict)
		
		tempDefString = values[1].replace(";", " ")
		CompDefStrings.append(tempDefString)


func cut_to_lines(file_path : String) -> PackedStringArray:
	text_buffer = FileAccess.get_file_as_string(file_path)
	return text_buffer.split("\n", true, 0)


func fragment_split_lines() -> void:
	for i in split_lines.size():
		split_lines[i] = split_lines[i].strip_escapes()
		split_lines[i] = split_lines[i].remove_chars("\"")
		split_lines[i] = split_lines[i].replace(", ", ";")


func switch_values(array_value : String) -> int:
	return Matrix_Identifier.get(array_value)
