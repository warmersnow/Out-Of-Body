extends KinematicBody2D

var velocity := Vector2.ZERO
export var gravity_base := 200 #baseline gravity
var spawn_delay_time := 0.05
var player_node = null
signal restore_player

func _physics_process(delta: float) -> void:
	velocity.y += gravity_base * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	#position += velocity

func spawn_setup():
	$MovementCollision.disabled = true
	$Area2D/RestoreCollision.disabled = true
	player_node = get_parent().get_node_or_null("Player")
	$SpawnDelay.start(spawn_delay_time)
	



func _on_SpawnDelay_timeout():
	print("enabling collision")
	$MovementCollision.disabled = false
	$Area2D/RestoreCollision.disabled = false


func _on_Area2D_body_entered(body):
	#var p = get_parent().get_node_or_null("Player")
	
	if player_node == body:
		emit_signal("restore_player")
		#remove_child(self)
		print("We did it")
	else:
		print("Wrong answer rat")
	
	pass
