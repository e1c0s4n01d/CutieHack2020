extends Control

# bbcode text colors
var green_color = Color("#1FFF80")
var red_color = Color("#FF4D4D")
var white_color = Color("#FFFFFF")

# enumerators
enum States { PLAYING, ENDED, RESULTS }
enum Character { PASSED, FAILED }
enum Entity { PLAYER, ENEMY }

# game states
var gamestate = States.PLAYING
var gamewinner = null

# enemy conditions
var count = 0
var bot_wpm = 0
var BASE_BOT_WPM = 40

# timer
var initial_time = 0
var display_value = 0
onready var timer = get_node("Timer")
onready var display_label = get_node("Display")

# settings
var word_amount = 5 

# text-related
var type_index = 0
var type_index_bot = 0
var characters = {} # holds the success/fail state of the given [type_index]
var characters_bot = {} # bot never fails LUL

var current_prompt = ""
var words = [ "about", "above", "add", "after", "again", "air", "all", "almost", "along", "also", "always", "america", "an", "and", "animal", "another", "answer", "any", "are", "around", "as", "ask", "at", "away", "back", "be", "because", "been", "before", "began", "begin", "being", "below", "do", "does", "down", "each", "earth", "eat", "end", "enough", "even","every", "example", "eye", "face", "family", "far", "father", "feet", "few", "find", "first", "follow", "food", "for", "form", "found", "four", "from", "get",  "girl", "give", "go", "good", "got", "great", "group", "grow", "had", "hand", "hard", "has", "have", "head", "hear","help","her","here","high","him","his","home","house","how","idea","if","important","in", "Indian","into","is","it","its","just","keep","kind","know","land","large","last","later","learn", "leave","left","let", "letter", "life", "light", "like", "line", "list", "little", "live", "long","look", "made", "make", "man", "many", "may", "me", "mean", "men", "might", "mile", "miss", "more", "most", "mother", "mountain", "move", "much", "must", "my", "name", "near", "need", "never", "new", "next", "night", "no", "not", "now", "number", "of", "off", "often", "oil", "old", "on", "once", "one", "only","open", "or", "other", "our", "out", "over", "own", "page", "paper", "part", "people", "picture", "place", "plant", "play", "point", "put", "question", "quick", "quickly", "quite", "read", "really", "right",  "something", "sometimes", "song", "soon", "sound", "spell", "start", "state", "still", "stop", "story", "study", "such", "take", "talk", "tell", "than", "that", "the", "their", "them", "then", "there", "these", "they", "thing", "think", "this", "those", "thought", "three", "through", "time", "to", "together", "too", "took", "tree", "watch", "water", "way", "we", "well", "went", "were", "year", "you", "young", "your" ]

# misc globals
var rand = RandomNumberGenerator.new()

onready var player_inputbox = $PlayerPrompt
onready var player_wpm = $PlayerWPM
onready var enemy_inputbox = $EnemyPrompt
onready var enemy_wpm = $EnemyWPM

func get_wpm(time_left):
	var elapsed = initial_time - time_left
	return (characters.size() / 5) / ((elapsed if (elapsed > 0) else 1 * 60) / 60)

func bbcode_und(character):
	return "[u]" + character + "[/u]"

func bbcode_color(color):
	return "[color=#" + color.to_html(false) + "]"
	
func bbcode_color_end():
	return "[/color]"

func generate(how_many):	
	# make a new empty prompt idk
	var string = ""
	
	for i in range(how_many):
		rand.randomize()
		string = string + words[rand.randf_range(1, words.size())]
		
		if (i < how_many - 1):
			string = string + " "
		
	return string
	
func play():
	# set new timer
	rand.randomize()
	display_value = floor(rand.randf_range(10, 25))
	initial_time = display_value
	
	gamestate = States.PLAYING
	
	count = 0
	bot_wpm = BASE_BOT_WPM * (rand.randf_range(0, 100) / 100)

	# set initial scores
	type_index = 0
	type_index_bot = 0
	characters = {}
	characters_bot = {}
	
	# generate prompt for both parties
	current_prompt = generate(word_amount * (initial_time * 0.175))
	
	player_inputbox.text = current_prompt
	enemy_inputbox.text = current_prompt
	
	display_label.text = str(display_value)
	timer.set_wait_time(1)
	timer.start()
	
