defmodule MessageSaver.MessageHandler do
  alias MessageSaver.{Message, MessageFormatter, Repo}

  def clear_messages(payload) do
    Message.delete_all_for_user(payload["user_id"])

    send_confirmation("clear", payload["response_url"])
  end

  def handle_action(%{"actions" => [action | _], "response_url" => response_url, "user" => %{"id" => user_id}}) do
    if action["text"]["text"] == "Delete Message" do
      Message.delete(action["value"])
      retrieve_messages(%{"user_id" => user_id, "response_url" => response_url})
    end
  end

  def save_message(payload) do
    attrs = %{
      author: extract_author(payload["message"]),
      channel: payload["channel"]["id"],
      permalink: get_permalink(payload),
      text: extract_text(payload["message"]),
      user_id: payload["user"]["id"]
    }

    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert!()

    send_confirmation("save", payload["response_url"])
  end

  def retrieve_messages(%{"user_id" => user_id, "response_url" => response_url}) do
    messages = Message.for_user(user_id)

    if Enum.count(messages) > 0 do
      messages
      |> build_response()
      |> Enum.reverse()
      |> send_messages(user_id)
    else
      send_confirmation("list_empty", response_url)
    end
  end

  defp build_response(messages) do
    blocks = [
      %{
        "type" => "section",
        "text" => %{
          "type" => "mrkdwn",
          "text" => "*Your saved messages*\n\n"
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

  defp get_permalink(payload) do
    %{"channel" => %{"id" => channel_id}, "message" => %{"ts" => timestamp}} = payload

    body = %{
      "token" => System.get_env("SLACK_TOKEN"),
      "channel" => channel_id,
      "message_ts" => timestamp
    }
    case HTTPoison.get("https://slack.com/api/chat.getPermalink", [], params: body) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body
        |> Poison.decode!()
        |> Map.fetch!("permalink")
      _ -> nil
    end
  end

  defp send_confirmation(action, response_url) do
    text =
      case action do
        "clear" -> "All saved messages have been deleted."
        "deleted" -> "Message deleted!"
        "list_empty" -> "You don’t have any saved messages."
        "save" -> "Message saved!"
      end

    body = Poison.encode!(%{"text" => text, "response_type" => "ephemeral"})
    HTTPoison.post(response_url, body, [{"Content-Type", "application/json"}])
  end

  defp send_messages(formatted_messages, user_id) do
    body =
      URI.encode_query(%{
        token: System.get_env("SLACK_TOKEN"),
        text: "Your saved messages:",
        channel: user_id,
        blocks: Poison.encode!(formatted_messages)
      })
    HTTPoison.post("https://slack.com/api/chat.postMessage", body, [{"Content-Type", "application/x-www-form-urlencoded"}])
  end
end
