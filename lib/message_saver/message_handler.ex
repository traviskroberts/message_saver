defmodule MessageSaver.MessageHandler do
  alias MessageSaver.MessageFormatter
  alias MessageSaver.MessageHandler
  alias MessageSaver.SlackAdapter

  @http_adapter Application.get_env(:message_saver, :http_adapter)

  def clear_messages(%{"user_id" => user_id, "response_url" => response_url}) do
    MessageSaver.delete_all_messages_for_user(user_id)

    SlackAdapter.send_confirmation("clear", response_url)
  end

  def handle_action(%{
        "actions" => [action | _],
        "response_url" => response_url,
        "user" => %{"id" => user_id}
      }) do
    if action["text"]["text"] == "Delete Message" do
      MessageSaver.delete_message_for_user(user_id, action["value"])

      retrieve_messages(%{"user_id" => user_id, "response_url" => response_url})
    end
  end

  def help_text(%{"response_url" => response_url}) do
    help_text = """
      *Valid commands*:\n
      `/saved_messages list` (or `/saved`) - list your saved messages\n
      `/saved_messages clear` - clear all of your saved messages\n
      `/saved_messages help` - list this help message
    """

    body = Poison.encode!(%{"text" => help_text, "response_type" => "ephemeral"})
    @http_adapter.post(response_url, body, [{"Content-Type", "application/json"}])
  end

  def retrieve_messages(%{"user_id" => user_id, "response_url" => response_url}) do
    messages = MessageSaver.messages_for_user(user_id)

    if Enum.count(messages) > 0 do
      messages
      |> build_list_response()
      |> Enum.reverse()
      |> SlackAdapter.send_messages_list(user_id)
    else
      SlackAdapter.send_confirmation("list_empty", response_url)
    end
  end

  def save_message(payload) do
    attrs = %{
      author: extract_author(payload["message"]),
      channel: payload["channel"]["id"],
      text: extract_text(payload["message"]),
      user_id: payload["user"]["id"]
    }

    case MessageSaver.save_new_message(attrs) do
      {:ok, message} ->
        Task.async(MessageHandler, :set_permalink, [message, payload])
        SlackAdapter.present_modal(message.id, payload["trigger_id"])

      {:error, _changeset} ->
        SlackAdapter.send_confirmation("save_error", payload["response_url"])
    end
  end

  def send_reminder(message) do
    message
    |> build_remind_response()
    |> Enum.reverse()
    |> SlackAdapter.send_messages_list(message.user_id)

    MessageSaver.clear_message_reminder(message)
  end

  def send_reminders do
    MessageSaver.get_messages_needing_reminders()
    |> Enum.each(&send_reminder/1)
  end

  def set_permalink(message, payload) do
    permalink = SlackAdapter.get_permalink(payload)

    MessageSaver.update_message(message, %{"permalink" => permalink})
  end

  def unknown_command(%{"response_url" => response_url}) do
    SlackAdapter.send_confirmation("unknown", response_url)
  end

  def update_message_options(%{"view" => %{"callback_id" => message_id, "state" => state}}) do
    %{
      "values" => %{
        "notes" => %{
          "notes_input" => notes_input
        },
        "interval" => %{
          "reminder_input" => reminder_input
        }
      }
    } = state

    if notes_input["value"] do
      MessageSaver.update_message(message_id, %{"notes" => notes_input["value"]})
    end

    if reminder_input["selected_option"] do
      interval = reminder_input["selected_option"]["value"]

      datetime =
        case interval do
          "tomorrow" ->
            Timex.now()
            |> Timex.beginning_of_day()
            |> Timex.shift(hours: 30)

          _ ->
            Timex.now()
            |> Timex.shift(minutes: String.to_integer(interval))
        end

      MessageSaver.update_message(message_id, %{"remind_at" => datetime})
    end
  end

  defp build_list_response(messages) do
    blocks = [
      %{
        "type" => "section",
        "text" => %{
          "type" => "mrkdwn",
          "text" => "*Your saved messages*:\n\n"
        }
      }
    ]

    Enum.reduce(messages, blocks, fn message, acc ->
      acc
      |> MessageFormatter.add_divider()
      |> MessageFormatter.add_text(message)
      |> MessageFormatter.add_context(message)
      |> MessageFormatter.add_delete_button(message)
    end)
  end

  defp build_remind_response(message) do
    blocks = [
      %{
        "type" => "section",
        "text" => %{
          "type" => "mrkdwn",
          "text" => "*You asked me to remind you about this message*:\n\n"
        }
      }
    ]

    blocks
    |> MessageFormatter.add_divider()
    |> MessageFormatter.add_text(message)
    |> MessageFormatter.add_context(message)
  end

  defp extract_author(message) do
    user = Map.get(message, "user", "")
    bot = Map.get(message, "bot_id", "")

    cond do
      String.trim(user) != "" ->
        user

      String.trim(bot) != "" ->
        bot

      true ->
        nil
    end
  end

  defp extract_text(message) do
    text = Map.get(message, "text", %{})
    attachments = Map.get(message, "attachments", [%{}])
    fallback = Map.get(List.first(attachments), "fallback", "")

    cond do
      String.trim(text) != "" ->
        text

      String.trim(fallback) != "" ->
        fallback

      true ->
        nil
    end
  end
end
