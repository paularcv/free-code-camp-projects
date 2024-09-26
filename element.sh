#!/bin/bash

# Check if an argument is provided
if [ -z "$1" ]; then
    echo "Please provide an element as an argument."
    exit 0
fi

SEARCH_VALUE=$1

# Set up the PSQL command
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Execute the query and store the result
RESULT=$($PSQL "SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius \
FROM elements AS e \
JOIN properties AS p ON e.atomic_number = p.atomic_number \
JOIN types AS t ON p.type_id = t.type_id \
WHERE e.atomic_number::text = '$SEARCH_VALUE' OR e.name = '$SEARCH_VALUE' OR e.symbol = '$SEARCH_VALUE';")

# Check if the result is empty
if [ -z "$RESULT" ]; then
    echo "I could not find that element in the database."
    exit 0
fi

# Read the result into variables
IFS='|' read -r ATOMIC_NUMBER NAME SYMBOL TYPE ATOMIC_MASS MELTING_POINT BOILING_POINT <<< "$RESULT"

# Output the result
echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."