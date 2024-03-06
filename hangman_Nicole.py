#Nicole Deng
#Hangman Final Project



"""
1. What were the 3 goals?
Were the goals met?
"""
"""
2. How does this project illustrate your mastery of Python?
"""
"""
3. What have you learned from doing this project?
"""

# Imports
import turtle
import random

# functions
def scaffold():
    """
    sig: none-> none
    draws the hangman scaffold"""
    turtle.bgcolor("blue")
    turtle.speed(5)
    turtle.penup()
    turtle.right(90)
    turtle.forward(100)
    turtle.left(90)
    turtle.pendown()
    turtle.hideturtle()
    turtle.color('yellow')
    turtle.pensize(10)
    turtle.forward(100)
    turtle.right(180)
    turtle.forward(200)
    turtle.right(180)
    turtle.forward(100)
    turtle.left(90)
    turtle.forward(300)
    turtle.right(90)
    turtle.forward(75)
    turtle.right(90)
    turtle.forward(20)



def head():
    """
    sig: none-> none
    draws head"""
    turtle.left(90)
    i=0
    while i<16:
        turtle. forward(15)
        turtle.right(360/16)
        i=i+1


def body():
    """
    sig: none-> none
    draws body"""
    i=0
    while i<8:
        turtle. forward(15)
        turtle.right(360/16)
        i=i+1
    turtle.left(90)
    turtle.forward(80)


def right_leg():
    """
    sig: none->none
    draws left leg"""
    turtle.pensize(5)
    turtle.left(45)
    turtle.forward(60)
    i=0
    turtle.pensize(5)
    turtle.left(90)
    while i<16:
        turtle. forward(2)
        turtle.right(360/16)
        i=i+1

def left_leg():
    """
    sig: none->none
    draws right leg and sets up for arms"""
    turtle.left(90)
    turtle.forward(60)
    turtle.left(90)
    turtle.forward(60)
    i=0
    turtle.left(90)
    while i<16:
        turtle. forward(2)
        turtle.right(360/16)
        i=i+1


def left_arm():
    """
    sig: none->none
    draws right leg and sets up for arms"""
    turtle.left(90)
    turtle.forward(60)
    turtle.left(50)
    turtle.forward(50)
    turtle.left(135)
    turtle.forward(50)
    i=0
    while i<16:
        turtle. forward(2)
        turtle.right(360/16)
        i=i+1
    
def right_arm():
    """
    sig: none->none
    draws right leg and sets up for arms"""
    turtle.right(180)
    turtle.forward(50)
    turtle.right (90)
    turtle.forward(50)
    i=0
    while i<16:
        turtle. forward(2)
        turtle.right(360/16)
        i=i+1

def draw_hangman(nwrong):
    """
    sig: int->none
    draws hangman body part corresponding to number wrong
    """
    if nwrong ==1:
        head()
    if nwrong ==2:
        body()
    if nwrong ==3:
        right_leg()
    if nwrong ==4:
        left_leg()
    if nwrong ==5:
        left_arm()
    if nwrong ==6:
        right_arm()

def draw_man():
    """
    sig: none-> none
    runs draw_hangman to draw the whole hangman. for testing."""
    head()
    body()
    right_leg()
    left_leg()
    left_arm()
    right_arm()

def setup_turtle():
    """
    sig: none-> none
    sets up game"""
    scaffold()

def select_word(wordbank):
    """
    sig: list ->list[str]
    returns a random word from the wordbank and breaks out as a list"""
    word=random.choice(wordbank)
    lst=list(word)
    for i in range(len(lst)):
        lst[i] = lst[i].upper()
    return lst

'''
wordbank=['red','orange','yellow','green','blue','purple']
random_word=select_word(wordbank)
print(random_word) '''

def isvalid(guess):
    """
    sig: str -> Bool
    validates input guess. Returns True if it is a single alphabetic character."""
    if len(guess) != 1:
        return False
    return guess.isalpha()

def setup_secret(word):
    """
    sig:list[str]->list[str] word: ["H", "E", "L", "L", "O"]
    sets up secret, the list with blanks to guess
    there is one blank for every letter in word as a list"""
    lst=[]
    #print(len(word))
    for i in range (0, len(word)):
        lst.append("_")
    return lst 
#print(setup_secret(random_word))


def get_guess():
    """
    sig: none->str
    prompts user for guess and validates it; returns validated guess"""
    guess=input("please enter your guess.").upper()
    while True:
        if isvalid(guess):
            return guess
        elif len(guess) == 0:
           print("Sorry, this is an empty string")
           guess=input("please enter your guess as a single letter.").upper()
        elif len(guess) >= 2:
           print("Please enter only one letter at a time")
           guess=input("please enter your guess as a single letter.").upper()
        else:
            print("Sorry, this is not an alphabatic character")
            guess=input("please enter your guess as a single letter.").upper()
            


###### MAIN ######


# set up the game  
setup_turtle()
#draw_man() # for testing drawing works!

wordbank=['red','orange','yellow','green','blue','purple']
# function call for selecting the word
secret_word = select_word(wordbank)
# function call for setting up the blanks for the player to fill in
shown_word = setup_secret(secret_word)
# Initialization of needed lists and counters
guess_letters=[]#list
bad_guess_num = 0
while True: # play game
    guessed = False
    guess=get_guess() 
# check if it has already been guessed
    if guess in guess_letters:
        print(guess, "has aready been guessed")
        continue
    else:
        print("You already guessed", guess_letters)
        guess_letters.append(guess)
    
# check if the guess is in the secret
    if guess in secret_word:
        guessed = True  
# updating the blanks to show correctly guessed letters
    if guessed:
        for i in range(len(secret_word)):
            if secret_word[i] == guess:
                shown_word[i] = guess
        if shown_word == secret_word:
           print("CONGRATULATIONS YOU WON WITH ONLY",bad_guess_num,"WRONG GUESSES!")
           #print("Thank you for playing hangman!")
           break
        else:
            print("Your progress so far: ")
            print(shown_word)
    elif bad_guess_num < 5:
        bad_guess_num += 1
        draw_hangman(bad_guess_num)
        print("Sorry,", guess, "is not in the secret number")
        print("Bad guess number", bad_guess_num, "out of 6!")
        print("Your progress so far: ")
        print(shown_word)
        if bad_guess_num >= 3:
            for i in range(len(shown_word)):
                if shown_word[i] == "_":
                    print("Hint: one of the char is:", secret_word[i])
                    break
    elif bad_guess_num == 5:
        bad_guess_num += 1
        draw_hangman(bad_guess_num)
        print("Sorry,", guess, "is not in the secret number")
        print("The word was", secret_word)
        print("GAME OVER. YOU LOSE!")
        #print("Thank you for playing hangman!")
        break
    
        
    
        

        
# WINNING THE GAME
"""
        if : #check for winning
            print('CONGRATULATIONS YOU WON WITH ONLY',wrong,'WRONG GUESSES!')
            break
        else:
            pass"""
# LOSING THE GAME
"""
        print('GAME OVER. YOU LOSE!')
"""
# END OF WHILE TRUE LOOP


print('Thank you for playing hangman!')
turtle.clear()













