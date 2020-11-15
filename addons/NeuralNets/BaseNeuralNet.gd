extends Reference

class_name BaseNeuralNet

enum _args {Z,X,INPUT}
enum _bargs {Z,Y,ERROR}
enum _cargs {Z,X,ERROR,FACTOR}

var net_structure : Array = [] setget _net_structure_set, _net_structure_get
var data : Array = [] setget _data_set, _data_get
var neuron_data : Array = [] setget _neuron_data_set, _neuron_data_get

func _net_structure_set(set : Array):
	net_structure = set.duplicate()

func _net_structure_get() -> Array:
	return net_structure.duplicate()

func _data_set(set : Array):
	data = set.duplicate(true)

func _data_get() -> Array:
	return data.duplicate(true)
	
func _neuron_data_set(set : Array):
	neuron_data = set.duplicate(true)

func _neuron_data_get() -> Array:
	return neuron_data.duplicate(true)

func _init(_net_structure : Array):

	net_structure = _net_structure.duplicate()
	neuron_data.resize(net_structure.size())
	data.resize(net_structure.size()-1)

	for z in range(data.size()):
		
		var t : Array = []
		t.resize((net_structure[z]+1) * net_structure[z+1])
		data[z] = t
		
		for x in range(net_structure[z+1]):
			for y in range(net_structure[z]+1):
				data[z][x*(net_structure[z]+1)+y] = 0.0
		
	for z in range(net_structure.size()):
		
		var w : Array = []
		w.resize(net_structure[z])
		neuron_data[z] = w
		
		for x in range(net_structure[z]):
			neuron_data[z][x] = 0

func add_random(min_val : float, max_val : float):
	for z in range(data.size()):
		for x in range(net_structure[z+1]):
			for y in range(net_structure[z]+1):
				data[z][x*(net_structure[z]+1)+y] += rand_range(min_val,max_val)

func multiply_random(min_val : float, max_val : float):
	for z in range(data.size()):
		for x in range(net_structure[z+1]):
			for y in range(net_structure[z]+1):
				data[z][x*(net_structure[z]+1)+y] *= rand_range(min_val,max_val)

func _activate(e : float) -> float: #virtual
	return 0.0

func _derivative(x : float) -> float: #virtual
	return 0.0
	
func for_each_connection(handle : ForEachConnectionHandle) -> void:
	for z in range(data.size()):
		for x in range(net_structure[z+1]):
			for y in range(net_structure[z]+1):
				handle._for_each_connection(x,y,z,x*(net_structure[z]+1)+y,self)

func _calculate_thread(args : Array)  -> float:

	var z = args[_args.Z]
	var x = args[_args.X]
	var input = args[_args.INPUT]
	
	var e = 0
	for y in range(net_structure[z]):
		e += data[z][x*(net_structure[z]+1)+y] * input[y]

	#bias
	e += data[z][x*(net_structure[z]+1)+input.size()] 
	
	e = _activate(e)
	
	return e

func calculate(input : Array) -> Array:
	
	input = input.duplicate()
	
	for z in range(net_structure.size()-1):
		
		neuron_data[z] = input.duplicate()
		
		var threads = []
		threads.resize(net_structure[z+1])

		for x in range(net_structure[z+1]):

			var thread = Thread.new()
			threads[x] = thread

			var args = []
			args.resize(_args.size())
			args[_args.INPUT] = input.duplicate()
			args[_args.X] = x
			args[_args.Z] = z

			thread.start(self,"_calculate_thread",args)

		input.resize(net_structure[z+1])

		for x in range(net_structure[z+1]):
			input[x] = threads[x].wait_to_finish()

	return input

func _correct_thread(args : Array):
	
	var error = args[_cargs.ERROR]
	var factor = args[_cargs.FACTOR]
	var x = args[_cargs.X]
	var z = args[_cargs.Z]

	var correction = factor * error * _derivative(neuron_data[z][x])
	
	for y in range(net_structure[z-1]):
		data[z-1][x*(net_structure[z-1])+y] += correction * neuron_data[z-1][y]
	
	data[z-1][x*(net_structure[z-1])+net_structure[z]] += correction

func _bpropagation_thread(args : Array) -> float:
	
	var error = args[_bargs.ERROR]
	var y = args[_bargs.Y]
	var z = args[_bargs.Z]
	
	var my_error = 0
	
	for x in range(net_structure[z+1]):
		my_error += error[x] * data[z][x*(net_structure[z]+1)+y]
	
	return my_error

func back_propagation(error : Array, lerning_factor : float):
	
	var neuron_error = []
	
	for z in range(net_structure.size()-1):
		var az = net_structure.size() - z - 2
		
		neuron_error.resize(net_structure[az])
		var threads = []
		threads.resize(net_structure[az])
		
		for y in range(net_structure[az]):
			var thread = Thread.new()
			threads[y] = thread
			
			var args = []
			args.resize(_bargs.size())
			args[_bargs.Y] = y
			args[_bargs.Z] = az
			args[_bargs.ERROR] = error.duplicate()
			
			thread.start(self,"_bpropagation_thread",args)
			
		for x in range(net_structure[az]):
			neuron_error[x] = threads[x].wait_to_finish()
		
		
		var cthreads = []
		cthreads.resize(net_structure[az + 1])
		
		for x in range(net_structure[az + 1]):
			
			var thread = Thread.new()
			cthreads[x] = thread
			
			var args = []
			args.resize(_cargs.size())
			args[_cargs.ERROR] = error[x]
			args[_cargs.FACTOR] = lerning_factor
			args[_cargs.X] = x
			args[_cargs.Z] = az + 1
			
			thread.start(self,"_correct_thread",args)
		
		for x in range(net_structure[az + 1]):
			cthreads[x].wait_to_finish()
		
		error = neuron_error.duplicate()
