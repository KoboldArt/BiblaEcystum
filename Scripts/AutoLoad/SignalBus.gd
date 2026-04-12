extends Node

signal define_overlay_on(toggled_on : bool)
signal save_img_trigger()

func emit_define_overlay(toggled_on : bool) -> void:
	emit_signal("define_overlay_on", toggled_on)


func emit_save_img() -> void:
	emit_signal("save_img_trigger")
