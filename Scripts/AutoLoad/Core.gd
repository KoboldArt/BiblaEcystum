extends Node

var prime_db : SQLite
var prime_db_path = "res://Database/prime_database.db"
## FTS5 prime_db table: "prime_index" ##

var comp_db : SQLite
var comp_db_path = "res://Database/comp_database.db"
## FTS5 comp_db table: "compound_index" ##

## Font Control ##
signal font_changed(index : int)
var font_selector : OptionButton
var cur_font : String
var font_dict : Dictionary = {
	0 : "res://Resources/Symbols/SimpleWhite/",
	1 : "res://Resources/Symbols/SimpleBlack/",
}

var overlay_on : bool

signal new_glyph_added()
var prime_IDs : Array = []
var prime_Matrices : Array = []
var prime_Defs : Array = []
var prime_data : Array = []
var comp_IDs : Array = []
var comp_Defs : Array = []
var comp_data : Array = []

## Glyph Control ##
var glyph_string : String

func _ready() -> void:
	var final_prime_db_path = ""
	var final_comp_db_path = ""
	
	if OS.has_feature("editor"):
		final_prime_db_path = prime_db_path
		final_comp_db_path = comp_db_path
	else:
		final_prime_db_path = get_database_path("prime_database.db")
		final_comp_db_path = get_database_path("comp_database.db")
	
		if not FileAccess.file_exists(final_prime_db_path):
			var dir = DirAccess.open("res://Database/")
			dir.copy("res://Database/prime_database.db", final_prime_db_path)
		
		if not FileAccess.file_exists(final_comp_db_path):
			var dir = DirAccess.open("res://Database/")
			dir.copy("res://Database/comp_database.db", final_comp_db_path)
	
	#prime_db.path = final_prime_db_path
	
	prime_db = SQLite.new()
	prime_db.path = final_prime_db_path
	#prime_db.path = prime_db_path
	prime_db.verbosity_level = SQLite.VerbosityLevel.NORMAL
	prime_db.set_read_only(false)
	prime_db.open_db()
	
	comp_db = SQLite.new()
	comp_db.path = final_comp_db_path
	#comp_db.path = comp_db_path
	comp_db.verbosity_level = SQLite.VerbosityLevel.NORMAL
	comp_db.set_read_only(false)
	comp_db.open_db()
	
	query_database()
	
	#prime_db.compileoption_used("ENABLE_FTS5")
	#comp_db.compileoption_used("ENABLE_FTS5")
	
	cur_font = font_dict[0]


func clear_database_arrays() -> void:
	prime_IDs.clear()
	prime_Matrices.clear()
	prime_Defs.clear()
	comp_IDs.clear()
	comp_Defs.clear()


func query_database() -> void:
	var temp_array : Array
	
	clear_database_arrays()
	
	var query = "SELECT * FROM prime_index ORDER BY ID ASC;"
	prime_db.query(query)
	temp_array = prime_db.query_result
	
	for row in temp_array.size():
		var matrix : Vector3i
		
		prime_IDs.append(temp_array[row].get("ID"))
		
		var matrix_str : Array
		matrix_str = temp_array[row].get("MatrixID").split(",", false, 0)
		
		matrix.x = matrix_str[0].to_int()
		matrix.y = matrix_str[1].to_int()
		matrix.z = matrix_str[2].to_int()
		
		prime_Matrices.append(matrix)
		
		prime_Defs.append(temp_array[row].get("Definitions"))
	
	query = "SELECT * FROM compound_index ORDER BY ID ASC;"
	comp_db.query(query)
	temp_array = comp_db.query_result
	
	for row in temp_array.size():
		comp_IDs.append(temp_array[row].get("ID"))
		comp_Defs.append(temp_array[row].get("Definitions"))


