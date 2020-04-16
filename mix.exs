defmodule MessageSaver.MixProject do
  use Mix.Project

  def project do
    [
      app: :message_saver,
      version: "0.1.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {MessageSaver.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:bugsnag, "~> 2.0.0"},
      {:ecto_sql, "~> 3.1"},
      {:gettext, "~> 0.11"},
      {:httpoison, "~> 1.6"},
      {:jason, "~> 1.0"},
      {:phoenix_ecto, "~> 4.0"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_dashboard, github: "phoenixframework/phoenix_live_dashboard"},
      {:phoenix_live_view, "~> 0.12"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix, "~> 1.4.16"},
      {:plug_cowboy, "~> 2.0"},
      {:poison, "~> 3.1"},
      {:postgrex, ">= 0.0.0"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 0.4"},
      {:timex, "~> 3.0"},
      # Dev
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      # Test
      {:ex_machina, "~> 2.4", only: :test}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
