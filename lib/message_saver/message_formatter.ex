defmodule MessageSaver.MessageFormatter do
  def add_context(list, message) do
    context = %{
      "type" => "context",
      "elements" => [
        %{
          "type" => "mrkdwn",
          "text" => ":speech_balloon: Posted by <@#{message.author}> in <##{message.channel}> | <#{message.permalink}|View message>"
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
end
