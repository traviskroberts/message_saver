defmodule MessageSaver.MessageFormatter do
  def add_context(list, message) do
    text =
      ":speech_balloon:"
      |> add_attribution(message)
      |> add_permalink(message)
      |> add_notes(message)

    context = %{
      "type" => "context",
      "elements" => [
        %{
          "type" => "mrkdwn",
          "text" => text
        }
      ]
    }

    [context | list]
  end

  def add_delete_button(list, message) do
    button = %{
      "type" => "actions",
      "elements" => [
        %{
          "type" => "button",
          "text" => %{
            "type" => "plain_text",
            "text" => "Delete Message",
            "emoji" => true
          },
          "value" => "#{message.id}"
        }
      ]
    }

    [button | list]
  end

  def add_divider(list) do
    divider = %{
      "type" => "divider"
    }

    [divider | list]
  end

  def add_text(list, message) do
    text = %{
      "type" => "section",
      "text" => %{
        "type" => "mrkdwn",
        "text" => message.text
      }
    }

    [text | list]
  end

  defp add_attribution(str, message) do
    str <> " Posted by <@#{message.author}> in <##{message.channel}>"
  end

  defp add_notes(str, message) do
    if message.notes do
      str <> "\nNotes: #{message.notes}"
    else
      str
    end
  end

  defp add_permalink(str, message) do
    str <> " | <#{message.permalink}|View message>"
  end
end
