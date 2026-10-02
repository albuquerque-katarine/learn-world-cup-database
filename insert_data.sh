#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql -h 127.0.0.1 --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql -h 127.0.0.1 --username=postgres --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Empty the database
$PSQL "TRUNCATE TABLE games, teams;"

# Build one SQL command instead of calling psql for every row
SQL="BEGIN;"

# Read the CSV file and collect unique teams
TEAMS=""

while IFS=',' read -r YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]]
  then
    TEAMS="$TEAMS('$WINNER'),('$OPPONENT'),"
  fi
done < games.csv

TEAMS="${TEAMS%,}"

SQL="$SQL INSERT INTO teams(name) VALUES $TEAMS ON CONFLICT (name) DO NOTHING;"

SQL="$SQL INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES"

FIRST=true

while IFS=',' read -r YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]]
  then
    if [[ $FIRST == true ]]
    then
      FIRST=false
    else
      SQL="$SQL,"
    fi

    SQL="$SQL($YEAR, '$ROUND', (SELECT team_id FROM teams WHERE name='$WINNER'), (SELECT team_id FROM teams WHERE name='$OPPONENT'), $WINNER_GOALS, $OPPONENT_GOALS)"
  fi
done < games.csv

SQL="$SQL; COMMIT;"

$PSQL "$SQL"
