extends CharacterBody2D

@export var Bullet: PackedScene

signal died

@export var speed = 300.0
@export var maxhealth = 10
var health
var is_invincible = false

#弾関連
var radius = 50
@export var num_bullets = 8
@export var bullet_speed  = 500

func _ready():
	hide()

func get_input():
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir * speed
	# 左右反転（この条件式はちょいムズい）
	if velocity.x != 0:
		$Sprite2D.flip_h = velocity.x < 0

# 角度をラジアンに変換するヘルパー関数
func deg2rad(deg):
	return deg * PI / 180	

func shoot():
	var angle = 0
	
	for i in range(num_bullets):
		var bullet = Bullet.instantiate()
		
		# Bullet.tscnにstart関数があるか確認して呼び出す
		if bullet.has_method("start"):
			bullet.start(global_position, deg2rad(angle))
		
		# 弾をシーンに追加
		get_parent().add_child(bullet)
		
		# 次の弾の角度を設定
		angle += 360 / num_bullets
	

func _physics_process(delta):
	get_input()
	# move_and_slide()は計算にタイムステップを自動的に含めるため、速度ベクトルにはdeltaを描けないこと。
	move_and_slide()

	# このfor文あんまりわかってない
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if not is_invincible:
			is_invincible = true
			health -= 1
			print(health, " / ", maxhealth)
			
			# 一時的に無敵状態にするためのタイマーを作成
			await get_tree().create_timer(1.0).timeout
			is_invincible = false
			
			if health <= 0:
				print("player died!")
				died.emit()
				$CollisionShape2D.set_deferred("disabled", true)

	
func start(pos):
	health = maxhealth
	position = pos
	show()
	$CollisionShape2D.disabled = false

func _on_shoot_timer_timeout():
	pass
