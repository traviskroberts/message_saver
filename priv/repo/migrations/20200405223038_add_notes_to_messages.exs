defmodule MessageSaver.Repo.Migrations.AddNotesToMessages do
  use Ecto.Migration

  def change do
    alter table(:messages) do
      add :notes, :text
    end
  end
end
