defmodule MessageSaver do
  import Ecto.Query, warn: false

  alias MessageSaver.{Message, Repo}

  def clear_message_reminder(message) do
    message
    |> Message.changeset(%{remind_at: nil})
    |> Repo.update()
  end

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

  def get_message(message_id) do
    query =
      from m in Message,
        where: m.id == ^message_id

    Repo.one!(query)
  end

  def get_messages_needing_reminders do
    datetime = Timex.now()
    query =
      from m in Message,
        where: m.remind_at < ^datetime

    Repo.all(query)
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

  def update_message(%Message{} = message, attrs) do
    message
    |> Message.changeset(attrs)
    |> Repo.update()
  end

  def update_message(message_id, attrs) do
    Message
    |> Repo.get!(message_id)
    |> Message.changeset(attrs)
    |> Repo.update()
  end
end
