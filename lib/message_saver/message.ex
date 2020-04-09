defmodule MessageSaver.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :author, :string
    field :channel, :string
    field :notes, :string
    field :permalink, :string
    field :remind_at, :naive_datetime
    field :text, :string
    field :user_id, :string

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:author, :channel, :notes, :permalink, :remind_at, :text, :user_id])
    |> validate_required([:author, :channel, :text, :user_id])
  end
end
