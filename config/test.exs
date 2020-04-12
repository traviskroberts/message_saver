use Mix.Config

# Configure your database
config :message_saver, MessageSaver.Repo,
  hostname: System.get_env("DB_HOST"),
  username: System.get_env("DB_USERNAME"),
  password: System.get_env("DB_PASSWORD"),
  database: "message_saver_test",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :message_saver, MessageSaverWeb.Endpoint,
  http: [port: 4002],
  server: false

config :message_saver, http_adapter: MessageSaver.Test.HttpStub

# Print only warnings and errors during test
config :logger, level: :warn
