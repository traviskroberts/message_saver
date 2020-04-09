defmodule MessageSaver.Repo.Migrations.AddRemindAtIndexToMessages do
  use Ecto.Migration

  def change do
    create index(:messages, [:remind_at])
  end
end
