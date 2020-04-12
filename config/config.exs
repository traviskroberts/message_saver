# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :message_saver,
  ecto_repos: [MessageSaver.Repo]

# Configures the endpoint
config :message_saver, MessageSaverWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "RRJK20e4w+wXT/Ome0xSRRQi9N2GhAHuQWlr3nfh8AJ3w2z3CfMnS3gU08cyo6IH",
  render_errors: [view: MessageSaverWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: MessageSaver.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "nCsIobiA"]

config :message_saver, http_adapter: HTTPoison

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :bugsnag,
  api_key: {:system, "BUGSNAG_API_KEY"},
  release_stage: {:system, "PHOENIX_ENV", "development"},
  notify_release_stages: ["production"],
  app_version: Mix.Project.config()[:version],
  in_project: ~r(message_saver)

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
