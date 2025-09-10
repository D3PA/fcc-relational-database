#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# limpiar tablas antes de insertar (probando)
# $PSQL "TRUNCATE games, teams RESTART IDENTITY;"

# funcion para obtener el team_id, insertando si no existe
get_team_id() {
  local TEAM_NAME=$1
  local TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$TEAM_NAME';")

  if [[ -z $TEAM_ID ]]
  then
    $PSQL "INSERT INTO teams(name) VALUES('$TEAM_NAME');"
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$TEAM_NAME';")
  fi

  echo $TEAM_ID
}

# insertar equipos unicos
cat games.csv | tail -n +2 | cut -d',' -f3,4 | tr ',' '\n' | sort | uniq | while read TEAM
do
  get_team_id "$TEAM" > /dev/null
done

# insertar partidos
cat games.csv | tail -n +2 | while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  WINNER_ID=$(get_team_id "$WINNER")
  OPPONENT_ID=$(get_team_id "$OPPONENT")

  $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS);"
done