func get_database_info(database : SQLite) -> Array:
	var search_table : String
	var db_temp_array : Array = []
	var db_master_array : Array = []
	
	if database == prime_db:
		search_table = "prime_index"
	elif database == comp_db:
		search_table = "compound_index"
	
	var query = "SELECT * FROM " + search_table + " ORDER BY ID ASC;"
	database.query(query)
	db_temp_array = database.query_result
	
	db_master_array = parse_database(db_temp_array)
	
	#for i in db_temp_array.size():
		#var temp_dict : Dictionary = {}
		#temp_dict.get_or_add("ID", db_temp_array[i].get("ID"))
		#
		#if database == prime_db:
			#var matrix_vec : Vector3i
			#var temp_matrix_str : Array
			#var matrix_array : Array
			#temp_matrix_str = db_temp_array[i].get("MatrixID").split(";", false, 0)
			#
			#for vec in temp_matrix_str.size():
				#var matrix_str : Array
				#matrix_str = temp_matrix_str[vec].split(",", false, 0)
				#
				#matrix_vec.x = matrix_str[0].to_int()
				#matrix_vec.y = matrix_str[1].to_int()
				#matrix_vec.z = matrix_str[2].to_int()
				#
				#matrix_array.append(matrix_vec)
			#
			#temp_dict.get_or_add("MatrixID", matrix_array)
		#
		#var temp_def : Array
		#temp_def = db_temp_array[i].get("Definitions").split(", ", true, 0)
		#
		#temp_dict.get_or_add("Definitions", temp_def)
		#
		#db_master_array.append(temp_dict)
	
	
	return db_master_array


func parse_database(db_temp_array : Array) -> Array:
	var result : Array
	
	for i in db_temp_array.size():
		var temp_dict : Dictionary = {}
		temp_dict.get_or_add("ID", db_temp_array[i].get("ID"))
		
		var matrix_vec : Vector3i
		var temp_matrix_str : Array
		var matrix_array : Array
		temp_matrix_str = db_temp_array[i].get("MatrixID").split(";", false, 0)
		
		for vec in temp_matrix_str.size():
			var matrix_str : Array
			matrix_str = temp_matrix_str[vec].split(",", false, 0)
			
			matrix_vec.x = matrix_str[0].to_int()
			matrix_vec.y = matrix_str[1].to_int()
			matrix_vec.z = matrix_str[2].to_int()
			
			matrix_array.append(matrix_vec)
		
		temp_dict.get_or_add("MatrixID", matrix_array)
		
		var temp_def : Array
		temp_def = db_temp_array[i].get("Definitions").split(", ", true, 0)
		
		temp_dict.get_or_add("Definitions", temp_def)
		
		result.append(temp_dict)
		
	return result


func search_database(value : String, old_value : String, column : String) -> Array:
	var query = "SELECT * FROM prime_index WHERE " + column + " MATCH '" + value + "' AND " + column + " != '" + old_value + "';"
	prime_db.query(query)
	
	query = "SELECT * FROM compound_index WHERE " + column + " MATCH '" + value + "' AND " + column + " != '" + old_value + "';"
	comp_db.query(query)
	
	return [prime_db.query_result, comp_db.query_result]


func get_prime_info(value : String, search_column : String, result_column : String) -> Array:
	var query = "SELECT " + result_column + " FROM prime_index WHERE " + search_column + " MATCH '" + value + "';"
	prime_db.query(query)
	
	return prime_db.query_result


func add_to_database(data_array : Array, database : SQLite) -> void:
	var data = {
		"ID" : data_array[0],
		"Definitions" : data_array[1]
	}
	
	database.insert_row("compound_index", data)
	
	emit_signal("new_glyph_added", data, false)
	
	query_database()
	print("Glyph was added to the dictionary.")


func update_comp_matrices(data_array : Array, database : SQLite) -> void:
	# data_array = [0-New_Matrix, 1-Old_ID]
	var data = {
		"MatrixID" : data_array[0]
	}
	
	var criteria = "ID = '" + data_array[1] + "'"
	
	if database == prime_db:
		return
	else:
		database.update_rows("compound_index", criteria, data)


func update_database(data_array : Array, database : SQLite) -> void:
	# data_array = [0-New_ID, 1-New_Definitions, 2-Old_ID]
	var data = {
		"ID" : data_array[0],
		"Definitions" : data_array[1]
	}
	
	var criteria = "ID = '" + data_array[2] + "'"
	
	if database == prime_db:
		database.update_rows("prime_index", criteria, data)
	else:
		database.update_rows("compound_index", criteria, data)
	
	query_database()
	print("Database updated successfully.")


func new_font_selected(index : int) -> void:
	emit_signal("font_changed", index)


func get_database_path(database_name : String) -> String:
	var exe_path = OS.get_executable_path()
	var base_dir = exe_path.get_base_dir()
	var db_folder = base_dir.path_join("data")
	
	if not DirAccess.dir_exists_absolute(db_folder):
		DirAccess.make_dir_absolute(db_folder)
	
	return db_folder.path_join(database_name)
