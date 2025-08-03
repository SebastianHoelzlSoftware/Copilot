#! /bin/bash
mix deps.clean --all
mix clean
mix deps.get
mix compile
mix ecto.reset