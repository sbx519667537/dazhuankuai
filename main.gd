extends Node2D

@onready var paddle_scene = preload("res://paddle.tscn")
@onready var brick_scene = preload("res://brick.tscn")
@onready var ball_scene = preload("res://ball.tscn")
@onready var paddle = $Paddle

func _ready():
	# 确保板子在球之前
	if paddle:
		move_child(paddle, 0)
	
	# 创建砖块
	create_bricks()

func _process(_delta):
	# 如果板子不存在，重新创建
	if not is_instance_valid(paddle) or not paddle:
		if paddle:
			paddle.queue_free()
		paddle = paddle_scene.instantiate()
		add_child(paddle)
		paddle.position = Vector2(576, 650)
		move_child(paddle, 0)

func create_bricks():
	for row in range(5):
		for col in range(10):
			var brick = brick_scene.instantiate()
			add_child(brick)
			brick.position = Vector2(100 + col * 100, 50 + row * 30)
