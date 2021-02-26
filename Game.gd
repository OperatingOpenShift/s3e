extends Node
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var rand = RandomNumberGenerator.new()
var TileSize = 40
var grow = 5
var dir = 0
var headPos
var targetPos
var snake = []
var SnakeTile = 0
var TargetTile = 1
var UnusedTile = -1
var gridSize
var points = 0
var BasePoints = 10
var speed = 5
var gameOver = false
var allowNewGame = false
var allowMovement = false

# Called when the node enters the scene tree for the first time.
func _ready():
	gridSize = Vector2(int(get_viewport().size.x/TileSize)-1, int(get_viewport().size.y/TileSize)-1)
	rand.randomize()
	print(gridSize)
	resetGame()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func placeTarget():
	targetPos = getRandomPos()
	while $Grid.get_cell(targetPos.x, targetPos.y) == SnakeTile:
		targetPos = getRandomPos()
	$Grid.set_cell(targetPos.x,targetPos.y,TargetTile)
	print("New target at ",targetPos)

func getRandomPos():
	return Vector2(rand.randi_range(0,gridSize.x),rand.randi_range(0,gridSize.y))

func resetGame():
	speed = 5
	points = 0
	snake = []
	gameOver = false
	grow = 5
	allowNewGame = false
	allowMovement = false
	
	for currentCell in $Grid.get_used_cells():
		$Grid.set_cell(currentCell.x, currentCell.y,UnusedTile)
	dir = rand.randi_range(0,3)
	headPos = getRandomPos()
	if headPos.x < gridSize.x/4:
		dir = 0
	if headPos.y < gridSize.y - gridSize.y/4:
		dir = 1
	if headPos.x > gridSize.x - gridSize.x/4:
		dir = 2
	if headPos.y > gridSize.y - gridSize.y/4:
		dir = 3
	$AllowMovementTimer.start()
	snake.append(headPos)
	drawSnake()
	placeTarget()
	updateSnakeSpeed()
	updateStats()
	$GameOverLabel.visible = false
	$Score.visible = true

func step():
	if dir == 0:
		headPos.x += 1
	if dir == 1:
		headPos.y += 1
	if dir == 2:
		headPos.x -= 1
	if dir == 3:
		headPos.y -= 1
	snake.append(headPos)
	if grow == 0:
		snake.pop_front()
	else:
		grow-=1
	
	if headPos == targetPos:
		grow+=1
		points += int(BasePoints * speed)
		speed+=0.5
		updateStats()
		updateSnakeSpeed()
		placeTarget()
		
	if ($Grid.get_cell(headPos.x,headPos.y) == SnakeTile 
	|| headPos.x > gridSize.x 
	|| headPos.y > gridSize.y
	|| headPos.x < 0
	|| headPos.y < 0):
		gameOver()
	
	drawSnake()
	
func gameOver():
	print("GAME OVER")
	$StepTimer.stop()
	gameOver = true
	$GameOverLabel.visible = true
	$GameOverLabel.text = "GAME OVER\nSCORE: "+str(points)
	$Score.visible = false
	$NewGameTimer.start()
		
func updateStats():
	print("Speed: ",speed)
	print("Points:",points)
	$Score.text = "YOUR SCORE: " + str(points)
	
func updateSnakeSpeed():
	$StepTimer.set_wait_time(float(1)/speed)
	$StepTimer.start()
	
func drawSnake():
	for currentCell in $Grid.get_used_cells_by_id(SnakeTile):
		$Grid.set_cell(currentCell.x, currentCell.y,UnusedTile)
		
	for cell in snake:
		$Grid.set_cell(cell.x, cell.y,SnakeTile)

func _input(ev):
	if ev is InputEventKey:
		if gameOver && allowNewGame:
			resetGame()
			return
			
		if !allowMovement:
			return
			
		if ev.scancode == KEY_RIGHT && dir != 2:
			dir = 0
		if ev.scancode == KEY_DOWN && dir != 3:
			dir = 1
		if ev.scancode == KEY_LEFT && dir != 0:
			dir = 2
		if ev.scancode == KEY_UP && dir != 1:
			dir = 3


func _enable_newgame():
	$GameOverLabel.text += "\nPRESS KEY\nTO START"
	allowNewGame = true


func allowMovement():
	allowMovement = true
	pass # Replace with function body.
