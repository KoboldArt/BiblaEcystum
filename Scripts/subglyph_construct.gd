extends TextureRect

enum GlyphType {NONE, HALF, QUARTER, SEPARATOR}
enum LineType {NONE, ROUND}

@export var G_Type : GlyphType = GlyphType.NONE

var Line : LineType = LineType.NONE
var line_width : float = 15.0

#@onready var input : LineEdit = self.find_child("LineEdit")

@onready var empty : Node = self.find_child("Empty")

@onready var nature : Line2D = self.find_child("Nature")
@onready var life : Line2D = self.find_child("Life")
@onready var society : Line2D = self.find_child("Society")
@onready var duty : Line2D = self.find_child("Duty")
@onready var space : Line2D = self.find_child("Space")

@onready var percept : Node = self.find_child("Perception_main")
@onready var recog : Node = self.find_child("Recognition_main")
@onready var record : Node = self.find_child("Record_main")
@onready var command : Node = self.find_child("Command_main")
@onready var action : Node = self.find_child("Action_main")

@onready var separator : Line2D = self.find_child("Separator")

var concepts : Array = []
var concepts_base_pos : Array = []
var process : Array = []


func _ready() -> void:
	concepts = [empty, nature, life, society, duty, space]
	process = [empty, percept, recog, record, command, action]
	
	clean_plate()
	
	if G_Type == GlyphType.SEPARATOR:
		self.find_child("Separator_main").visible = true
	else:
		self.find_child("Separator_main").visible = false


func clean_plate() -> void:
	for con in concepts.size():
		concepts[con].visible = false
		concepts[con].get_parent().visible = true
	
	for pro in process.size():
		process[pro].visible = false
		#process[pro].get_parent().visible = true


func change_color(color : Color) -> void:
	separator.set_default_color(color)
	
	for con in concepts.size():
		concepts[con].set_default_color(color)
	
	for pro in process.size():
		var lines = process[pro].get_children()
		for l in lines.size():
			lines[l].set_default_color(color)


func change_line_type(line : Line2D, is_separator : bool = false) -> void:
	if not is_separator:
		line.set_width(line_width)
	else:
		line.set_width(line_width * 0.85)
	
	if Line == LineType.NONE:
		line.set_joint_mode(Line2D.LINE_JOINT_BEVEL)
		line.set_begin_cap_mode(Line2D.LINE_CAP_NONE)
		line.set_end_cap_mode(Line2D.LINE_CAP_NONE)
	elif  Line == LineType.ROUND:
		line.set_joint_mode(Line2D.LINE_JOINT_ROUND)
		line.set_begin_cap_mode(Line2D.LINE_CAP_ROUND)
		line.set_end_cap_mode(Line2D.LINE_CAP_ROUND)


func modify_concept_shape(matrixID : String) -> void:
	var area : int = matrixID.substr(0, 1).to_int()
	var caste : int = matrixID.substr(2, 1).to_int()
	var type : String = matrixID.substr(3, 1)
	var size_fac : float# = 0.75
	var move_fac : float# = 32.0
	
	if type == "H":
		size_fac = 0.6875
		move_fac = 40.0
	else:
		size_fac = 0.75
		move_fac = 32.0
	
	concepts[area].visible = true
	change_line_type(concepts[area])
	
	if (area == 1 and caste == 4) or area == 4:
		resize_shape(area, Vector2(1.0, 1.0), Vector2(0.0, 0.0))
		type_size(concepts[area], type)
	elif area != 4:
		if caste == 1:
			resize_shape(area, Vector2(1.0, size_fac), Vector2(0.0, 0.0))
			type_size(concepts[area], type)
		elif caste == 2:
			resize_shape(area, Vector2(0.75, 1.0), Vector2(0.0, 0.0))
			type_size(concepts[area], type)
		elif caste == 3:
			resize_shape(area, Vector2(0.75, 1.0), Vector2(32.0, 0.0))
			type_size(concepts[area], type)
		elif caste == 4:
			resize_shape(area, Vector2(1.0, size_fac), Vector2(0.0, move_fac))
			type_size(concepts[area], type)
		else:
			return
	else:
		return


