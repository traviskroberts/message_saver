defmodule MessageSaver.MessageHandler do
  alias MessageSaver.MessageFormatter
  alias MessageSaver.MessageHandler

  def clear_messages(%{"user_id" => user_id, "response_url" => response_url}) do
    MessageSaver.delete_all_messages_for_user(user_id)

    send_confirmation("clear", response_url)
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
    HTTPoison.post(response_url, body, [{"Content-Type", "application/json"}])
  end

  def present_modal(message, trigger_id) do
    headers = [{"Content-Type", "application/x-www-form-urlencoded"}]
    body =
      URI.encode_query(%{
        token: System.get_env("SLACK_TOKEN"),
        trigger_id: trigger_id,
        view: Poison.encode!(modal_body(message.id))
      })
    HTTPoison.post("https://slack.com/api/views.open", body, headers)
  end

  def retrieve_messages(%{"user_id" => user_id, "response_url" => response_url}) do
    messages = MessageSaver.messages_for_user(user_id)

    if Enum.count(messages) > 0 do
      messages
      |> build_list_response()
      |> Enum.reverse()
      |> send_messages(user_id)
    else
      send_confirmation("list_empty", response_url)
    end
  end

  def save_message(payload) do
    message = MessageSaver.save_new_message(%{
      author: extract_author(payload["message"]),
      channel: payload["channel"]["id"],
      text: extract_text(payload["message"]),
      user_id: payload["user"]["id"]
    })

    Task.async(MessageHandler, :set_permalink, [message, payload])

    present_modal(message, payload["trigger_id"])
  end

  def send_reminder(message) do
    message
    |> build_remind_response()
    |> Enum.reverse()
    |> send_messages(message.user_id)

    MessageSaver.clear_message_reminder(message)
  end

  def send_reminders do
    MessageSaver.get_messages_needing_reminders()
    |> Enum.each(&send_reminder/1)
  end

  def set_permalink(message, payload) do
    %{"channel" => %{"id" => channel_id}, "message" => %{"ts" => timestamp}} = payload
    body = %{
      "token" => System.get_env("SLACK_TOKEN"),
      "channel" => channel_id,
      "message_ts" => timestamp
    }

    permalink =
      case HTTPoison.get("https://slack.com/api/chat.getPermalink", [], params: body) do
        {:ok, %HTTPoison.Response{status_code: 200, body: resp}} ->
          resp
          |> Poison.decode!()
          |> Map.get("permalink", "")

        _ ->
          ""
      end

    MessageSaver.update_message(message, %{"permalink" => permalink})
  end

  def unknown_command(%{"response_url" => response_url}) do
    send_confirmation("unknown", response_url)
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

  defp send_confirmation(action, response_url) do
    text =
      case action do
        "clear" -> "All saved messages have been deleted."
        "deleted" -> "Message deleted!"
        "list_empty" -> "You don’t have any saved messages."
        "save" -> "Message saved!"
        "unknown" -> "Unknown command. Use `/saved_messages help` to see available commands."
      end

    body = Poison.encode!(%{"text" => text, "response_type" => "ephemeral"})
    HTTPoison.post(response_url, body, [{"Content-Type", "application/json"}])
  end

  defp send_messages(formatted_messages, user_id) do
    body =
      URI.encode_query(%{
        token: System.get_env("SLACK_TOKEN"),
        channel: user_id,
        blocks: Poison.encode!(formatted_messages)
      })

    HTTPoison.post("https://slack.com/api/chat.postMessage", body, [
      {"Content-Type", "application/x-www-form-urlencoded"}
    ])
  end

  defp modal_body(message_id) do
    %{
      "type" => "modal",
      "callback_id" => Integer.to_string(message_id),
      "title" => %{
        "type" => "plain_text",
        "text" => "Save Message",
        "emoji" => true
      },
      "submit" => %{
        "type" => "plain_text",
        "text" => "Save",
        "emoji" => true
      },
      "close" => %{
        "type" => "plain_text",
        "text" => "Cancel",
        "emoji" => true
      },
      "blocks" => [
        %{
          "type" => "input",
          "block_id" => "notes",
          "optional" => true,
          "element" => %{
            "action_id" => "notes_input",
            "type" => "plain_text_input",
            "multiline" => true
          },
          "label" => %{
            "type" => "plain_text",
            "text" => "Add a note (optional)",
            "emoji" => true
          }
        },
        %{
          "type" => "input",
          "block_id" => "interval",
          "optional" => true,
          "label" => %{
            "type" => "plain_text",
            "text" => "Set a reminder (optional)",
            "emoji" => true
          },
          "element" => %{
            "action_id" => "reminder_input",
            "type" => "static_select",
            "placeholder" => %{
              "type" => "plain_text",
              "text" => "Remind me in...",
              "emoji" => true
            },
            "options" => [
              %{
                "text" => %{
                  "type" => "plain_text",
                  "text" => "15 minutes",
                  "emoji" => true
                },
                "value" => "15"
              },
              %{
                "text" => %{
                  "type" => "plain_text",
                  "text" => "30 minutes",
                  "emoji" => true
                },
                "value" => "30"
              },
              %{
                "text" => %{
                  "type" => "plain_text",
                  "text" => "1 hour",
                  "emoji" => true
                },
                "value" => "60"
              },
              %{
                "text" => %{
                  "type" => "plain_text",
                  "text" => "4 hours",
                  "emoji" => true
                },
                "value" => "240"
              },
              %{
                "text" => %{
                  "type" => "plain_text",
                  "text" => "Tomorrow",
                  "emoji" => true
                },
                "value" => "tomorrow"
              }
            ]
          }
        }
      ]
    }
  end
end
