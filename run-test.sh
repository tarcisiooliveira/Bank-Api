#!/bin/bash

# Wait until Postgres is ready
while ! pg_isready -q -h $PG_HOSTNAME -p $PG_PORT -U $PG_USERNAME
do
  echo "$(date) - waiting for database to start"
  sleep 2
done


mix deps.get
cd deps/argon2_elixir && make clean && make
cd ../..
mix test --warnings-as-errors
