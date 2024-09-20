#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=number_guess -t -c"
SECRET_NUMBER=$(( $RANDOM % 1000 + 1 ))
echo Enter your username:
read USERNAME
USER_ID=$($PSQL "select user_id from users where name='$USERNAME';")
QUERY_RESULT=""
GAMES_PLAYED=0
BEST_GAME=Placeholder
if [[ -z $USER_ID ]]
then
  echo Welcome, $USERNAME! It looks like this is your first time here.
  INSERT_USER_RESULT=$($PSQL "insert into users(name) values('$USERNAME');")
  USER_ID=$($PSQL "select user_id from users where name='$USERNAME';")
else
  QUERY_RESULT=$($PSQL "select games_played, best_game from users where user_id=$USER_ID;")
  read GAMES_PLAYED BAR BEST_GAME <<< $QUERY_RESULT
  echo Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.
fi
GUESSES=0
GUESS=0
while [[ true ]]
do
  if [[ $GUESSES = 0 ]]
  then
    echo Guess the secret number between 1 and 1000:
  elif [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    (( GUESSES-- ))
    echo That is not an integer, guess again:
  elif (( $GUESS < $SECRET_NUMBER ))
  then
    echo "It's higher than that, guess again:"
  elif (( $GUESS > $SECRET_NUMBER ))
  then
    echo "It's lower than that, guess again:"
  else
    UPDATE_GAMES_PLAYED_RESULT=$($PSQL "update users set games_played=$(($GAMES_PLAYED + 1)) where USER_ID=$USER_ID;")
    if [ $BEST_GAME == "Placeholder" ] || [ $GUESSES -lt $BEST_GAME ]
    then
      UPDATE_BEST_GAME_RESULT=$($PSQL "update users set best_game=$GUESSES where user_id=$USER_ID;")
    fi
    echo "You guessed it in $GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
    break
  fi
  read GUESS
  (( GUESSES++ ))
done