func resize_shape(index : int, m_scale : Vector2, move : Vector2) -> void:
	var shape = concepts[index]
	var base_pos = concepts[index].get_meta("Base")
	var points = shape.get_points()
	
	for point in points.size():
		var old_pos : Vector2 = base_pos[point]
		shape.set_point_position(
			point, Vector2(
				old_pos.x * m_scale.x + move.x,
				old_pos.y * m_scale.y + move.y
				)
			)


func get_process_children(matrixID : String) -> void:
	var proc : int = matrixID.substr(1, 1).to_int()
	var line_elements : Array = process[proc].get_children()
	process[proc].visible = true
	
	for e in line_elements.size():
		modify_process_rotation(line_elements[e], matrixID)


func modify_process_rotation(line : Line2D, matrixID : String) -> void:
	#var proc : int = matrixID.substr(1, 1).to_int()
	var caste : int = matrixID.substr(2, 1).to_int()
	var type : String = matrixID.substr(3, 1)
	var meta_data : String
	
	if line.has_meta("v" + matrixID):
		meta_data = "v" + matrixID
	elif line.has_meta("v" + matrixID.substr(0,2) + "0"):
		meta_data = "v" + matrixID.substr(0,2) + "0"
	elif line.has_meta("v" + matrixID.substr(0, 3)):
		meta_data = "v" + matrixID.substr(0, 3)
	else:
		meta_data = "Base"
	
	line.visible = true
	change_line_type(line)
	
	if caste == 1:
		rotation_matrix(line, 0.0, meta_data)
		type_size(line, type)
	elif caste == 2:
		rotation_matrix(line, 270.0, meta_data)
		type_size(line, type)
	elif caste == 3:
		rotation_matrix(line, 90.0, meta_data)
		type_size(line, type)
	elif caste == 4:
		rotation_matrix(line, 180.0, meta_data)
		type_size(line, type)
	else:
		return


func rotation_matrix(shape : Line2D, rot_deg : float, meta_data : String) -> void:
	var min_pos : float = 0.0
	var max_pos : float = 128.0
	var transform : Vector2
	var x : float
	var y : float
	
	var path_points = shape.get_meta(meta_data)
	
	for p in path_points.size():
		x = path_points[p].x
		y = path_points[p].y
		
		if rot_deg == 0:
			transform = Vector2(x, y)
		elif rot_deg == 90:
			transform = Vector2(max_pos - y, min_pos + x)
		elif rot_deg == 180:
			transform = Vector2(max_pos - x, max_pos - y)
		elif rot_deg == 270:
			transform = Vector2(min_pos + y, max_pos - x)
		
		shape.set_point_position(p, transform)


func type_size(shape : Line2D, type : String) -> void:
	var full_pos = shape.get_points()
	var m_scale : Vector2
	var move : Vector2
	
	if type == "":
		m_scale = Vector2(1.0, 1.0)
		shape.set_width(line_width)
	elif type == "H":
		m_scale = Vector2(1.0, 0.4)
		move = Vector2(0.0, 64 * 0.6)
		shape.set_width(line_width * 0.85)
	elif type == "Q":
		m_scale = Vector2(0.4, 0.4)
		move = Vector2(64 * 0.6, 64 * 0.6)
		shape.set_width(line_width * 0.8)
	
	for p in full_pos.size():
		shape.set_point_position(
			p,
			Vector2(
				(full_pos[p].x * m_scale.x) + move.x,
				(full_pos[p].y * m_scale.y) + move.y
				)
			)


func _on_ID_submitted(new_text: String) -> void:
	clean_plate()
	
	var type : String
	
	if G_Type == GlyphType.HALF:
		type = "H"
	elif G_Type == GlyphType.QUARTER:
		type = "Q"
	else:
		type = ""
	
	var matrix = matrix_from_database(new_text + "0000").remove_chars(",") + type
	modify_concept_shape(matrix)
	get_process_children(matrix)
	
	#modify_process_rotation(matrix)


func matrix_from_database(ID : String) -> String:
	var query = "SELECT MatrixID FROM prime_index WHERE ID MATCH '" + ID + "';"
	Core.prime_db.query(query)
	
	return Core.prime_db.query_result[0].get("MatrixID")
