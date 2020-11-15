extends Node

func print_net(net : BaseNeuralNet) -> String:
	
	var dict = {}
	dict["layer_size"] = net.net_structure
	dict["data"] = net.data
	
	return JSON.print(dict)

func parse_net(json : String) -> BaseNeuralNet:
	
	var dict = JSON.parse(json).result
	var net = BaseNeuralNet.new(dict["layer_size"])
	
	for i in range(dict["data"].size()):
		net.data[i] = dict["data"][i]
	
	return net
