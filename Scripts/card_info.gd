extends Node

enum Type {PRIME, COMPOUND}

var glyph_type : Type

## Concept = MatrixID.x, Process = MatrixID.y, Class = MatrixID.z
var MatrixID : Vector3

@onready var edit_btn : Button = self.find_child("Edit_Button")
@onready var accept_btn : Button = self.find_child("Accept_Button")
@onready var cancel_btn : Button = self.find_child("Cancel_Button")
@onready var card_def_box : RichTextLabel = self.find_child("CardDef_Box")
@onready var card_def_edit : TextEdit = self.find_child("CardDef_Edit")
@onready var glyph_display : Node = self.find_child("Glyph")
@onready var card_id_box : RichTextLabel = self.find_child("ID_Box")

var glyph_ID_buffer : String
var glyph_Def_buffer : String

var is_editing : bool = false

func _ready() -> void:
	glyph_display.is_card = true
	edit_btn.visible = true
	accept_btn.visible = false
	cancel_btn.visible = false
	card_def_edit.visible = false

func editing_glyph(toggled_on: bool) -> void:
	edit_btn.visible = not toggled_on
	accept_btn.visible = toggled_on
	cancel_btn.visible = toggled_on
	card_def_edit.visible = toggled_on
	
	if toggled_on:
		glyph_ID_buffer = glyph_display.get_meta("Glyph_ID")
		glyph_Def_buffer = card_def_box.text
		
		card_def_edit.text = card_def_box.text
		card_def_edit.grab_focus()
		if glyph_type == Type.COMPOUND:
			glyph_display.update_button_visibility(Vector3(1, 1, 1))
	else:
		glyph_display.set_meta("Glyph_ID", glyph_ID_buffer)
		glyph_display.draw_glyph()
		card_def_box.text = glyph_Def_buffer
		glyph_display.update_button_visibility(Vector3(0, 0, 0))


func _on_edit_button_pressed() -> void:
	editing_glyph(true)


func _on_accept_button_pressed() -> void:
	var update_type : Array = [false, true, true]
	var card_def_pack : Array = [card_def_edit.text, glyph_Def_buffer]
	var card_ID_pack : Array = [glyph_display.get_meta("Glyph_ID"), glyph_ID_buffer]
	var target_db : SQLite
	
	if glyph_type == Type.COMPOUND:
		target_db = Core.comp_db
	else:
		target_db = Core.prime_db
	
	if card_def_edit.text == glyph_Def_buffer:
		update_type.set(1, false)
	if glyph_display.get_meta("Glyph_ID") == glyph_ID_buffer:
		update_type.set(2, false)
	
	Validator.original_ID = glyph_ID_buffer
	
	if Validator.validate_entry(card_def_pack, card_ID_pack, target_db, update_type):
		glyph_ID_buffer = glyph_display.get_meta("Glyph_ID")
		card_id_box.text = glyph_display.get_meta("Glyph_ID")
		glyph_Def_buffer = card_def_edit.text
		editing_glyph(false)
	else:
		editing_glyph(false)

func _on_cancel_button_pressed() -> void:
	editing_glyph(false)
