defmodule MessageSaver.Message do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false

  alias MessageSaver.{Message, Repo}

  schema "messages" do
    field :author, :string
    field :channel, :string
    field :permalink, :string
    field :text, :string
    field :user_id, :string

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:author, :channel, :permalink, :text, :user_id])
    |> validate_required([:author, :channel, :text, :user_id])
  end

  def delete_all_for_user(user_id) do
    query =
      from m in Message,
        where: m.user_id == ^user_id

    Repo.delete_all(query)
  end

  def delete(id) do
    query =
      from m in Message,
        where: m.id == ^id

    Repo.delete_all(query)
  end

  def for_user(user_id) do
    query =
      from m in Message,
        where: m.user_id == ^user_id

    Repo.all(query)
  end
end
