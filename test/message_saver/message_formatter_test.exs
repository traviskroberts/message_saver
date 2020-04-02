defmodule MessageSaver.MessageFormatterTest do
  use MessageSaver.DataCase, async: true

  alias MessageSaver.MessageFormatter

  describe "add_context/2" do
    test "it adds the message context to the list" do
      message = %{
        author: "author_name",
        channel: "channel-name",
        permalink: "permalink_url"
      }

      expected_message = %{
        "type" => "context",
        "elements" => [
          %{
            "type" => "mrkdwn",
            "text" =>
              ":speech_balloon: Posted by <@author_name> in <#channel-name> | <permalink_url|View message>"
          }
        ]
      }

      assert MessageFormatter.add_context([], message) == [expected_message]
    end
  end

  describe "add_delete_button/2" do
    test "it adds the delete button to the list" do
      message = %{id: 12}

      expected_map = %{
        "type" => "actions",
        "elements" => [
          %{
            "type" => "button",
            "text" => %{
              "type" => "plain_text",
              "text" => "Delete Message",
              "emoji" => true
            },
            "value" => "12"
          }
        ]
      }

      assert MessageFormatter.add_delete_button([], message) == [expected_map]
    end
  end

  describe "add_divider/1" do
    test "it adds a divider to the list" do
      expected_map = %{
        "type" => "divider"
      }

      assert MessageFormatter.add_divider(["rest"]) == [expected_map | ["rest"]]
    end
  end

  describe "add_text/2" do
    test "it adds the message text to the list" do
      message = %{text: "message text"}

      expected_map = %{
        "type" => "section",
        "text" => %{
          "type" => "mrkdwn",
          "text" => "message text"
        }
      }

      assert MessageFormatter.add_text(["rest"], message) == [expected_map | ["rest"]]
    end
  end
end
