defmodule MessageSaver.Message do
  use Ecto.Schema
  import Ecto.Changeset

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
end
