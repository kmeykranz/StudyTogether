extends CharacterBody2D
class_name Player
@onready var graphic: Node2D = $Graphic
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Graphic/Sprite2D

var SPEED = 200.0
var MousePos:Vector2

func _enter_tree() -> void:
	# 设置该节点的多人权限
	set_multiplayer_authority(name.to_int())
	pass

func _ready() -> void:
	position = Vector2(100,0)

func _physics_process(delta: float) -> void:
	# 如果不是该节点的控制者，则无法移动，直接终止方法
	# 根据设置的节点的权限id，与本身的唯一id作对比，如果一致，则权限正确
	# get_unique_id获取的id即为本机的id标识，在创建客户端或者服务器的时候生成
	if not is_multiplayer_authority():
		return
		
	# 鼠标点击
	if Input.is_action_just_pressed("click"):
		MousePos=get_global_mouse_position();
		print("mouse clicked")
	
	move(delta)

func move(delta) -> void:
	var direction=0;
	
	if MousePos:
		if MousePos.distance_to(position)>0:
			if MousePos.x>position.x-5 && MousePos.x<position.x+5:
				velocity.x=0;
			else:
				if MousePos.x>position.x:
					direction=1;
				else:
					direction=-1;
			#if MousePos.y>position.y-5&& MousePos.y<position.y+5:
				#velocity.y=0;
			#else:
				#if MousePos.y>position.y:
					#velocity.y=1*SPEED;
				#else:
					#velocity.y=-1*SPEED;

	# 设置角色移动速度
	velocity.x = direction * 100
	# 设置玩家重力加速度
	velocity.y += ProjectSettings.get("physics/2d/default_gravity") * delta
	# 如果存在水平方向的运动
	if not is_zero_approx(direction):
		# 设置对应的朝向
		graphic.scale.x = 1 if direction > 0 else -1
		# 执行函数，执行动画
		update_player_animation.rpc("run")
	else:
		# 执行函数，执行动画
		update_player_animation.rpc("idle")
	# 玩家移动
	move_and_slide()

# "authority"：只有多人权限（服务器）才能远程调用
# "any_peer"：允许客户远程呼叫。对于传输用户输入很有用
# "call_remote"：该函数不会在本地对等点上调用
# "call_local"：该函数可以在本地peer上调用。当服务器同时也是玩家时很有用
# "unreliable"数据包不会被确认，可能会丢失，并且可能以任何顺序到达
# "unreliable_ordered"数据包按照发送的顺序接收。这是通过忽略后来到达的数据包（如果已经收到在它们之后发送的另一个数据包）来实现的。如果使用不当可能会导致丢包
# "reliable"发送重新发送尝试直到数据包被确认，并且它们的顺序被保留。具有显着的性能损失
@rpc("authority", "call_local")
## 更新玩家动画
func update_player_animation(animation_name:String) -> void:
	# 播放指定动画
	animation_player.play(animation_name)
