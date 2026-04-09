extends Node

@onready var composer_glyph : Node = self.find_child("Glyph")
@onready var definition_box : TextEdit = self.find_child("DefinitionBox")
@onready var feedback_display : RichTextLabel = self.find_child("1_IbC_FeedbackMsg")
@onready var add_btn : Button = self.find_child("AddToDictionary")
@onready var close_btn : Button = self.find_child("CloseBtn")


func _ready() -> void:
	## Glyph Composer Resources ##
	Validator.glyph_node = composer_glyph
	Validator.definition_box = definition_box
	Validator.feedback_display = feedback_display
	
	add_btn.pressed.connect(_on_add_to_dictionary_pressed)
	close_btn.pressed.connect(close_window)
	
	composer_glyph.update_button_visibility(Vector3(1, 0, 0))


func _on_add_to_dictionary_pressed() -> void:
	var def_pack : Array = [definition_box.text, ""]
	var ID_pack : Array = [composer_glyph.get_meta("Glyph_ID"), ""]
	
	if Validator.validate_entry(def_pack, ID_pack, Core.comp_db, [true, false, false]):
		close_window()


func close_window() -> void:
	get_parent().queue_free()
