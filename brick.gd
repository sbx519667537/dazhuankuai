extends StaticBody2D

var can_penetrate = false  # 是否可以被穿透
var color = Color(0.2, 0.8, 0.2, 1)  # 默认绿色

func _ready():
	add_to_group("bricks") 
	# 随机决定是否可以被穿透（20%概率）
	if randf() < 0.2:
		can_penetrate = true
		color = Color(0.8, 0.2, 0.2, 1)  # 红色表示可穿透
	
	# 设置砖块颜色
	$ColorRect.color = color

# 获取砖块的矩形区域
func get_rect() -> Rect2:
	var size = $ColorRect.size
	return Rect2(position - size/2, size)
