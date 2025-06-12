extends CharacterBody2D

const SPEED = 400.0
var direction = Vector2.ZERO
var can_penetrate = false  # 是否具有穿透能力
var penetration_count = 0  # 当前穿透次数
var main_scene

func _ready():
	main_scene = get_parent()
	# 随机初始方向
	direction = Vector2(randf_range(-1, 1), -1).normalized()

func _physics_process(delta):
	velocity = direction * SPEED
	var collision = move_and_collide(velocity * delta)
	
	if collision:
		var collider = collision.get_collider()
		
		# 与板子碰撞
		if collider is CharacterBody2D and collider.name == "Paddle":
			var paddle_pos = collider.position
			var relative_x = (position.x - paddle_pos.x) / 50.0
			direction = Vector2(relative_x, -1).normalized()
			# 确保球不会卡在板子上
			position += collision.get_normal() * 2
		
		# 与砖块碰撞
		elif collider.is_in_group("bricks"):
			direction = direction.bounce(collision.get_normal())
			# 确保球不会卡在砖块上
			position += collision.get_normal() * 2
			# 确保砖块被销毁
			if collider.has_method("queue_free"):
				collider.queue_free()
		
		# 与墙壁碰撞
		else:
			direction = direction.bounce(collision.get_normal())
			# 确保球不会卡在墙上
			position += collision.get_normal() * 2
	
	# 如果球掉出屏幕底部，重置位置
	if position.y > 700:
		position = Vector2(576, 600)
		direction = Vector2(randf_range(-1, 1), -1).normalized()

func split_ball():
	if main_scene:
		# 创建两个新的球
		var ball1 = main_scene.create_ball_at_position(position)
		var ball2 = main_scene.create_ball_at_position(position)
		
		# 设置新球的方向
		var current_angle = direction.angle()
		ball1.direction = Vector2(cos(current_angle - PI/4), sin(current_angle - PI/4))
		ball2.direction = Vector2(cos(current_angle + PI/4), sin(current_angle + PI/4))
		
		# 设置新球的速度
		ball1.speed = SPEED
		ball2.speed = SPEED

# 获取球的矩形区域
func get_rect() -> Rect2:
	var size = $ColorRect.size
	return Rect2(position - size/2, size) 
