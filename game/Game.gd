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
var playerName

# Called when the node enters the scene tree for the first time.
func _ready():
	gridSize = Vector2(int(get_viewport().size.x/TileSize)-1, int(get_viewport().size.y/TileSize)-1)
	rand.randomize()
	print(gridSize)
	resetGame()
	playerName=get_player_name()
	$PlayerName.text=playerName
	$HTTPRequest.connect("request_completed", self, "_on_request_completed")
	
func get_player_name():
	if !OS.has_feature('JavaScript'):
		return "Player"
	var jsName = JavaScript.eval(""" 
			var url_string = window.location.href;
			var url = new URL(url_string);
			url.searchParams.get("player_name");
		""")
	if jsName == null:
		return "Player"
	return jsName
	
func get_base_url():
	if !OS.has_feature('JavaScript'):
		return ""
	return JavaScript.eval("""
		var getUrl = window.location;
		getUrl.protocol + "//" + getUrl.host;
		""")

func placeTarget():
	targetPos = getRandomPos()
	while $Grid.get_cell(targetPos.x, targetPos.y) == SnakeTile:
		targetPos = getRandomPos()
	$Grid.set_cell(targetPos.x,targetPos.y,TargetTile)
	print("New target at ",targetPos)

func getRandomPos():
	return Vector2(rand.randi_range(0,gridSize.x-1),rand.randi_range(0,gridSize.y-1))

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
		grow+=3
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
	sendScore(points)
	$NewGameTimer.start()

func sendScore(points):
	var baseUrl = get_base_url()
	if baseUrl == "" || baseUrl == null:
		print("Not running in browser, not sending highscore")
		return
		
	if playerName == "Player":
		print("Player name not set, not sending highscore")
		return
	var data = {
		"game": "s3e",
		"version": "0.9",
		"player": playerName,
		"score": points,
	}
	var query = JSON.print(data)
	var headers = ["Content-Type: application/json"]
	var url = baseUrl+"/highscore"
	print(url)
	$HTTPRequest.request(url, headers, false, HTTPClient.METHOD_POST, query)
	print("sending highscore to "+baseUrl+"/highscore: "+query)
	
func _on_request_completed(result, response_code, headers, body):
	print("highscore sent")
	
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
		if ev.scancode == KEY_RIGHT:
			moveRight()
		if ev.scancode == KEY_DOWN && dir != 3:
			moveDown()
		if ev.scancode == KEY_LEFT && dir != 0:
			moveLeft()
		if ev.scancode == KEY_UP && dir != 1:
			moveUp()


func _enable_newgame():
	$GameOverLabel.text += "\nPRESS KEY\nTO START"
	allowNewGame = true


func allowMovement():
	allowMovement = true
	pass # Replace with function body.
	
func move(newDir):
	if gameOver && allowNewGame:
			resetGame()
			return
			
	if !allowMovement:
		return
	dir = newDir	
	
func moveRight():
	if dir != 2:
		move(0)
	$RightButton.hide()
	$LeftButton.hide()
	$UpButton.show()
	$DownButton.show()
		
func moveDown():
	if dir != 3:
		move(1)
	$RightButton.show()
	$LeftButton.show()
	$UpButton.hide()
	$DownButton.hide()

func moveLeft():
	if dir != 0:
		move(2)
	$RightButton.hide()
	$LeftButton.hide()
	$UpButton.show()
	$DownButton.show()

func moveUp():
	if dir != 1:
		move(3)
	$RightButton.show()
	$LeftButton.show()
	$UpButton.hide()
	$DownButton.hide()

		
func _on_DownButton_pressed():
	moveDown()

func _on_UpButton_pressed():
	moveUp()

func _on_RightButton_pressed():
	moveRight()

func _on_LeftButton_pressed():
	moveLeft()
