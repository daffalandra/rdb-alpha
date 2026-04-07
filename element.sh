#!/bin/bash

# Add Database Conection
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Handle non element case
if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
else
  # Check if input is a number
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    WHERE_CLAUSE="atomic_number = $1"
  else
    WHERE_CLAUSE="symbol = '$1' OR name = '$1'"
  fi

  # Query for element data
  # REFACTOR JOIN
  DATA=$($PSQL "SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements JOIN properties USING(atomic_number) JOIN types USING(type_id) WHERE $WHERE_CLAUSE")

  # if theres not the data
  if [[ -z $DATA ]]
  then
    echo "I could not find that element in the database."
  else
    echo "$DATA" | while IFS="|" read AN NAME SYMBOL TYPE MASS MELT BOIL
    do
      echo "The element with atomic number $AN is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELT celsius and a boiling point of $BOIL celsius."
    done
  fi
fi