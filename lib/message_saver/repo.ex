defmodule MessageSaver.Repo do
  use Ecto.Repo,
    otp_app: :message_saver,
    adapter: Ecto.Adapters.Postgres
end
