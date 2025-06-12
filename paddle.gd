extends CharacterBody2D

const SPEED = 400.0

func _physics_process(delta):
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()
	
	# 限制板子不会移出屏幕
	position.x = clamp(position.x, 50, 1150)

# 获取板子的矩形区域
func get_rect() -> Rect2:
	var size = $ColorRect.size
	return Rect2(position - size/2, size) 