func get_list(input_box):
	return characters if (input_box == player_inputbox) else characters_bot
	
func results():
	gamestate = States.RESULTS
	
	var player_wpm = get_wpm(display_value)
	
	if (gamewinner != Entity.ENEMY and gamewinner != Entity.PLAYER):
		# compare amount of letters successful.
		var player_letters_successful = 0
		var bot_letters_successful = 0

		for i in get_list(player_inputbox):
			if (get_list(player_inputbox)[i] == Character.PASSED):
				player_letters_successful += 1

		for i in get_list(enemy_inputbox):
			if (get_list(enemy_inputbox)[i] == Character.PASSED):
				bot_letters_successful += 1
		
		if (player_letters_successful < bot_letters_successful):
			gamewinner = Entity.ENEMY
		else:	
			gamewinner = Entity.PLAYER

	if (gamewinner == Entity.ENEMY):
		get_tree().change_scene("res://Loser.tscn")
	elif (gamewinner == Entity.PLAYER):
		get_tree().change_scene("res://Winner.tscn")
	
func pass_to_list(state, index, box):
	var list = get_list(box)
	list[index] = state

func build_string(index, inputbox):
	var new_string = ""
	
	# determine whose array we'll be looking at
	var list = get_list(inputbox)
	
	# build from existing
	for i in list:
		var color = green_color if list[i] == 0 else red_color
		new_string = new_string + bbcode_color(color) + current_prompt.substr(i, 1) + bbcode_color_end()
	
	# underline next character
#	var cur_index = index + 1 if (index > 1) else index
#	new_string = new_string + bbcode_und(current_prompt.substr(cur_index, 1))
	
	# add the rest
	new_string = new_string + bbcode_color(white_color) + current_prompt.substr(index + 1, current_prompt.length()) + bbcode_color_end()
		
	inputbox.parse_bbcode(new_string)

func on_success(index, box):
	pass_to_list(Character.PASSED, index, box)	
	build_string(index, box)
	
func on_fail(index):
	pass_to_list(Character.FAILED, index, player_inputbox)
	build_string(index, player_inputbox)

# maybe, if i get to it
func on_retract(index):
	var array = characters.keys()
	
	if (characters.size() > 0 and array[index]):
		characters.erase(index)
		
	build_string(index - 1, player_inputbox)
	
func proc_prompt(character):
	var to_match = current_prompt.substr(type_index, 1)
	var using = character.to_lower()
	
	# deleting characters
	if (using == "backspace"):
		if (type_index > 0):
			type_index -= 1
			
		if (characters.size() > 0 and type_index < 1):
			for i in characters:
				characters.erase(i)
				
		on_retract(type_index)
		
		return # guard clause
	
	# adding characters
	if (using == to_match or using == "space" and to_match == " "):
		on_success(type_index, player_inputbox)
	else:
		on_fail(type_index)
		
	type_index += 1

func _ready():
	print(characters.size())
	play()
	
func _process(delta):
	if (gamestate == States.PLAYING):
		# showing wpm
		player_wpm.set_text(str(floor(get_wpm(display_value))) + " WPM")
		enemy_wpm.set_text("")
		#enemy_wpm.set_text(str(floor(bot_wpm)) + " WPM")
			
		if (type_index_bot >= current_prompt.length() - 1):
			gamewinner = Entity.ENEMY # of course.
			results()
			return
		
		var interval = (delta * bot_wpm * BASE_BOT_WPM)
		
		if (count >= interval):
			# bot logic
			on_success(type_index_bot, enemy_inputbox)
			type_index_bot += 1
			count = 0
		else:
			count += delta
		
func _unhandled_input(event):
	if event is InputEventKey and not event.is_pressed():
		# translate event key byte into string character
		var typed = event as InputEventKey
		var character = OS.get_scancode_string(typed.scancode) #PoolByteArray([typed.unicode]).get_string_from_utf8()

		if (gamestate == States.PLAYING):
			proc_prompt(character)
			
			if (type_index >= current_prompt.length() - 1):
				results()
				return

func _on_Timer_timeout():	
	if display_value == 0:
		results()
		timer.stop()
	elif (gamestate == States.PLAYING):
		display_value -= 1
		display_label.set_text(str(display_value))
