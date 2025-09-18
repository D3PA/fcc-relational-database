#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# ask username
echo "Enter your username:"
read USERNAME

# Search for user in the database
USER_INFO=$($PSQL "SELECT games_played, best_game FROM users WHERE username='$USERNAME'")

# welcome message
if [[ -z $USER_INFO ]]; then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  GAMES_PLAYED=0
  BEST_GAME=null
else
  IFS="|" read GAMES_PLAYED BEST_GAME <<< "$USER_INFO"
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# generate secret number
SECRET=$(( RANDOM % 1000 + 1 ))
TRIES=0

echo "Guess the secret number between 1 and 1000:"

while true; do
  read GUESS
  (( TRIES++ ))

  # validate if it is integer
  if ! [[ $GUESS =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi

  # compare with the secret number
  if (( GUESS < SECRET )); then
    echo "It's higher than that, guess again:"
  elif (( GUESS > SECRET )); then
    echo "It's lower than that, guess again:"
  else
    echo "You guessed it in $TRIES tries. The secret number was $SECRET. Nice job!"
    break
  fi
done

# update statistics
if [[ $BEST_GAME == "null" || $TRIES -lt $BEST_GAME ]]; then
  BEST_GAME=$TRIES
fi

NEW_GAMES=$(( GAMES_PLAYED + 1 ))
UPDATE_STATS=$($PSQL "UPDATE users SET games_played=$NEW_GAMES, best_game=$BEST_GAME WHERE username='$USERNAME'")