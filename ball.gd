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
	# 设置碰撞层(第1层)
	collision_layer = 1
	collision_mask = 1

func _physics_process(delta):
	# 简化边界检测
	if position.y > 700:  # 下边界
		position = Vector2(576, 600)
		direction = Vector2(randf_range(-1, 1), -1).normalized()
	elif position.y < 0:  # 上边界
		position.y = 30
		direction = Vector2(direction.x, 1.0)  # 强制向下
		velocity = direction.normalized() * SPEED * 2.0  # 更强力反弹
		print("上边界反弹: new velocity=", velocity)  # 调试日志
	
	# 统一更新速度
	velocity = direction * SPEED
	
	# 物理移动和碰撞处理
	var collision = move_and_collide(velocity * delta)
	if collision:
		var collider = collision.get_collider()
		var normal = collision.get_normal()
		
		# 处理板子碰撞(完全只读)
		if collider is CharacterBody2D and collider.name == "Paddle":
			# 获取板子位置但不保留引用
			var paddle_pos = get_node("/root/Main/Paddle").position
			var relative_x = (position.x - paddle_pos.x) / 50.0
			direction = Vector2(relative_x, -1).normalized()
			position += collision.get_normal() * 5
			# 不进行任何可能影响板子的操作
		
		# 与砖块碰撞
		elif collider.is_in_group("bricks"):
			# 确保砖块被销毁
			if collider.has_method("queue_free"):
				collider.queue_free()
				# 如果是红色砖块则分裂成3个球
				if collider.can_penetrate:
					split_ball()
					split_ball()
			# 无论是否销毁都先反弹
			direction = direction.bounce(normal)
			position += normal * 5
		
		# 与墙壁碰撞
		else:
			direction = direction.bounce(collision.get_normal())
			# 确保球不会卡在墙上
			position += collision.get_normal() * 2
	

func split_ball():
	if main_scene:
		# 创建一个新的球
		var new_ball = main_scene.ball_scene.instantiate()
		
		# 设置方向和速度(确保不会垂直向上)
		var current_angle = direction.angle()
		# 限制角度在-60°到60°之间
		var new_angle = clamp(current_angle + randf_range(-PI/3, PI/3), -PI/3, PI/3)
		# 确保y方向分量足够向下(-0.8到-0.3)
		var dir_y = -randf_range(0.3, 0.8)
		# 计算x方向分量保持水平运动
		var dir_x = cos(new_angle) * sign(randf_range(-1, 1))
		new_ball.direction = Vector2(dir_x, dir_y).normalized()
		new_ball.velocity = new_ball.direction * SPEED * 0.9  # 稍慢的初始速度
		
		# 再初始化其他属性
		new_ball.main_scene = main_scene
		# 添加随机位置偏移(10-20像素)
		new_ball.position = position + Vector2(randf_range(-20, 20), randf_range(-20, 20))
		main_scene.add_child(new_ball)
		# 延迟0.1秒后初始化(避免碰撞重叠)
		await get_tree().create_timer(0.1).timeout
		new_ball._ready()

# 获取球的矩形区域
func get_rect() -> Rect2:
	var size = $ColorRect.size
	return Rect2(position - size/2, size)
