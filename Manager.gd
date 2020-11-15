extends Node2D

var best_dist = 0
var best_net = NeuralNet.new(Settings.net_struct)
var agent_count = 0

func _ready():
	load_net()
	new_gen()

func new_gen():
	agent_count = Settings.gen_size
	var agents = $Spawn.get_children()
	
	for agent in agents:
		if agent.position.x > best_dist:
			best_dist = agent.position.x
			best_net = agent.net
		agent.queue_free()
	
	save_net()
	$Label.text = str(best_dist)
	
	for i in Settings.gen_size -1 :
		var instance = Settings.agent_scene.instance()
		instance.position = $Spawn.position
		instance.net.data = best_net.data
		instance.manager = self
		$Spawn.call_deferred("add_child", instance)
		
	var instance = Settings.agent_scene.instance()
	instance.position = $Spawn.position
	instance.net.data = best_net.data
	instance.manager = self
	instance.best = true
	$Spawn.call_deferred("add_child", instance)
	
	$Timer.start(Settings.gen_time)

func save_net():
	var net_file = File.new()
	net_file.open(Settings.path, File.WRITE)
	net_file.store_string(NeuralNetMethods.print_net(best_net))

func load_net():
	var net_file = File.new()
	
	if net_file.file_exists(Settings.path):
		net_file.open(Settings.path, File.READ)
		var file_net = NeuralNetMethods.parse_net(net_file.get_as_text())
		best_net.data = file_net.data
	else:
		net_file.open(Settings.path, File.WRITE)
		best_net.add_random(-2,2)
		net_file.store_string(NeuralNetMethods.print_net(best_net))

func agent_end(dist,net):
	agent_count -= 1
	if (dist > best_dist):
		best_dist = dist
		best_net = net
	
	if (agent_count == 0):
		new_gen()


func _on_Timer_timeout():
	new_gen()
