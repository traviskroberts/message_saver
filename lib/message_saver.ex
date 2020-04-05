defmodule MessageSaver do
  import Ecto.Query, warn: false

  alias MessageSaver.{Message, Repo}

  def delete_all_messages_for_user(user_id) do
    query =
      from m in Message,
        where: m.user_id == ^user_id

    Repo.delete_all(query)
  end

  def delete_message_for_user(user_id, message_id) do
    query =
      from m in Message,
        where: m.user_id == ^user_id,
        where: m.id == ^message_id

    Repo.delete_all(query)
  end

  def messages_for_user(user_id) do
    query =
      from m in Message,
        where: m.user_id == ^user_id

    Repo.all(query)
  end

  def save_new_message(attrs) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert!()
  end
end
