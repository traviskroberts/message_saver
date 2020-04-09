defmodule MessageSaver.Repo.Migrations.AddRemindAtToMessages do
  use Ecto.Migration

  def change do
    alter table(:messages) do
      add :remind_at, :naive_datetime
    end
  end
end
