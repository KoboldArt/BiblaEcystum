extends Node2D

@onready var TextBox : LineEdit = self.find_child("InputBox")
@onready var AddButton : Button = self.find_child("AddToDB")

var TempDB : FileAccess
var TempDB_path : String = "res://Database/read_n_write_test.txt"


func update_database(content : String) -> void:
	TempDB = FileAccess.open(TempDB_path, FileAccess.READ_WRITE)
	TempDB.seek_end(0)
	TempDB.store_string(str("\n", content))
	TempDB.close()


func _on_add_to_db_pressed() -> void:
	var TextToStore = TextBox.text
	update_database(TextToStore)
