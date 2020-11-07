extends Control

# game states
enum States { PLAYING, ENDED, RESULTS }
var gamestate = States.PLAYING

# settings
var word_amount = 5 

# global var
var type_index = 0
var current_prompt = ""

var words = [ "about", "above", "add", "after", "again", "air", "all", "almost", "along", "also", "always", "America", "an", "and", "animal", "another", "answer", "any", "are", "around", "as", "ask", "at", "away", "back", "be", "because", "been", "before", "began", "begin", "being", "below", "do", "does", "down", "each", "earth", "eat", "end", "enough", "even","every", "example", "eye", "face", "family", "far", "father", "feet", "few", "find", "first", "follow", "food", "for", "form", "found", "four", "from", "get",  "girl", "give", "go", "good", "got", "great", "group", "grow", "had", "hand", "hard", "has", "have", "head", "hear","help","her","here","high","him","his","home","house","how","idea","if","important","in", "Indian","into","is","it","its","just","keep","kind","know","land","large","last","later","learn", "leave","left","let", "letter", "life", "light", "like", "line", "list", "little", "live", "long","look", "made", "make", "man", "many", "may", "me", "mean", "men", "might", "mile", "miss", "more", "most", "mother", "mountain", "move", "much", "must", "my", "name", "near", "need", "never", "new", "next", "night", "no", "not", "now", "number", "of", "off", "often", "oil", "old", "on", "once", "one", "only","open", "or", "other", "our", "out", "over", "own", "page", "paper", "part", "people", "picture", "place", "plant", "play", "point", "put", "question", "quick", "quickly", "quite", "read", "really", "right",  "something", "sometimes", "song", "soon", "sound", "spell", "start", "state", "still", "stop", "story", "study", "such", "take", "talk", "tell", "than", "that", "the", "their", "them", "then", "there", "these", "they", "thing", "think", "this", "those", "thought", "three", "through", "time", "to", "together", "too", "took", "tree", "watch", "water", "way", "we", "well", "went", "were", "year", "you", "young", "your" ]
var rand = RandomNumberGenerator.new()

onready var player_inputbox = $PlayerPrompt
onready var enemy_inputbox = $EnemyPrompt

func generate(how_many):	
	# make a new empty prompt idk
	var string = ""
	
	for i in range(how_many):
		rand.randomize()
		string = string + words[rand.randf_range(1, words.size())] + " "
		
	return string
	
func play():
	# reinitialize
	gamestate = States.PLAYING
	type_index = 0
	current_prompt = generate(word_amount)
	
	player_inputbox.text = current_prompt
	enemy_inputbox.text = current_prompt
	
func proc_prompt(character):
	var to_match = current_prompt.substr(type_index, 1)
	var using = character.to_lower()
	
	if (using == to_match or using == "space" and to_match == " "):
		print("success")
		type_index += 1
	else:
		print("failed")

func _ready():
	play()
		
func _unhandled_input(event):
	if event is InputEventKey and not event.is_pressed():
		# translate event key byte into string character
		var typed = event as InputEventKey
		var character = OS.get_scancode_string(typed.scancode) #PoolByteArray([typed.unicode]).get_string_from_utf8()

		if (gamestate == States.PLAYING):
			proc_prompt(character)
