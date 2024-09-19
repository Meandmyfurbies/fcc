#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"
if [[ -z $1 ]]
then
  echo Please provide an element as an argument.
else
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    ELEMENT_QUERY_RESULT=$($PSQL "select name, symbol from elements where atomic_number=$1;")
    if [[ -z $ELEMENT_QUERY_RESULT ]]
    then
      echo I could not find that element in the database.
    else
      read NAME BAR SYMBOL <<< $ELEMENT_QUERY_RESULT
      read TYPE_ID BAR MASS BAR MELT_POINT BAR BOIL_POINT <<< $($PSQL "select type_id, atomic_mass, melting_point_celsius, boiling_point_celsius from properties where atomic_number=$1;")
      TYPE_NAME=$(echo $($PSQL "select type from types where type_id=$TYPE_ID;") | xargs)
      echo "The element with atomic number $1 is $NAME ($SYMBOL). It's a $TYPE_NAME, with a mass of $MASS amu. $NAME has a melting point of $MELT_POINT celsius and a boiling point of $BOIL_POINT celsius."
    fi
  else
    ELEMENT_QUERY_RESULT=$($PSQL "select atomic_number, symbol from elements where name='$1';")
    if [[ -z $ELEMENT_QUERY_RESULT ]]
    then
      ELEMENT_QUERY_RESULT=$($PSQL "select atomic_number, name from elements where symbol='$1';")
      if [[ -z $ELEMENT_QUERY_RESULT ]]
      then
        echo I could not find that element in the database.
      else
        read ATOMIC_NUMBER BAR NAME <<< $ELEMENT_QUERY_RESULT
        read TYPE_ID BAR MASS BAR MELT_POINT BAR BOIL_POINT <<< $($PSQL "select type_id, atomic_mass, melting_point_celsius, boiling_point_celsius from properties where atomic_number=$ATOMIC_NUMBER;")
        TYPE_NAME=$(echo $($PSQL "select type from types where type_id=$TYPE_ID;") | xargs)
        echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($1). It's a $TYPE_NAME, with a mass of $MASS amu. $NAME has a melting point of $MELT_POINT celsius and a boiling point of $BOIL_POINT celsius."
      fi
    else
      read ATOMIC_NUMBER BAR SYMBOL <<< $ELEMENT_QUERY_RESULT
      read TYPE_ID BAR MASS BAR MELT_POINT BAR BOIL_POINT <<< $($PSQL "select type_id, atomic_mass, melting_point_celsius, boiling_point_celsius from properties where atomic_number=$ATOMIC_NUMBER;")
      TYPE_NAME=$(echo $($PSQL "select type from types where type_id=$TYPE_ID;") | xargs)
      echo "The element with atomic number $ATOMIC_NUMBER is $1 ($SYMBOL). It's a $TYPE_NAME, with a mass of $MASS amu. $1 has a melting point of $MELT_POINT celsius and a boiling point of $BOIL_POINT celsius."
    fi
  fi
fi