#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Generate random number between 1 and 1000
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

echo "Enter your username:"
read USERNAME

# Check database for user
USER_DATA=$($PSQL "SELECT games_played, best_game FROM users WHERE username='$USERNAME'")

if [[ -z $USER_DATA ]]
then
  # New user
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  # Insert new user into DB
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
else
  # Existing user
  echo "$USER_DATA" | while IFS="|" read GAMES_PLAYED BEST_GAME
  do
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi

echo "Guess the secret number between 1 and 1000:"
TRIES=0

while true
do
  read GUESS
  (( TRIES++ ))

  # Check if input is an integer
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    continue
  fi

  if [[ $GUESS -eq $SECRET_NUMBER ]]
  then
    echo "You guessed it in $TRIES tries. The secret number was $SECRET_NUMBER. Nice job!"
    break
  elif [[ $GUESS -gt $SECRET_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  else
    echo "It's higher than that, guess again:"
  fi
done

# Update Database after game ends
# Update games played
UPDATE_GAMES=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE username='$USERNAME'")

# Update best game if it's the first game or if current tries is lower than best_game
if [[ -z $BEST_GAME || $TRIES -lt $BEST_GAME ]]
then
  UPDATE_BEST=$($PSQL "UPDATE users SET best_game = $TRIES WHERE username='$USERNAME'")
fi