#!/bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Clear existing data in tables (optional)
$PSQL "TRUNCATE TABLE games, teams RESTART IDENTITY;"

# Read and insert data from games.csv
while IFS="," read -r year round winner opponent winner_goals opponent_goals
do
  # Skip header row
  if [[ $year != "year" ]]
  then
    # Insert winner team if not exists
    winner_id=$($PSQL "SELECT team_id FROM teams WHERE name='$winner'")
    if [[ -z $winner_id ]]
    then
      $PSQL "INSERT INTO teams(name) VALUES('$winner')"
      winner_id=$($PSQL "SELECT team_id FROM teams WHERE name='$winner'")
    fi

    # Insert opponent team if not exists
    opponent_id=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent'")
    if [[ -z $opponent_id ]]
    then
      $PSQL "INSERT INTO teams(name) VALUES('$opponent')"
      opponent_id=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent'")
    fi

    # Verify that both winner_id and opponent_id are retrieved before inserting into games
    if [[ -n $winner_id && -n $opponent_id ]]
    then
      $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($year, '$round', $winner_id, $opponent_id, $winner_goals, $opponent_goals)"
    else
      echo "Error: Missing team ID for either winner '$winner' or opponent '$opponent'"
    fi
  fi
done < games.csv
