extends KinematicBody2D
export (PackedScene) var Body = preload("Body/Body.tscn")

export var move_speed := 80 #speed the player moves without charge attacking
export var gravity_base := 200 #baseline gravity
export var jump_base := 200 #baseline jump velocity
export var charge_speed_bonus := 1.75 #multiplier applied to move_speed when charging
export var soul_speed_bonus := 1.33 #multiplier to all movement when in soul mode

var curr_state_bonus = 1
var coyote_timer_count := 0.1 #length of time coyote time is
var has_jumped := true #true when the player has taken a normal jump
var velocity := Vector2.ZERO #velocity to be applied to the player as movement
var last_floor := false #if the player was on the floor during the last call
var has_second_jumped := true #true if the player has used the second jump
var coyote_jump := true #true while the player is in the coyote jump period
var is_charging_forward := false #true when the player is using the charge attack
var facing_direction = 1 # 1 for right, -1 for left
var body = Body.instance()
var soul_is_seperated = false

signal player_moves

func _ready():
	body.connect("restore_player", self, "restore_body")

func _physics_process(delta: float) -> void:
	#reset horizontal velocity
	velocity.x = 0
	
	#set H-Velocity
	if Input.is_action_pressed("left_move"):
		velocity.x -= move_speed
		facing_direction = -1 * curr_state_bonus
		
	if Input.is_action_pressed("right_move"):
		velocity.x += move_speed
		facing_direction = 1 * curr_state_bonus
	
	if Input.is_action_pressed("charge_attack"):
		is_charging_forward = true
		if(velocity.x == 0):
			velocity.x += move_speed * facing_direction * curr_state_bonus
		velocity.x = velocity.x * charge_speed_bonus
	else:
		is_charging_forward = false
	
	
	var curr_floor = is_on_floor()
	
	if curr_floor: #when the player is grounded, jumps are reset
		has_jumped = false
		has_second_jumped = false
		curr_state_bonus = 1
	
	if Input.is_action_just_pressed("jump"): #checks if a jump is actually possible
		if (curr_floor || coyote_jump) && !has_jumped: #checks if the player is grounded or if they have not jumped in coyote time yet
			velocity.y -= jump_base * curr_state_bonus
			coyote_jump = false
			has_jumped = true
		elif !(has_second_jumped): #should they have jumped already but not double jumped they may take the second jump
			self.velocity.y = 0
			velocity.y -= jump_base * soul_speed_bonus
			has_second_jumped = true
			spawn_body()
	else:
		#apply gravity - currently always has downward velocity
		if !Input.is_action_pressed("jump"):
			if self.velocity.y < 0:
				self.velocity.y = 3 * ((self.velocity.y) / 4)
		velocity.y += gravity_base * delta * (1/curr_state_bonus)
	
	if last_floor != curr_floor:
			$Coyote_Timer.start(coyote_timer_count)
			coyote_jump = true
	
	
	
	
	
	
	last_floor = curr_floor
	velocity = move_and_slide(velocity, Vector2.UP)
	emit_signal("player_moves")
	#if(abs(velocity.y) < (jump_base/2)):
		#$Camera2D.drag_margin_v_enabled = false
	#else:
		#$Camera2D.drag_margin_v_enabled = true

func spawn_body():
	if !soul_is_seperated:
		body.position = position
		#body.position.y += gravity_base * 0.01
		##add_child(body)#PROBLEM: Movement is tied to player movement
		get_parent().add_child(body)
		body.spawn_setup()
		soul_is_seperated = true

func coyote_time_end():
	coyote_jump = false

func restore_body():
	print("Restored")
	soul_is_seperated = false
	call_deferred("remove_body")
	
func remove_body():
	position = body.position
	get_parent().remove_child(body)
	
