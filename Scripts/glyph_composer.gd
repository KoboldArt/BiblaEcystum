extends Node

@onready var popup_window : Popup = self.get_parent()
@onready var composer_glyph : Node = self.find_child("Glyph")
@onready var definition_box : TextEdit = self.find_child("DefinitionBox")
@onready var feedback_display : RichTextLabel = self.find_child("1_IbC_FeedbackMsg")
@onready var add_btn : Button = self.find_child("AddToDictionary")
@onready var close_btn : Button = self.find_child("CloseBtn")


func _ready() -> void:
	popup_control(false)
	## Glyph Composer Resources ##
	Validator.glyph_node = composer_glyph
	Validator.definition_box = definition_box
	Validator.feedback_display = feedback_display
	
	add_btn.pressed.connect(_on_add_to_dictionary_pressed)
	close_btn.pressed.connect(popup_control.bind(false))
	
	composer_glyph.update_button_visibility(Vector3(1, 0, 0))


func popup_control(toggle : bool) -> void:
	if toggle:
		popup_window.show()
	else:
		popup_window.hide()


func _on_add_to_dictionary_pressed() -> void:
	var def_pack : Array = [definition_box.text, ""]
	var ID_pack : Array = [composer_glyph.get_meta("Glyph_ID"), ""]
	
	if Validator.validate_entry(def_pack, ID_pack, Core.comp_db, [true, false, false]):
		popup_control(false)
