tool
extends EditorPlugin

func _enter_tree():
	add_autoload_singleton("NeuralNetMethods","res://addons/NeuralNets/NeuralNetMethods.gd")

func _exit_tree():
	remove_autoload_singleton("NeuralNetMethods")
