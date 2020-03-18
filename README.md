# MessageSaver

To run locally:

  * Install dependencies - `mix deps.get`
  * Create local `.env` file - `cp .env.template .env`
  * Edit `.env` file if necessary
  * Create database - `source .env && mix ecto.setup`
  * Install packages - `cd assets && npm install && cd -`
  * Start the server - `source .env && mix phx.server`
