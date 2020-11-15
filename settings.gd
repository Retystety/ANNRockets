extends Node

var force = 5
var force_treshold = 0.5
var torque = 3
var torque_treshold = 0.1

var net_struct = [8 + 2 + 2 + 1 + 1 + 2,20,20,2]

var path = "user://net.txt"

var gen_size = 50
var gen_time = 60

var agent_scene = load("res://Rocket/Rocket.tscn")

var add_range = 0.3
var multiply_range = 0.1
