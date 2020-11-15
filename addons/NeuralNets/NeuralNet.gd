extends BaseNeuralNet

class_name NeuralNet

func _init(net_structure).(net_structure):
	pass

func _activate(e : float) -> float:
	return (e/(sqrt(1+pow(e,2))))

func _derivative(x : float) -> float:
	return (1 - pow(x,2))/(pow((pow(x,2)+1),2))
