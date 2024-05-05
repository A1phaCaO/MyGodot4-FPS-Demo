extends CharacterBody3D

@export var mouse_sensity = 0.1 # 鼠标灵敏度
@export var view_range = Vector2(-85, 85) # 抬头范围
@export var move_speed = 5 # 走路速度
@export var jump_height = 5
@export var gravity = 9.8
@export var ground_move_smooth = 10
@export var air_move_smooth = 2

@onready var head = $Head # 获取头部(摄像机)
var is_lock_mouse = true
var dir = Vector3.ZERO
var current_smooth = 0
var V_velocity = Vector3.ZERO # 处理竖直方向速度
var H_velocity = Vector3.ZERO # 处理水平方向速度


func  _ready():	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func  _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		is_lock_mouse = !is_lock_mouse
		if is_lock_mouse == true:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		elif is_lock_mouse == false:
			Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	if is_lock_mouse == true:
		if event is InputEventMouseMotion:
			rotate_y(deg_to_rad(-event.relative.x * mouse_sensity)) # 左右旋转身体
			head.rotate_x(deg_to_rad(-event.relative.y * mouse_sensity)) #上下旋转相机
			head.rotation.x = clamp(head.rotation.x, deg_to_rad(view_range.x), deg_to_rad(view_range.y)) # 限制视角
		
func _physics_process(delta):
	if is_on_floor():
		current_smooth = ground_move_smooth
		V_velocity = Vector3.ZERO
		if is_lock_mouse == true:
			dir = Vector3.ZERO
			if Input.is_action_pressed("move_forward"):
				dir += -transform.basis.z
			if Input.is_action_pressed("move_back"):
				dir += transform.basis.z
			if Input.is_action_pressed("move_left"):
				dir += -transform.basis.x
			if Input.is_action_pressed("move_right"):
				dir += +transform.basis.x
			if Input.is_action_just_pressed("jump"):
				V_velocity += Vector3.UP * jump_height
	else:
		current_smooth = air_move_smooth
		V_velocity += Vector3.DOWN * gravity * delta
	H_velocity = lerp(H_velocity, dir * move_speed, current_smooth * delta)
	dir = dir.normalized()
	velocity = H_velocity + V_velocity
	move_and_slide()
	
