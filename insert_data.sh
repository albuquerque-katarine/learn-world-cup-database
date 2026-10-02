if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Insert teams
cat games.csv | tail -n +2 | cut -d',' -f3,4 | tr ',' '\n' | sort -u |
while IFS= read -r TEAM
do
  echo "INSERT INTO teams(name) VALUES('$TEAM') ON CONFLICT (name) DO NOTHING;"
done > /tmp/insert.sql

# Insert games
cat games.csv | tail -n +2 |
while IFS=',' read -r YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  echo "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', (SELECT team_id FROM teams WHERE name='$WINNER'), (SELECT team_id FROM teams WHERE name='$OPPONENT'), $WINNER_GOALS, $OPPONENT_GOALS);"
done >> /tmp/insert.sql

$PSQL "$(cat /tmp/insert.sql)"
