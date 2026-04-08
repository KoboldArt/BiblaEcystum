extends Node


var prime_db : SQLite
var prime_db_path = "res://Database/prime_database.db"
var comp_db : SQLite
var comp_db_path = "res://Database/comp_database.db"


var prime_lib_path : String = ("res://Database/prime_library.txt")
#var prime_lib = FileAccess
var comp_lib_path : String = ("res://Database/comp_library.txt")
#var comp_lib = FileAccess
var text_buffer : String
var split_lines : PackedStringArray

var PrimeIDs : Array
var Matrices : Array
var PrimeDefinitions : Array

var CompIDs : Array
var CompDefinitions : Array

var Matrix_Identifier : Dictionary = {
	"" = 0,
	"Nature" = 1, "Life" = 2, "Society" = 3, "Duty" = 4, "Space" = 5,
	"Perception" = 1, "Recognition" = 2, "Record" = 3, "Command" = 4, "Action" = 5,
	"Worker" = 1, "Soldier" = 2, "Scholar" = 3, "Priest" = 4
}

var lib_dictionary : Dictionary

#func _ready() -> void:
	#process_file_source()
	#setup_sql_db()
	#setup_sql_comp_db()
	


func setup_sql_db() -> void:
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
	
	prime_db.create_table("prime_dictionary", table_dict)
	
	for i in PrimeIDs.size():
		var data = {
			"ID" : PrimeIDs[i] + "0000",
			"MatrixID" : Matrices[i],
			"Definitions" : JSON.stringify(PrimeDefinitions[i])
		}
		
		prime_db.insert_row("prime_dictionary", data)


func setup_sql_comp_db() -> void:
	comp_db = SQLite.new()
	comp_db.path = comp_db_path
	
	comp_db.verbosity_level = SQLite.VerbosityLevel.NORMAL
	comp_db.open_db()
	
	var table_dict : Dictionary = {
		"ID" : {"data_type" : "text", "primary_key" : true, "auto_increment" : false},
		"Definitions" : {"data_type" : "text"}
	}
	comp_db.create_table("compound_dictionary", table_dict)
	
	for i in CompIDs.size():
		var data = {
			"ID" : CompIDs[i],
			"Definitions" : JSON.stringify(CompDefinitions[i])
		}
		
		comp_db.insert_row("compound_dictionary", data)
	
	print("Database connection successful")


func process_file_source() -> void:
	PrimeIDs.clear()
	Matrices.clear()
	PrimeDefinitions.clear()
	CompIDs.clear()
	CompDefinitions.clear()
	
	#text_buffer = prime_lib.get_file_as_string(prime_lib_path)
	split_lines = cut_to_lines(prime_lib_path)
	fragment_split_lines()
	#for i in split_lines.size():
		#split_lines[i] = split_lines[i].strip_escapes()
		#split_lines[i] = split_lines[i].remove_chars("\"")
		#split_lines[i] = split_lines[i].replace(", ", ";")
	
	process_prime_library()
	
	#text_buffer = comp_lib.get_file_as_string(comp_lib_path)
	split_lines = cut_to_lines(comp_lib_path)
	fragment_split_lines()
	process_comp_library()


func process_prime_library() -> void:
	split_lines.remove_at(0)
	
	for i in split_lines.size():
		var values : Array
		var tempVec : String
		var tempDict : Array
		
		values = split_lines[i].split(",", true, 0)
		
		PrimeIDs.append(values[0])
		
		tempVec = str(switch_values(values[1]), ",", switch_values(values[2]), ",", switch_values(values[3]))
		#tempVec = switch_values(values[2])
		#tempVec = switch_values(values[3])
		Matrices.append(tempVec)
		
		tempDict = values[4].split(";", true, 0)
		
		PrimeDefinitions.append(tempDict)


func process_comp_library() -> void:
	for i in split_lines.size():
		var values : Array
		var tempDict : Array
		
		values = split_lines[i].split(",", true, 0)
		
		CompIDs.append(values[0])

		tempDict = values[1].split(";", true, 0)
		
		CompDefinitions.append(tempDict)


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
