extends Node

@onready var input : LineEdit = self.find_child("LineEdit")

@onready var empty : Line2D = self.find_child("Empty")

@onready var nature : Line2D = self.find_child("Nature")
@onready var life : Line2D = self.find_child("Life")
@onready var society : Line2D = self.find_child("Society")
@onready var duty : Line2D = self.find_child("Duty")
@onready var space : Line2D = self.find_child("Space")

@onready var percept : Node2D = self.find_child("Perception_main")
@onready var recog : Node2D = self.find_child("Recognition_main")
@onready var record : Node2D = self.find_child("Record_main")
@onready var command : Node2D = self.find_child("Command_main")
@onready var action : Node2D = self.find_child("Action_main")

var concepts : Array = []
var concepts_base_pos : Array = []
var process : Array = []


func _ready() -> void:
	concepts = [empty, nature, life, society, duty, space]
	process = [empty, percept, recog, record, command, action]
	
	clean_plate()


func clean_plate() -> void:
	for con in concepts.size():
		concepts[con].visible = false
		concepts[con].get_parent().visible = true
	
	for pro in process.size():
		process[pro].visible = false


func modify_concept_shape(modifier : int, shape_id : int) -> void:
	if modifier == 1:
		if shape_id != 4:
			resize_shape(shape_id, Vector2(1.0, 0.75), Vector2(0.0, 0.0))
	elif modifier == 2:
		if shape_id != 4:
			resize_shape(shape_id, Vector2(0.75, 1.0), Vector2(0.0, 0.0))
	elif modifier == 3:
		if shape_id != 4:
			resize_shape(shape_id, Vector2(0.75, 1.0), Vector2(32.0, 0.0))
	elif modifier == 4:
		if shape_id == 1 or shape_id == 4:
			resize_shape(shape_id, Vector2(1.0, 1.0), Vector2(0.0, 0.0))
		else:
			resize_shape(shape_id, Vector2(1.0, 0.75), Vector2(0.0, 32.0))
	else:
		return


func resize_shape(index : int, scale_dir : Vector2, move_dir : Vector2) -> void:
	var shape = concepts[index]
	var base_pos = concepts[index].get_meta("Old_Points")
	var points = shape.get_points()
	
	for point in points.size():
		var old_pos : Vector2 = base_pos[point]
		shape.set_point_position(point, Vector2(old_pos.x * scale_dir.x + move_dir.x, old_pos.y * scale_dir.y + move_dir.y))


func modify_process_rotation(modifier : int, shape_id : int) -> void:
	if modifier == 1:
		process[shape_id].set_rotation_degrees(0.0)
	elif modifier == 2:
		process[shape_id].set_rotation_degrees(-90.0)
	elif modifier == 3:
		process[shape_id].set_rotation_degrees(90.0)
	elif modifier == 4:
		process[shape_id].set_rotation_degrees(180.0)
	else:
		return


func adjust_process_shape(base : int, modifier : int, shape_id : int) -> void:
	var shape = process[shape_id].get_children()
	
	if shape.size() > 1:
		var old_pos : PackedVector2Array = shape[1].get_meta("Old_Points")
		for point in old_pos.size():
			shape[1].set_point_position(point, old_pos[point])
		if base == 4:
			if shape_id == 2 or shape_id == 4 or shape_id == 5:
				var new_pos : PackedVector2Array = shape[1].get_meta("Dut_Points")
				for point in old_pos.size():
					shape[1].set_point_position(point, new_pos[point])
		elif base == 1:
			if shape_id == 2:
				if modifier == 2:
					var new_pos : PackedVector2Array = shape[1].get_meta("NatSo_Points")
					for point in old_pos.size():
						shape[1].set_point_position(point, new_pos[point])
				elif modifier == 3:
					var new_pos : PackedVector2Array = shape[1].get_meta("NatSc_Points")
					for point in old_pos.size():
						shape[1].set_point_position(point, new_pos[point])
		else:
			return


func half_size() -> void:
	for shape in concepts.size():
		var points = concepts[shape].get_points()
		for point in points.size():
			concepts[shape].set_point_position(point, Vector2(points[point].x, points[point].y * 0.4))
	
	for shape in process.size():
		var process_lines = process[shape].get_children()
		for line in process_lines.size():
			var points = process_lines[line].get_points()
			for point in points.size():
				process_lines[line].set_point_position(point, Vector2(points[point].x, points[point].y * 0.4 + 64))


func _on_line_edit_text_submitted(new_text: String) -> void:
	var matrix : Vector3i = Vector3i(0, 0, 0)
	matrix.x = new_text.substr(0, 1).to_int()
	matrix.y = new_text.substr(1, 1).to_int()
	matrix.z = new_text.substr(2, 1).to_int()
	
	clean_plate()
	
	concepts[matrix.x].visible = true
	process[matrix.y].visible = true
	
	modify_concept_shape(matrix.z, matrix.x)
	adjust_process_shape(matrix.x, matrix.z, matrix.y)
	modify_process_rotation(matrix.z, matrix.y)
	
	if new_text.substr(3, 1) == "H":
		half_size()
	elif new_text.substr(3, 1) == "Q":
		pass
