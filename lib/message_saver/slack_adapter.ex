defmodule MessageSaver.SlackAdapter do
  alias MessageSaver.SlackModal

  @http_adapter Application.get_env(:message_saver, :http_adapter)

  def get_permalink(%{"channel" => %{"id" => channel_id}, "message" => %{"ts" => timestamp}}) do
    body = %{
      "token" => System.get_env("SLACK_TOKEN"),
      "channel" => channel_id,
      "message_ts" => timestamp
    }

    case @http_adapter.get("https://slack.com/api/chat.getPermalink", [], params: body) do
      {:ok, %HTTPoison.Response{status_code: 200, body: resp}} ->
        resp
        |> Poison.decode!()
        |> Map.get("permalink", "")

      _ ->
        ""
    end
  end

  def present_modal(message_id, trigger_id) do
    headers = [{"Content-Type", "application/x-www-form-urlencoded"}]

    body =
      URI.encode_query(%{
        token: System.get_env("SLACK_TOKEN"),
        trigger_id: trigger_id,
        view: Poison.encode!(SlackModal.body(message_id))
      })

    @http_adapter.post("https://slack.com/api/views.open", body, headers)
  end

  def send_confirmation(action, response_url) do
    text =
      case action do
        "clear" -> "All saved messages have been deleted."
        "deleted" -> "Message deleted!"
        "list_empty" -> "You don’t have any saved messages."
        "save" -> "Message saved!"
        "save_error" -> "There was an error saving that message."
        "unknown" -> "Unknown command. Use `/saved_messages help` to see available commands."
      end

    body = Poison.encode!(%{"text" => text, "response_type" => "ephemeral"})
    @http_adapter.post(response_url, body, [{"Content-Type", "application/json"}])
  end

  def send_messages_list(messages, user_id) do
    body =
      URI.encode_query(%{
        token: System.get_env("SLACK_TOKEN"),
        channel: user_id,
        blocks: Poison.encode!(messages)
      })

    @http_adapter.post("https://slack.com/api/chat.postMessage", body, [
      {"Content-Type", "application/x-www-form-urlencoded"}
    ])
  end
end
