extends RigidBody2D

var net = NeuralNet.new(Settings.net_struct)
var input = []

var force = false
var torque = 0

var manager

var best = false


func _ready():
	if (!best):
		net.add_random(-Settings.add_range/2, Settings.add_range/2)
		net.multiply_random(1/(1+Settings.multiply_range),1+Settings.multiply_range)
	input.resize(Settings.net_struct[0])

func _physics_process(delta):
	var rays = $Rays.get_children()
	var i = 0
	
	for ray in rays:
		if ray.is_colliding():
			input[i] = 1
		else:
			input[i] = 0
		i+=1
		
	input[i] = global_position.x
	i+=1
	input[i] = global_position.y
	i+=1
	input[i] = linear_velocity.x
	i+=1
	input[i] = linear_velocity.y
	i+=1
	input[i] = rotation
	i+=1
	input[i] = angular_velocity
	i+=1 
	input[i] = torque
	i+=1
	if(force):
		input[i] = 1
		$Particles2D.emitting = true
	else:
		input[i] = 0
		$Particles2D.emitting = false
	
	var out = net.calculate(input)
	
	if(out[0] >= Settings.force_treshold):
		force = Settings.force
	else:
		force = 0
		
	if(abs(out[1]) >= Settings.torque_treshold):
		torque = clamp(out[1] * Settings.torque, -Settings.torque, Settings.torque)
	else:
		torque = 0
	
	add_force(Vector2.ZERO,transform.y * -force)
	add_torque(torque)
	


func _on_Rocket_body_entered(body):
	manager.agent_end(global_position.x,net)
	queue_free()
