defmodule MessageSaver.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :user_id, :string
      add :author, :string
      add :channel, :string
      add :text, :text
      add :permalink, :string

      timestamps()
    end
  end
end
